#!/usr/bin/env bash

set -euo pipefail

# --- Functions ---

# Prints usage information to stderr and exits with the provided code
usage() {
    cat >&2 << 'EOF'
Usage: collect_context.sh [-h] [-d <dir>] [-c]

Collects project context including Git information and file contents.

Options:
  -h, --help     Show this help message and exit
  -d <dir>       Target repository directory (default: current directory)
  -c, --copy     Copy output directly to the system clipboard

Examples:
  collect_context.sh                        # Run in current directory
  collect_context.sh -d /path/to/project    # Run in specific directory
  collect_context.sh -c                     # Copy output to clipboard
  collect_context.sh -d /path/to/project -c # Run in directory and copy to clipboard
EOF
    exit "${1:-0}"
}

# Routes stdin to the system clipboard using xclip
pipe_to_clipboard() {
    # xclip is required and checked in dependencies
    cat | xclip -selection clipboard
}

# Checks for required dependencies and exits if any are missing
check_dependencies() {
    local deps=("git" "file" "awk" "xclip")
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            echo "Error: Required command '$dep' is not installed." >&2
            exit 1
        fi
    done
}

# Gathers file contents, respecting .gitignore
gather_file_context() {
    # 1. Use `git ls-files` to get all relevant files.
    #    -c = cached (files Git knows about)
    #    -o = others (untracked files)
    #    --exclude-standard = respect .gitignore
    #
    # 2. Pipe the list directly into the `while` loop.
    #    This is more efficient than storing it in a variable.
    git ls-files -c -o --exclude-standard | while IFS= read -r file; do
        # 3. Filter token-heavy text files using a case statement
        case "$file" in
            *lock.json|*.lock|*-lock.yaml|*.min.js) continue ;;
        esac
        
        # 4. Check the file's encoding.
        local encoding
        encoding=$(file -L --mime-encoding -b "$file")
        
        # 5. If the encoding is NOT binary, we can safely print it.
        #    This is a "deny-list" approach, which is far more robust
        #    than trying to "allow-list" all possible text types.
        if [[ "$encoding" != "binary" ]]; then
            echo "### File: \`$file\`"
            # 6. Extract extension efficiently using short-circuit evaluation
            local ext="${file##*.}"
            [[ "$ext" == "$file" ]] && ext=""
            # 7. Add syntax highlighting hints
            echo '```'"$ext"
            # 8. Prevent markdown syntax breakage by ensuring trailing newline
            awk 1 "$file"
            echo '```'
            echo
        fi
    done
}

# Gathers Git information and prints it to standard output
gather_git_context() {
    # Check if we're in a git repo
    if ! git rev-parse --is-inside-work-tree &> /dev/null; then
        echo "Not a git repository. Skipping git context." >&2
        return
    fi
    
    echo "### Git Status (Short)"
    echo '```'
    git status --short
    echo '```'
    echo
    
    echo "### Git Diff (Unstaged)"
    echo '```'
    git --no-pager diff
    echo '```'
    echo
    
    echo "### Git Diff (Staged)"
    echo '```'
    git --no-pager diff --staged
    echo '```'
    echo
    
    echo "### Git Log (Last 5)"
    echo '```'
    git --no-pager log -n 5 --oneline
    echo '```'
    echo
}

# --- Main Logic ---
main() {
    local target_dir="."
    local auto_copy=false
    
    # Parse command line arguments using getopts
    while getopts ":hd:c" opt; do
        case $opt in
            h)
                usage 0
                ;;
            d)
                target_dir="$OPTARG"
                ;;
            c)
                auto_copy=true
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                usage 1
                ;;
            :)
                echo "Option -$OPTARG requires an argument." >&2
                usage 1
                ;;
        esac
    done
    
    # Shift parsed options so remaining arguments are accessible if needed
    shift $((OPTIND-1))
    
    # Navigate to the target directory
    cd "$target_dir" || { echo "Error: Cannot access directory $target_dir" >&2; exit 1; }
    
    # Check dependencies
    check_dependencies
    
    echo "Gathering project context..." >&2

    # Execute context gathering based on the -c flag
    if [[ "$auto_copy" == true ]]; then
        { gather_git_context; gather_file_context; } | pipe_to_clipboard
        echo "Context successfully copied to clipboard." >&2
    else
        gather_git_context
        gather_file_context
    fi

    echo "Context output complete." >&2
}

# Pass all script arguments to the main function
main "$@"