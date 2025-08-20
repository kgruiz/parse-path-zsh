# -----------------------------------------------------------------------------
# parsepath - Print PATH entries, one per line
# -----------------------------------------------------------------------------
#
# Description:
#   Parses the current shell PATH and prints each entry on its own line.
#   Includes useful flags for filtering, formatting, and normalization.
#
# Usage:
#   parsepath [options]
#
# Options:
#   -h, --help         Show this help and exit
#   -e, --exists       Only include entries that currently exist as directories
#   -u, --unique       Remove duplicates while preserving order
#   -r, --realpath     Resolve to absolute, canonical paths (no symlinks)
#   -n, --number       Prefix each line with a 1-based index
#   -0, --null         Output NUL-separated entries instead of newlines
#                      (disables numbering)
#
# Notes:
#   - Empty components in PATH represent the current directory (".") and are
#     shown as "." in the output.
#   - On systems without `realpath`, this uses zsh's :A modifier to resolve
#     canonical paths when --realpath is supplied.
# -----------------------------------------------------------------------------

function parsepath {
  emulate -L zsh
  setopt extendedglob

  # colours (match style used in other scripts)
  if [[ -z $ESC ]]; then readonly ESC="\033"; fi
  if [[ -z $RESET ]]; then readonly RESET="${ESC}[0m"; fi
  if [[ -z $BOLD_CYAN ]]; then readonly BOLD_CYAN="${ESC}[1;36m"; fi
  if [[ -z $YELLOW ]]; then readonly YELLOW="${ESC}[0;33m"; fi
  if [[ -z $BOLD_RED ]]; then readonly BOLD_RED="${ESC}[1;31m"; fi

  local show_help=0
  local only_exists=false
  local unique=false
  local use_realpath=false
  local number=false
  local use_null=false

  # help printer
  _parsepath_help() {
    cat <<EOF
${BOLD_CYAN}Usage:${RESET} parsepath ${YELLOW}[options]${RESET}

${BOLD_CYAN}Options:${RESET}
  -h, --help         Show this help and exit
  -e, --exists       Only include entries that currently exist as directories
  -u, --unique       Remove duplicates while preserving order
  -r, --realpath     Resolve to absolute, canonical paths (no symlinks)
  -n, --number       Prefix each line with a 1-based index
  -0, --null         Output NUL-separated entries (disables numbering)
EOF
  }

  # parse flags
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)      show_help=1; shift ;;
      -e|--exists)    only_exists=true; shift ;;
      -u|--unique)    unique=true; shift ;;
      -r|--realpath)  use_realpath=true; shift ;;
      -n|--number)    number=true; shift ;;
      -0|--null)      use_null=true; shift ;;
      --)             shift; break ;;
      -*)
        printf "%sUnknown option%s '%s'\n" "$BOLD_RED" "$RESET" "$1" >&2
        _parsepath_help >&2
        return 1
        ;;
      *)
        # no positional arguments supported
        printf "%sUnexpected argument%s '%s'\n" "$BOLD_RED" "$RESET" "$1" >&2
        _parsepath_help >&2
        return 1
        ;;
    esac
  done

  if (( show_help )); then
    _parsepath_help
    return 0
  fi

  # numbering does not make sense with NUL separation; disable it if requested
  if [[ $use_null == true && $number == true ]]; then
    number=false
  fi

  # split PATH preserving empty components
  local -a raw_entries
  raw_entries=( ${(s.:.)PATH} )

  # prepare output entries
  local -a out_entries
  local -A seen

  local p canon key
  for p in "${raw_entries[@]}"; do
    # empty means current directory
    [[ -z $p ]] && p='.'

    # realpath / canonicalise via zsh :A (absolute + resolve symlinks)
    if [[ $use_realpath == true ]]; then
      # Use parameter expansion to avoid external deps
      canon=${p:A}
    else
      canon=$p
    fi

    # existence filter
    if [[ $only_exists == true ]]; then
      [[ -d $canon ]] || continue
    fi

    # uniqueness (preserve order)
    if [[ $unique == true ]]; then
      key="$canon"
      if [[ -n ${seen[$key]} ]]; then
        continue
      fi
      seen[$key]=1
    fi

    out_entries+=( "$canon" )
  done

  # print
  if [[ $use_null == true ]]; then
    local entry
    for entry in "${out_entries[@]}"; do
      printf "%s\0" "$entry"
    done
    return 0
  fi

  local total=${#out_entries[@]}
  local width=${#total}
  local i=0
  local entry
  for entry in "${out_entries[@]}"; do
    (( i++ ))
    if [[ $number == true ]]; then
      printf "%*d  %s\n" "$width" "$i" "$entry"
    else
      printf "%s\n" "$entry"
    fi
  done

  return 0
}

# zsh completion (no positional args; just options)
if [[ -n $ZSH_VERSION ]]; then
  _parsepath() {
    _arguments \
      '(-h --help)'{-h,--help}'[show help and exit]' \
      '(-e --exists)'{-e,--exists}'[only include entries that exist as directories]' \
      '(-u --unique)'{-u,--unique}'[remove duplicates while preserving order]' \
      '(-r --realpath)'{-r,--realpath}'[resolve to absolute, canonical paths]' \
      '(-n --number)'{-n,--number}'[prefix each line with a 1-based index]' \
      '(-0 --null)'{-0,--null}'[use NUL as line separator]'
  }
  compdef _parsepath parsepath
fi
