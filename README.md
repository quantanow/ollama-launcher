# ollama-launcher

A suite of fast, polished CLIs for working with [Ollama](https://ollama.com).

- **ollama-launch** — pick an agent, pick a model, pick a variant — start chatting
- **ollama-clean** — interactively remove local models to free disk space
- **ollama-compare** — run the same prompt across multiple models and compare outputs
- **ollama-batch** — process a directory of text files through a single model
- **ollama-bench** — benchmark model inference speed with warmup + timed runs
- **ollama-chat** — persistent conversation manager with forking and history
- **ollama-modelfile** — interactive Modelfile builder for custom models
- **ollama-vision** — vision-capable model picker, select image(s), ask question, get response
- **ollama-pipe** — chain model operations: pipe text through summarize → translate → json-format

No config, no fuss.

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
- **Recent-launches quick-pick** — jump straight to your last 5 agent+model combos
- **fzf** fuzzy search UI (type to filter, arrows to navigate)
- Numbered menu fallback when fzf is not installed — works everywhere
- 5 agents and 100 popular models from the Ollama library ready to go
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

This downloads all tools to `/usr/local/bin` and makes them executable. Uses `sudo` automatically if `/usr/local/bin` is not writable.

### Manual

```bash
git clone https://github.com/quantanow/ollama-launcher
cd ollama-launcher
cp bin/* /usr/local/bin/
```

### Local dev (no install)

```bash
git clone https://github.com/quantanow/ollama-launcher
cd ollama-launcher
./bin/ollama-launch
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
ollama-launch [--help | --version | --list-agents | --list-models] [-p]
```

Run with no arguments to open the interactive picker:

```bash
ollama-launch
```

If you have recent launches in `~/.ollama-launch-history`, a **quick-pick popup** appears first showing your last 5 agent+model combos. Selecting a recent entry skips all other steps and launches immediately. Selecting an agent from the popup proceeds straight to the model picker. If there is no history (or you cancel), the picker runs in three steps: first pick an **agent**, then pick a **model**, then pick a **variant**. The final command run will be:

```bash
ollama launch <agent> --model <model>:<variant>
```

### With fzf installed

When you have launch history, the first screen shows recent combos and agents together:

```
  ↑↓ navigate  /  Enter to select  /  Esc to quit
  Recent: _

  ──────────────────────────────────────
  claude            │  qwen3:14b
  codex             │  granite4.1:8b
  ──────────────────────────────────────
  claude
  codex
  hermes
  ...
```

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
| `--list-models --cloud` | | Print only models that have a `:cloud` variant and exit |
| `--print` | `-p` | Print the `ollama launch` command instead of executing it |

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

# List only cloud-hosted models
ollama-launch --list-models --cloud

# Print the command without running it
ollama-launch -p
# → ollama launch claude --model granite4.1:8b
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

The default model list includes **100 popular models** from the Ollama library, with full metadata and variant information. A few examples:

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

## ollama-clean

Interactively remove local models to free disk space.

```bash
ollama-clean
```

Shows all locally installed models with their sizes. Use **Tab** to multi-select in fzf, or enter comma-separated numbers in the menu fallback. Confirms before deleting.

Set `OLLAMA_CLEAN_TEST=1` to print the `ollama rm` commands without executing them.

## ollama-compare

Run the same prompt across multiple local models and compare outputs side-by-side.

```bash
# Interactive — pick models, enter prompt, see results
ollama-compare

# Pre-select models and prompt
ollama-compare --prompt "Explain recursion" --models llama3.1,mistral

# Pipe prompt from stdin
echo "Summarize this article" | ollama-compare --models llama3.1,qwen2.5
```

Select at least 2 models. Outputs are shown sequentially in framed blocks after all models finish running. Set `OLLAMA_COMPARE_TEST=1` to print commands without executing.

## ollama-batch

Process a directory of text files through a single model, saving outputs to matching filenames.

```bash
# Interactive — pick model, pick directory
ollama-batch

# Pre-select everything
ollama-batch --dir prompts/ --model llama3.1 --out results/

# Custom file pattern
ollama-batch --dir articles/ --pattern '*.md' --model qwen2.5 --out summaries/
```

Automatically resumes by skipping files that already have non-empty output in the output directory. Set `OLLAMA_BATCH_TEST=1` to print commands without executing.

## ollama-bench

Benchmark model inference speed with warmup + timed runs.

```bash
# Interactive — pick model, run benchmark
ollama-bench

# Pre-select model with multiple runs
ollama-bench --model llama3.1 --runs 3

# Custom prompt
ollama-bench --model qwen2.5 --prompt "Explain quantum computing in simple terms"

# View past results
ollama-bench --history
```

Performs a warmup inference first (to load the model into memory), then runs the benchmark prompt and measures wall-clock time. Results are stored in `~/.ollama-bench-history`. Set `OLLAMA_BENCH_TEST=1` to print commands without executing.

## ollama-chat

Persistent conversation manager. Each chat is stored as a plain text file in `~/.ollama-chats/` with model, system prompt, and full turn history.

```bash
# Interactive — list chats and resume one
ollama-chat

# Create a new chat
ollama-chat --new

# Resume a specific chat
ollama-chat --resume my-project

# Fork an existing chat
ollama-chat --fork my-project my-project-v2

# Show chat info
ollama-chat --info my-project

# List all chats
ollama-chat --list
```

Inside the REPL, type `/quit` to exit, `/system <text>` to change the system prompt, `/model <name>` to switch models, `/clear` to wipe history (keeping system prompt), and `/info` to show metadata. Set `OLLAMA_CHAT_TEST=1` to mock responses and read REPL input from stdin.

## ollama-modelfile

Interactive Modelfile builder for creating custom ollama models.

```bash
# Interactive — build a Modelfile step by step
ollama-modelfile

# Pre-select all parameters
ollama-modelfile --name mybot --from llama3.1 --system "You are helpful" --temperature 0.5 --num-ctx 8192
```

Preview the Modelfile before confirming. Then runs `ollama create <name> -f <modelfile>`. Set `OLLAMA_MODELFILE_TEST=1` to print the command and Modelfile contents without executing.

## ollama-vision

Vision-capable model picker. Select a vision model, provide image file(s), ask a question, and get a response.

```bash
# Interactive — pick model, enter image path(s), ask question
ollama-vision

# Pre-select everything
ollama-vision --model llava --image photo.jpg --prompt "Describe this image"

# Multiple images (comma-separated)
ollama-vision --model llava --image img1.jpg,img2.jpg --prompt "Compare these"
```

Only vision-tagged models are shown in the picker. Installed local models are highlighted. Set `OLLAMA_VISION_TEST=1` to print the command without executing.

## ollama-pipe

Chain model operations into multi-step pipelines. Pipe text through a series of model instructions — output of each step feeds into the next.

```bash
# One-step pipeline
ollama-pipe --input article.txt --step "llama3.1 Summarize this article"

# Multi-step chain with predefined prompts
ollama-pipe --input doc.txt --chain summarize,json --model qwen2.5

# Available chains: summarize, translate, json, polish, extract
```

Predefined chains expand into prompts (e.g. `--chain summarize,translate` runs "Summarize" then "Translate to French"). You can also define custom steps with `--step "model prompt"`. Set `OLLAMA_PIPE_TEST=1` to print commands without executing.

## Adding or Removing Models

Model data is stored in `models.json`. To update the embedded model arrays in `bin/ollama-launch`, edit `models.json` and then run the build script:

```bash
node scripts/generate-model-data.js
```

Then commit the updated `bin/ollama-launch`.

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
OLLAMA_LAUNCH_TEST=1 ./bin/ollama-launch
```

---

## How It Works

1. Checks that `ollama` is in your PATH (exits with a clear error if not)
2. Prints the header
3. **Step 0 — Recent quick-pick:** if history exists, shows recent agent+model combos alongside the full agent list. Selecting a recent entry skips all other steps.
4. **Step 1 — Agent:** fzf picker or numbered menu → you pick an agent
5. **Step 2 — Model:** fzf picker or numbered menu → you pick a model
6. **Step 3 — Variant:** fzf picker or numbered menu → you pick a variant (skipped for single-variant models)
7. Saves the agent+model combo to `~/.ollama-launch-history` (last 5 entries kept)
8. Runs `ollama launch <agent> --model <model>:<variant>` — replacing the shell process (`exec`)

Colors are detected via `[ -t 1 ]` and suppressed automatically when stdout is not a terminal.

---

## Contributing

PRs welcome. To add a model to the default list, edit `models.json` and run `node scripts/generate-model-data.js`, then open a PR.

To report a bug or request a feature, open an issue at [github.com/quantanow/ollama-launcher/issues](https://github.com/quantanow/ollama-launcher/issues).

---

## License

MIT — see [LICENSE](./LICENSE).
