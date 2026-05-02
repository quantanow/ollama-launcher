# ollama-launch

A fast, polished CLI for picking and launching [Ollama](https://ollama.com) agents interactively. Pick an agent, pick a model, start chatting — no config, no fuss.

```
┌─────────────────────────────┐
│  ollama-launch  🦙           │
│  Pick an agent and model    │
└─────────────────────────────┘
```

Runs commands like:
```bash
ollama launch claude --model glm4:9b
ollama launch openclaw --model mistral:7b
```

## Features

- Two-step interactive picker: **agent** then **model**
- **fzf** fuzzy search UI (type to filter, arrows to navigate)
- Numbered menu fallback when fzf is not installed — works everywhere
- 5 agents and 24 curated popular models ready to go
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

### npm (recommended)

```bash
npm install -g ollama-launch
```

### One-liner (no npm)

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

### Local dev (no install)

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
ollama-launch [--help | --version | --list-agents | --list-models]
```

Run with no arguments to open the interactive picker:

```bash
ollama-launch
```

The picker runs in two steps: first pick an **agent**, then pick a **model**. The final command run will be:

```bash
ollama launch <agent> --model <model>
```

### With fzf installed

Step 1 — pick an agent:

```
  ↑↓ navigate  /  type to filter  /  Enter to select  /  Esc to quit
  Agent: _

  claude
  codex
  hermes
  openclaw
  opencode
```

Step 2 — pick a model:

```
  ↑↓ navigate  /  type to filter  /  Enter to run  /  Esc to quit
  Model: _

  codellama:7b
  deepseek-coder:6.7b
  ...
```

Type any part of a name to filter in real time. Press **Enter** to confirm, **Esc** or **Ctrl-C** to quit.

### Without fzf

Numbered menus are shown for each step:

```
Available agents:

   1  claude
   2  codex
   3  hermes
   4  openclaw
   5  opencode

Enter number [1-5]: _
```

Then the same for models. Invalid input re-prompts. Press **Ctrl-C** to quit at any point.

---

## Switches

| Switch | Short | Description |
|--------|-------|-------------|
| `--help` | `-h` | Show usage and exit |
| `--version` | `-v` | Print version string and exit |
| `--list-agents` | | Print all available agents, one per line, and exit |
| `--list-models` | | Print all available models, one per line, and exit |

### Examples

```bash
# Show help
ollama-launch --help

# Print version
ollama-launch --version
# → ollama-launch 1.0.0

# List all agents
ollama-launch --list-agents
# → claude
#   codex
#   hermes
#   openclaw
#   opencode

# List all models (pipe-friendly)
ollama-launch --list-models
# → codellama:7b
#   deepseek-coder:6.7b
#   ...

# Use with grep to check availability
ollama-launch --list-models | grep qwen
```

---

## Available Agents

| Agent | Command |
|-------|---------|
| `claude` | `ollama launch claude --model ...` |
| `codex` | `ollama launch codex --model ...` |
| `hermes` | `ollama launch hermes --model ...` |
| `openclaw` | `ollama launch openclaw --model ...` |
| `opencode` | `ollama launch opencode --model ...` |

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

## Adding or Removing Agents / Models

Edit the `AGENTS` or `MODELS` array near the top of `ollama-launch`. Keep each sorted alphabetically:

```bash
AGENTS=(
  "claude"
  "my-new-agent"   # ← add here, keep sorted
  ...
)

MODELS=(
  "codellama:7b"
  "my-custom-model:latest"   # ← add here, keep sorted
  ...
)
```

After editing, either run the script directly or reinstall it.

---

## How It Works

1. Checks that `ollama` is in your PATH (exits with a clear error if not)
2. Prints the header
3. **Step 1 — Agent:** fzf picker or numbered menu → you pick an agent
4. **Step 2 — Model:** fzf picker or numbered menu → you pick a model
5. Runs `ollama launch <agent> --model <model>` — replacing the shell process (`exec`)

Colors are detected via `[ -t 1 ]` and suppressed automatically when stdout is not a terminal.

---

## Contributing

PRs welcome. To add a model to the default list, edit the `MODELS` array in `ollama-launch` and open a PR. Keep the list alphabetical.

To report a bug or request a feature, open an issue at [github.com/quantanow/ollama-launcher/issues](https://github.com/quantanow/ollama-launcher/issues).

---

## License

MIT — see [LICENSE](./LICENSE).
