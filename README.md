# ollama-launch

A fast, polished CLI for picking and launching [Ollama](https://ollama.com) models interactively. No config, no fuss — run it, pick a model, start chatting.

```
┌─────────────────────────────┐
│  ollama-launch  🦙           │
│  Pick a model to run        │
└─────────────────────────────┘
```

## Features

- Interactive model picker with **fzf** fuzzy search (type to filter, arrows to navigate)
- Numbered menu fallback when fzf is not installed — works everywhere
- 24 curated popular models ready to go, sorted alphabetically
- ANSI colors auto-disabled when output is piped or redirected
- No config files, no runtime dependencies beyond bash and ollama

---

## Requirements

| Dependency | Required | Notes |
|------------|----------|-------|
| [ollama](https://ollama.com/download) | Yes | Must be in PATH |
| bash 3.2+ | Yes | Ships with macOS and all Linux distros |
| [fzf](https://github.com/junegunn/fzf) | No | Enables fuzzy search UI; falls back to numbered menu without it |

---

## Install

### One-liner (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/quantanow/ollama-launcher/main/install.sh | bash
```

This downloads `ollama-launch` to `/usr/local/bin` and makes it executable. Uses `sudo` automatically if `/usr/local/bin` is not writable.

### Manual

```bash
git clone https://github.com/quantanow/ollama-launcher
cd ollama-launcher
cp ollama-launch /usr/local/bin/ollama-launch
chmod +x /usr/local/bin/ollama-launch
```

### Homebrew / local dev

If you just want to run it from the repo without installing:

```bash
git clone https://github.com/quantanow/ollama-launcher
cd ollama-launcher
./ollama-launch
```

### Install fzf (optional but recommended)

```bash
# macOS
brew install fzf

# Linux
sudo apt install fzf      # Debian/Ubuntu
sudo dnf install fzf      # Fedora
sudo pacman -S fzf        # Arch
```

---

## Usage

```
ollama-launch [--help | --version | --list]
```

Run with no arguments to open the interactive model picker:

```bash
ollama-launch
```

### With fzf installed

An interactive fuzzy finder opens:

```
  ↑↓ navigate  /  type to filter  /  Enter to run  /  Esc to quit
  Model: _

  codellama:7b
  deepseek-coder:6.7b
  deepseek-r1:7b
  gemma3:1b
  ...
```

Type any part of a model name to filter in real time. Press **Enter** to launch, **Esc** or **Ctrl-C** to quit without launching.

### Without fzf

A numbered list is shown:

```
Available models:

   1  codellama:7b
   2  deepseek-coder:6.7b
   3  deepseek-r1:7b
  ...
  24  starcoder2:7b

Enter number [1-24]:
```

Enter the number and press **Enter**. Invalid input re-prompts — it won't exit on a bad number. Press **Ctrl-C** to quit.

---

## Switches

| Switch | Short | Description |
|--------|-------|-------------|
| `--help` | `-h` | Show usage and exit |
| `--version` | `-v` | Print version string and exit |
| `--list` | | Print all available models, one per line, and exit |

### Examples

```bash
# Show help
ollama-launch --help

# Print version
ollama-launch --version
# → ollama-launch 1.0.0

# List all models (scriptable, pipe-friendly)
ollama-launch --list
# → codellama:7b
#   deepseek-coder:6.7b
#   ...

# Use --list with grep to check if a model is available
ollama-launch --list | grep qwen
```

---

## Available Models

The default model list (24 models, alphabetical):

| Model | Description |
|-------|-------------|
| `codellama:7b` | Meta's code-focused Llama model |
| `deepseek-coder:6.7b` | DeepSeek's coding model |
| `deepseek-r1:7b` | DeepSeek R1 reasoning model |
| `gemma3:1b` | Google Gemma 3 (1B) |
| `gemma3:4b` | Google Gemma 3 (4B) |
| `glm4:9b` | Zhipu GLM-4 |
| `llama3.2:1b` | Meta Llama 3.2 (1B) |
| `llama3.2:3b` | Meta Llama 3.2 (3B) |
| `llama3.3:70b` | Meta Llama 3.3 (70B) |
| `mistral:7b` | Mistral 7B |
| `mistral-nemo:12b` | Mistral Nemo 12B |
| `mixtral:8x7b` | Mistral MoE model |
| `nomic-embed-text` | Nomic text embeddings |
| `phi4:14b` | Microsoft Phi-4 (14B) |
| `phi4-mini:3.8b` | Microsoft Phi-4 Mini |
| `qwen2.5:0.5b` | Alibaba Qwen 2.5 (0.5B) |
| `qwen2.5:7b` | Alibaba Qwen 2.5 (7B) |
| `qwen2.5:14b` | Alibaba Qwen 2.5 (14B) |
| `qwen2.5-coder:7b` | Qwen 2.5 Coder (7B) |
| `qwen2.5-coder:14b` | Qwen 2.5 Coder (14B) |
| `smollm2:135m` | HuggingFace SmolLM2 (135M) |
| `smollm2:1.7b` | HuggingFace SmolLM2 (1.7B) |
| `starcoder2:3b` | BigCode StarCoder2 (3B) |
| `starcoder2:7b` | BigCode StarCoder2 (7B) |

---

## Adding or Removing Models

Edit the `MODELS` array near the top of `ollama-launch`. Keep it sorted alphabetically:

```bash
MODELS=(
  "codellama:7b"
  "my-custom-model:latest"   # ← add here, keep sorted
  "deepseek-coder:6.7b"
  ...
)
```

After editing, either run the script directly or reinstall it.

---

## How It Works

1. Checks that `ollama` is in your PATH (exits with a clear error if not)
2. Prints the header
3. If `fzf` is available: pipes the model list into fzf and waits for selection
4. If `fzf` is not available: prints a numbered menu and reads your input
5. Runs `ollama run <selected-model>` — replacing the shell process (`exec`)

Colors are detected via `[ -t 1 ]` and suppressed automatically when stdout is not a terminal.

---

## Contributing

PRs welcome. To add a model to the default list, edit the `MODELS` array in `ollama-launch` and open a PR. Keep the list alphabetical.

To report a bug or request a feature, open an issue at [github.com/quantanow/ollama-launcher/issues](https://github.com/quantanow/ollama-launcher/issues).

---

## License

MIT — see [LICENSE](./LICENSE).
