# collect_context.sh

A utility script that bundles a Git repository's state and non-binary source files into a single Markdown stream optimized for Large Language Model context windows.

## Dependencies

- `git` - Version control system
- `file` - File type detection
- `awk` - Text processing
- `xclip` - Clipboard integration (optional, required for `-c` flag)

## Usage

```bash
collect_context.sh [OPTIONS]
```

### Flags

- `-c, --copy` - Copy output directly to the system clipboard
- `-d <dir>, --directory <dir>` - Target a specific repository directory (default: current directory)
- `-h, --help` - Display help message and exit

### Examples

Basic execution:

```bash
collect_context.sh
```

Copy output to clipboard:

```bash
collect_context.sh -c
```

Target a specific directory:

```bash
collect_context.sh -d /path/to/project
```

Copy output from specific directory to clipboard:

```bash
collect_context.sh -d /path/to/project -c
```

## What It Does

The script collects:

1. **Git Information**: Status, unstaged changes, staged changes, and recent commit history
2. **Source Files**: Complete contents of all non-binary, text-based files in the repository
3. **Smart Filtering**: Respects `.gitignore` rules and excludes binary files automatically

All output is formatted as clean Markdown with syntax highlighting for easy consumption by LLMs.