# parse-path-zsh

`parse-path-zsh` provides a Zsh function, `parsepath`, that prints each entry in your current `PATH` on its own line. It includes helpful flags for filtering, de-duplicating, canonicalizing, numbering, and NUL-separated output for scripting.

## Table of Contents

- [Key Features](#key-features)
- [Installation](#installation)
- [Usage](#usage)
- [Options](#options)
- [Examples](#examples)
- [Notes](#notes)
- [Contributing](#contributing)
- [License](#license)

## Key Features

- **Simple PATH inspection:** Print each `PATH` entry, one per line
- **Filter existing entries:** Keep only directories that exist
- **Stable de-duplication:** Remove duplicates while preserving order
- **Canonicalization:** Resolve entries to absolute, symlink-free paths
- **Indexing:** Prefix lines with a 1-based number
- **Scripting-friendly:** NUL-separated output via `--null`

## Installation

1. Clone (or download) the script to a stable location, e.g. `~/.config/zsh/plugins/parse-path-zsh`.

   ```zsh
   # Option 1: Clone the repository
   git clone https://github.com/kgruiz/parse-path-zsh.git ~/.config/zsh/plugins/parse-path-zsh

   # Option 2: Create the directory and download the file
   mkdir -p ~/.config/zsh/plugins/parse-path-zsh
   curl -o ~/.config/zsh/plugins/parse-path-zsh/parse-path.zsh \
     https://raw.githubusercontent.com/kgruiz/parse-path-zsh/main/parse-path.zsh
   ```

2. Source the script in your `.zshrc` (and enable completion).

   ```zsh
   # init zsh completion
   autoload -Uz compinit
   compinit

   # load parse-path-zsh
   PARSEPATH_FUNC_PATH="$HOME/.config/zsh/plugins/parse-path-zsh/parse-path.zsh"
   if [ -f "$PARSEPATH_FUNC_PATH" ]; then
     if ! . "$PARSEPATH_FUNC_PATH" 2>&1; then
       echo "Error: Failed to source \"$(basename "$PARSEPATH_FUNC_PATH")\"" >&2
     fi
   else
     echo "Error: \"$(basename "$PARSEPATH_FUNC_PATH")\" not found at:" >&2
     echo "  $PARSEPATH_FUNC_PATH" >&2
   fi
   unset PARSEPATH_FUNC_PATH
   ```

3. Reload your shell configuration.

   ```zsh
   source ~/.zshrc
   ```

## Usage

```zsh
parsepath [options]
```

## Options

| Option | Long | Description |
|-------:|:-----|:------------|
| `-h` | `--help` | Show help and exit |
| `-e` | `--exists` | Only include entries that currently exist as directories |
| `-u` | `--unique` | Remove duplicates while preserving order |
| `-r` | `--realpath` | Resolve to absolute, canonical paths (no symlinks) |
| `-n` | `--number` | Prefix each line with a 1-based index |
| `-0` | `--null` | Output NUL-separated entries (disables numbering) |
| `-p` | `--raw` | Print the raw PATH as a single line and exit |

## Examples

Basic listing of `PATH` entries:

```zsh
❯ parsepath
```

Only entries that exist, canonicalized to absolute paths:

```zsh
❯ parsepath --exists --realpath
```

Unique entries only (preserve first occurrence):

```zsh
❯ parsepath --unique
```

Numbered output with width based on total count:

```zsh
❯ parsepath --number
```

NUL-separated output (useful for robust scripting):

```zsh
❯ parsepath --null | xargs -0 -I{} echo {}
```

Print the raw PATH in one line (no processing):

```zsh
❯ parsepath --raw
```

Combine with other tools, e.g. filter for Node-related paths:

```zsh
❯ parsepath | grep -i node
```

## Notes

- Empty components in `PATH` represent the current directory (`.`) and are shown as `.` in the output.
- When `--realpath` is supplied, canonicalization is performed using Zsh's `:A` modifier (no external `realpath` dependency).
- The script includes Zsh completion for its flags when sourced in Zsh.
- `--raw` prints `$PATH` exactly as-is and ignores other flags.

## Contributing

Issues and PRs are welcome.

## License

Distributed under the **GNU GPL v3.0**. See [LICENSE](LICENSE) or `https://www.gnu.org/licenses/gpl-3.0.html` for details.
