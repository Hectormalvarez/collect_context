#!/usr/bin/env bash

# --- Functions ---

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

    echo "Context output complete." >&2
}

# Pass all script arguments to the main function
main "$@"