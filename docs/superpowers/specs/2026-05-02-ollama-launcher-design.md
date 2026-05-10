# ollama-launcher Design Spec
*Date: 2026-05-02 (updated 2026-05-10)*

## Overview

A suite of self-contained bash CLIs for working with Ollama. The flagship is `ollama-launch`: an interactive launcher that presents a three-step picker (agent → model → variant) with a recent-launches quick-pick, and runs `ollama launch <agent> --model <model>`. Eight companion tools cover cleanup, comparison, batch processing, benchmarking, chat management, Modelfile building, vision tasks, and pipeline chaining. Published as an npm package and installable via curl.

## Goals

- Zero-friction agent + model selection — one command, pick and go
- Dev-tool quality polish (colors, clean UX, clear errors)
- Easy open-source contribution (single-file scripts, no build step)
- Works anywhere bash runs; fzf enhances but is not required
- Installable via `npm install -g ollama-launch` or curl one-liner

## Non-Goals

- Model management (pull, delete, update) — handled by `ollama-clean`
- Configuration files or persistent preferences
- Non-interactive / scripted usage as primary mode (companion tools support some flags)
- Support for any runtime other than bash

---

## File Structure

```
ollama-launcher/
├── bin/
│   ├── ollama-launch       # interactive agent + model launcher
│   ├── ollama-clean        # interactive local model remover
│   ├── ollama-compare      # run same prompt across multiple models
│   ├── ollama-batch        # process directory of files through one model
│   ├── ollama-bench        # benchmark model inference speed
│   ├── ollama-chat         # persistent conversation manager
│   ├── ollama-modelfile    # interactive Modelfile builder
│   ├── ollama-vision       # vision-capable model picker
│   └── ollama-pipe         # multi-step model pipeline
├── models.json             # source of truth for model metadata
├── scripts/
│   ├── fetch-models.js     # scrapes ollama.com for top 100 models
│   └── generate-model-data.js  # regenerates embedded bash arrays
├── install.sh              # curl-pipeable one-liner installer
├── package.json            # npm package config
├── index.html              # GitHub Pages landing page
├── README.md
├── tests/                  # bats test suite (11 files)
├── .github/workflows/      # CI/CD (test + publish)
└── LICENSE                 # MIT
```

### Install methods

**npm (recommended):**
```bash
npm install -g ollama-launch
```

**One-liner:**
```bash
curl -fsSL https://raw.githubusercontent.com/quantanow/ollama-launcher/main/install.sh | bash
```

`install.sh` copies all 9 scripts to `/usr/local/bin/` and makes them executable. Uses `sudo` automatically if `/usr/local/bin` is not writable.

**Local dev (no install):**
```bash
git clone https://github.com/quantanow/ollama-launcher
cd ollama-launcher
./bin/ollama-launch
```

---

## Agent List

Hardcoded bash array inside `bin/ollama-launch`, sorted alphabetically:

```
claude
codex
hermes
openclaw
opencode
```

---

## Model List

JSON-derived, 100 popular models from the Ollama library. All models have full variant data (332 total variants). Embedded as parallel bash arrays at build time via `scripts/generate-model-data.js`.

Examples:
```
granite4.1          57.9K pulls    [tools]
mistral-medium-3.5  15.1K pulls    [vision, tools, thinking]
qwen3.6             1.1M pulls     [vision, tools, thinking]
```

---

## Selection UI

### Step 0: Recent quick-pick (conditional)

If `~/.ollama-launch-history` exists, shows last 5 `agent|model` combos above a separator, then all agents, in one popup:

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

- Select recent entry → skips steps 1–3, launches immediately
- Select agent → skips step 1, proceeds to model picker
- Cancel or separator → full 3-step flow

### Step 1: Pick Agent

5 agents in fzf or numbered menu.

### Step 2: Pick Model

Metadata-rich list: name, pulls, tags, input type. `cloud` appended to tags at display time for models with `:cloud` variants.

### Step 3: Pick Variant (conditional)

For models with 2+ variants:
```
granite4.1:3b   2.1GB   128K context   Text
granite4.1:8b   5.3GB   128K context   Text
granite4.1:30b  17GB    128K context   Text
```

0 variants → use base name. 1 variant → auto-select.

---

## Final Command

```bash
exec ollama launch <agent> --model <model>
```

A confirmation line is printed before launch:
```
Running: ollama launch claude --model granite4.1:8b
```

---

## Header

```
┌─────────────────────────────┐
│  ollama-launch  🦙           │
│  Pick an agent and model    │
└─────────────────────────────┘
```

---

## CLI Flags

| Flag | Short | Behavior |
|------|-------|----------|
| `--help` | `-h` | Print usage and exit 0 |
| `--version` | `-v` | Print version (read from `package.json`) and exit 0 |
| `--list-agents` | | Print all agents, one per line, and exit 0 |
| `--list-models` | | Print all 100 models, one per line, and exit 0 |
| `--list-models --cloud` | | Print only models with `:cloud` variant and exit 0 |
| `--print` | `-p` | Print the `ollama launch` command instead of executing it |

Unknown flags exit 1.

---

## Colors

ANSI colors used throughout. Auto-disabled when stdout is not a TTY (`[ -t 1 ]` check).

| Element | Style |
|---------|-------|
| Header border | Bold cyan |
| Header text | Bold white |
| Model/agent names | Bold bright cyan (fzf), white (menu) |
| Metadata | Dim |
| Prompt / numbers | Bold green |
| Errors | Bold red |

---

## Error Handling

| Condition | Behavior |
|-----------|----------|
| `ollama` not in PATH | Print error with install link, exit 1 |
| `fzf` not in PATH | Prompt to auto-install; continue with menu if declined |
| User cancels (Esc/Ctrl-C) | Exit cleanly, exit 0, no message |
| Invalid menu number | Re-prompt, do not exit |

---

## npm Package

`package.json` uses the `bin` field to register all 9 scripts as global binaries. The `files` field includes `bin/*` and `models.json`. Scripts read `VERSION` from `package.json` at runtime (checks `SCRIPT_DIR` then `SCRIPT_DIR/..` to resolve symlinks for npm global installs).

```json
{
  "name": "ollama-launch",
  "version": "1.1.14",
  "bin": {
    "ollama-launch": "bin/ollama-launch",
    "ollama-clean": "bin/ollama-clean",
    ...
  },
  "files": ["bin/*", "models.json"]
}
```

---

## Open Source Conventions

- MIT License
- README covers: what it is, install (npm + curl + manual + local dev), usage (fzf and fallback), switches, agents table, models table, companion tools, contributing
- Published to npm as `ollama-launch`
- Hosted at github.com/quantanow/ollama-launcher
