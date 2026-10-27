# LaTeX lab report sample

A lab report template with LaTeX sources in `src/`, examples in `src/taskN.tex`,
and reusable LaTeX commands.

**Ubuntu 22.04 setup:** `install.sh` installs Make, TeX Live, `latexmk`, Russian
support, and the required LaTeX/font packages. It reuses an existing upstream
TeX Live installation when available; otherwise it installs Ubuntu’s packages.

```bash
bash install.sh
bash pdf.sh
```

**Ubuntu 24.04 setup:** later !

To clear the cache and rebuild:

```bash
bash pdf.sh --clean
```

Final PDF: `build/main.pdf`. Cache and logs: `artifacts/`.
