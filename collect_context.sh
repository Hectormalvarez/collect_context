#!/usr/bin/env bash

set -euo pipefail

# --- Functions ---

# Checks for required dependencies and exits if any are missing
check_dependencies() {
    local deps=("git" "file" "awk")
    
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
    check_dependencies
    
    echo "Gathering project context..." >&2

    # Gather all context and print it to standard output
    gather_git_context
    gather_file_context

    echo "Context output complete." >&2
}

# Pass all script arguments to the main function
main "$@"