#!/usr/bin/env bash

# --- Functions ---

# Gathers file contents, respecting .gitignore
gather_file_context() {
    # 1. Use `git ls-files` to get all relevant files.
    #    -c = cached (files Git knows about)
    #    -o = others (untracked files)
    #    --exclude-standard = respect .gitignore
    # This is a robust way to get all non-ignored files.
    local file_list
    file_list=$(git ls-files -c -o --exclude-standard)
    
    # Loop through the filtered list
    while IFS= read -r file; do
        # 2. Check MIME type to ensure it's text
        #    We add -L to follow symlinks, just in case.
        local mime_type
        mime_type=$(file -L --mime-type -b "$file")
        
        # 3. Check if the mime_type string starts with "text/"
        if [[ "$mime_type" == text/* ]]; then
            echo "======== FILE: $file ========"
            cat "$file"
            echo
        fi
    done <<< "$file_list"
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