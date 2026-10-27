#!/usr/bin/env bash
set -euo pipefail

clean=false
make_args=()

usage() {
    cat <<'EOF'
Usage: bash pdf.sh [--clean] [--engine pdflatex|xelatex|lualatex]

Build the final PDF in build/ and keep compiler files in artifacts/.
  --clean          Remove the build cache before compiling.
  --engine ENGINE  Override the engine selected in usercfg.mk.
  -h, --help       Show this help.
EOF
}

while (($#)); do
    case "$1" in
        --clean) clean=true; shift ;;
        --engine)
            if (($# < 2)); then
                printf 'Missing value for --engine.\n' >&2
                usage >&2
                exit 2
            fi
            case "$2" in
                pdflatex) make_args+=(BACKEND=-pdf) ;;
                xelatex) make_args+=(BACKEND=-xelatex) ;;
                lualatex) make_args+=(BACKEND=-lualatex) ;;
                *) printf 'Unsupported engine: %s\n' "$2" >&2; exit 2 ;;
            esac
            shift 2
            ;;
        -h|--help) usage; exit 0 ;;
        *) printf 'Unknown argument: %s\n' "$1" >&2; usage >&2; exit 2 ;;
    esac
done

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
if "$clean"; then
    make "${make_args[@]}" clean
fi
make "${make_args[@]}" pdf
