# ollama-launch

A fast, polished CLI for picking and launching [Ollama](https://ollama.com) models interactively.

## Features

- Interactive model picker with **fzf** fuzzy search (or a numbered menu if fzf isn't installed)
- Curated list of popular models, sorted alphabetically
- Clean ANSI colors, auto-disabled in non-TTY environments
- Zero config, zero dependencies beyond bash and ollama

## Install

**One-liner:**
```bash
curl -fsSL https://raw.githubusercontent.com/isaleem/ollama-launcher/main/install.sh | bash
```

**Manual:**
```bash
git clone https://github.com/isaleem/ollama-launcher
cp ollama-launch /usr/local/bin/ollama-launch
chmod +x /usr/local/bin/ollama-launch
```

## Usage

```
ollama-launch           # open model picker
ollama-launch --list    # print all models
ollama-launch --version # print version
ollama-launch --help    # show help
```

## Adding Models

Edit the `MODELS` array near the top of `ollama-launch`:

```bash
MODELS=(
  "codellama:7b"
  "my-custom-model:latest"   # ← add here, keep sorted
  ...
)
```

Then reinstall or use the local script directly.

## Requirements

- bash 3.2+
- [ollama](https://ollama.com/download) installed and in PATH
- [fzf](https://github.com/junegunn/fzf) (optional, for fuzzy search)

## Contributing

PRs welcome. To add a model to the default list, edit `MODELS` in `ollama-launch` and open a PR.

## License

MIT
