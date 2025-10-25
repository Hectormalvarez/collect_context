#!/usr/bin/env bash

# --- Main Logic ---
main() {
    # Print a status message to standard error
    echo "Testing script..." >&2

    # Print the test output to standard output
    echo "Hello, standard output!"

    echo "Script setup complete." >&2
}

# Pass all script arguments to the main function
main "$@"