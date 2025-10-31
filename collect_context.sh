#!/usr/bin/env bash

# --- Functions ---

# Gathers file contents, respecting .gitignore
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
        # 3. Check the file's encoding.
        local encoding
        encoding=$(file -L --mime-encoding -b "$file")
        
        # 4. If the encoding is NOT binary, we can safely print it.
        #    This is a "deny-list" approach, which is far more robust
        #    than trying to "allow-list" all possible text types.
        if [[ "$encoding" != "binary" ]]; then
            echo "======== FILE: $file ========"
            cat "$file"
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
    
    echo "======== GIT STATUS (SHORT) ========"
    git status --short
    echo
    
    echo "======== GIT DIFF (UNSTAGED) ========"
    git --no-pager diff
    echo
    
    echo "======== GIT DIFF (STAGED) ========"
    git --no-pager diff --staged
    echo
    
    echo "======== GIT LOG (LAST 5) ========"
    git --no-pager log -n 5 --oneline
    echo
}

# --- Main Logic ---
main() {
    echo "Gathering project context..." >&2

    # Gather all context and print it to standard output
    gather_git_context
    gather_file_context

    echo "Context output complete." >&2
}

# Pass all script arguments to the main function
main "$@"