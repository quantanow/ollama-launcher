# ollama-launch

A fast, polished CLI for picking and launching [Ollama](https://ollama.com) agents interactively. Pick an agent, pick a model, pick a variant — start chatting. No config, no fuss.

```
┌─────────────────────────────┐
│  ollama-launch  🦙           │
│  Pick an agent and model    │
└─────────────────────────────┘
```

Runs commands like:
```bash
ollama launch claude --model granite4.1:8b
ollama launch openclaw --model mistral-medium-3.5:latest
```

## Features

- Three-step interactive picker: **agent** → **model** → **variant**
- **fzf** fuzzy search UI (type to filter, arrows to navigate)
- Numbered menu fallback when fzf is not installed — works everywhere
- 5 agents and 80 popular models from the Ollama library ready to go
- Metadata-rich model picker showing pulls, tags, and input type
- Variant picker for models with multiple sizes
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

The picker runs in three steps: first pick an **agent**, then pick a **model**, then pick a **variant**. The final command run will be:

```bash
ollama launch <agent> --model <model>:<variant>
```

### With fzf installed

**Step 1 — pick an agent:**

```
  ↑↓ navigate  /  type to filter  /  Enter to select  /  Esc to quit
  Agent: _

  claude
  codex
  hermes
  openclaw
  opencode
```

**Step 2 — pick a model:**

```
  ↑↓ navigate  /  type to filter  /  Enter to select  /  Esc to quit
  Model: _

  granite4.1          16K pulls    [tools]
  mistral-medium-3.5  4,261 pulls  [vision, tools, thinking]
  qwen3.6             736.2K pulls [vision, tools, thinking]
  ...
```

**Step 3 — pick a variant:**

```
  ↑↓ navigate  /  type to filter  /  Enter to run  /  Esc to quit
  Variant: _

  granite4.1:3b   2.1GB   128K context   Text
  granite4.1:8b   5.3GB   128K context   Text
  granite4.1:30b  17GB    128K context   Text
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

Then the same for models and variants. Invalid input re-prompts. Press **Ctrl-C** to quit at any point.

---

## Model Selection

The model picker displays rich metadata for each model:

- **Pull count** — how many times the model has been pulled from Ollama
- **Tags** — capabilities like `vision`, `tools`, `thinking`
- **Input type** — `Text`, `Text, Image`, etc.

Models with multiple size variants (e.g., `3b`, `8b`, `30b`) show a secondary variant picker after model selection. Models with a single variant skip this step and launch immediately.

Example display format:

```
granite4.1          16K pulls    [tools]
mistral-medium-3.5  4,261 pulls  [vision, tools, thinking]
qwen3.6             736.2K pulls [vision, tools, thinking]
```

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
# → granite4.1
#   mistral-medium-3.5
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

The default model list includes **80 popular models** from the Ollama library, with full metadata and variant information. A few examples:

| Model | Description |
|-------|-------------|
| `granite4.1` | IBM Granite 4.1 |
| `mistral-medium-3.5` | Mistral Medium 3.5 |
| `qwen3.6` | Qwen3.6 coding and thinking model |
| `deepseek-r1` | DeepSeek R1 reasoning model |
| `llama3.3` | Meta Llama 3.3 |
| `gemma3` | Google Gemma 3 |

See the full list with `ollama-launch --list-models`.

---

## Adding or Removing Models

Model data is stored in `models.json`. To update the embedded model arrays in `ollama-launch`, edit `models.json` and then run the build script:

```bash
node scripts/generate-model-data.js
```

Then commit the updated `ollama-launch`.

To add or remove agents, edit the `AGENTS` array near the top of `ollama-launch`. Keep the list sorted alphabetically:

```bash
AGENTS=(
  "claude"
  "my-new-agent"   # ← add here, keep sorted
  ...
)
```

After editing, either run the script directly or reinstall it.

---

## Updating Model Data

Model metadata is stored in `models.json`. To regenerate the embedded bash arrays in `ollama-launch`:

```bash
node scripts/generate-model-data.js
```

Then commit the updated `ollama-launch`.

---

## Testing

The test suite uses [bats](https://github.com/bats-core/bats-core):

```bash
bats tests/
```

Set `OLLAMA_LAUNCH_TEST=1` to print the command instead of executing it:

```bash
OLLAMA_LAUNCH_TEST=1 ./ollama-launch
```

---

## How It Works

1. Checks that `ollama` is in your PATH (exits with a clear error if not)
2. Prints the header
3. **Step 1 — Agent:** fzf picker or numbered menu → you pick an agent
4. **Step 2 — Model:** fzf picker or numbered menu → you pick a model
5. **Step 3 — Variant:** fzf picker or numbered menu → you pick a variant (skipped for single-variant models)
6. Runs `ollama launch <agent> --model <model>:<variant>` — replacing the shell process (`exec`)

Colors are detected via `[ -t 1 ]` and suppressed automatically when stdout is not a terminal.

---

## Contributing

PRs welcome. To add a model to the default list, edit `models.json` and run `node scripts/generate-model-data.js`, then open a PR.

To report a bug or request a feature, open an issue at [github.com/quantanow/ollama-launcher/issues](https://github.com/quantanow/ollama-launcher/issues).

---

## License

MIT — see [LICENSE](./LICENSE).
