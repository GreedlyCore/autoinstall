#!/usr/bin/env bash
set -euo pipefail

case "${1:-}" in
    -h|--help)
        printf '%s\n' 'Usage: bash install.sh' \
            'Ubuntu 22.04 setup: install TeX Live and the sample dependencies.' \
            'Reuse an existing upstream TeX Live installation when available.'
        exit 0
        ;;
    '') ;;
    *) printf 'Usage: bash install.sh\n' >&2; exit 2 ;;
esac
if (($#)); then
    printf 'Usage: bash install.sh\n' >&2
    exit 2
fi

if [[ ! -r /etc/os-release ]]; then
    printf 'This installer requires Ubuntu 22.04.\n' >&2
    exit 1
fi
. /etc/os-release
if [[ "${ID:-}" != ubuntu || "${VERSION_ID:-}" != 22.04 ]]; then
    printf 'This installer targets Ubuntu 22.04; detected %s.\n' "${PRETTY_NAME:-unknown OS}" >&2
    exit 1
fi
printf 'Ubuntu 22.04 setup: TeX Live and lab report dependencies.\n'

as_root() {
    if ((EUID == 0)); then
        "$@"
    else
        sudo "$@"
    fi
}

# Reuse standard upstream installations, including the local TeX Live 2026.
# Do not mix APT-managed TeX packages into an upstream installation.
tlmgr_bin=''
if [[ -n "${TEXLIVE_BIN:-}" ]]; then
    tlmgr_bin="${TEXLIVE_BIN%/}/tlmgr"
    if [[ ! -x "$tlmgr_bin" ]]; then
        printf 'No executable tlmgr found in TEXLIVE_BIN=%s\n' "$TEXLIVE_BIN" >&2
        exit 1
    fi
else
    shopt -s nullglob
    for candidate in /usr/local/texlive/*/bin/*/tlmgr; do
        if [[ -x "$candidate" ]]; then
            tlmgr_bin=$candidate
        fi
    done
fi

as_root apt-get update
if [[ -n "$tlmgr_bin" ]]; then
    printf 'Using existing TeX Live: %s\n' "$tlmgr_bin"
    as_root apt-get install -y make perl
    as_root "$tlmgr_bin" install \
        latexmk collection-latexrecommended collection-latexextra \
        collection-fontsrecommended collection-langcyrillic \
        cm-super sourcecodepro placeins
else
    # Ubuntu supplies its own TeX Live release; 22.04 is the OS version.
    # latex-extra includes placeins; fonts-extra includes sourcecodepro.
    as_root apt-get install -y \
        make perl latexmk texlive texlive-latex-extra \
        texlive-lang-cyrillic texlive-fonts-extra cm-super
fi

printf '\nInstallation complete. Build the report with: bash pdf.sh\n'
