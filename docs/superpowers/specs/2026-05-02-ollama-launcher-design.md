# ollama-launcher Design Spec
*Date: 2026-05-02*

## Overview

A single self-contained bash script called `ollama-launch` that presents an interactive model picker and runs `ollama run <model>` with the selected model.

## Goals

- Zero-friction model selection — one command, pick and go
- Dev-tool quality polish (colors, clean UX, clear errors)
- Easy open-source contribution (single file, no build step)
- Works anywhere bash runs; fzf enhances but is not required

## Non-Goals

- Model management (pull, delete, update)
- Configuration files or persistent state
- Non-interactive / scripted usage
- Support for any runtime other than bash

---

## File Structure

```
ollama-launcher/
├── ollama-launch       # the script (chmod +x, no extension)
├── install.sh          # curl-pipeable one-liner installer
├── README.md
└── LICENSE             # MIT
```

Install via:
```bash
curl -fsSL https://raw.githubusercontent.com/<user>/ollama-launcher/main/install.sh | bash
```

`install.sh` copies `ollama-launch` to `/usr/local/bin/ollama-launch` and sets executable bit.

---

## Model List

Hardcoded bash array inside the script, sorted alphabetically. Curated list of popular models:

```
codellama:7b
deepseek-coder:6.7b
deepseek-r1:7b
gemma3:1b
gemma3:4b
glm4:9b
llama3.2:1b
llama3.2:3b
llama3.3:70b
mistral:7b
mistral-nemo:12b
mixtral:8x7b
nomic-embed-text
phi4:14b
phi4-mini:3.8b
qwen2.5:0.5b
qwen2.5:7b
qwen2.5:14b
qwen2.5-coder:7b
qwen2.5-coder:14b
smollm2:135m
smollm2:1.7b
starcoder2:3b
starcoder2:7b
```

---

## Selection UI

### With fzf (preferred)
- Detected via `command -v fzf`
- Model list piped to fzf with header
- On selection: immediately runs `ollama run <model>`
- On Escape/Ctrl-C: exits cleanly, exit code 0

### Without fzf (fallback)
- Prints numbered list of models
- Colored prompt, validates input, re-prompts on invalid entry
- On Ctrl-C: exits cleanly

---

## Header

```
┌─────────────────────────────┐
│  ollama-launch  🦙           │
│  Pick a model to run        │
└─────────────────────────────┘
```

---

## CLI Flags

| Flag        | Behavior                                    |
|-------------|---------------------------------------------|
| `--help`    | Print usage and exit 0                      |
| `--version` | Print version string (hardcoded) and exit 0 |
| `--list`    | Print all models, one per line, and exit 0  |

---

## Colors

ANSI colors, auto-disabled when stdout is not a TTY.

| Element       | Style     |
|---------------|-----------|
| Header border | Bold cyan |
| Header text   | Bold white|
| Model names   | White     |
| Prompt        | Bold green|
| Errors        | Bold red  |

---

## Error Handling

| Condition                 | Behavior                               |
|---------------------------|----------------------------------------|
| `ollama` not in PATH      | Print error with install link, exit 1  |
| User cancels (Esc/Ctrl-C) | Exit cleanly, exit 0, no message       |
| Invalid menu number       | Re-prompt, do not exit                 |

---

## Version

Hardcoded `VERSION="1.0.0"` at top of script. Bump manually on release.

## Open Source Conventions

- MIT License
- README covers: what it is, install, usage, adding models, contributing
