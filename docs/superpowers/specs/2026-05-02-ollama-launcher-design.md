# ollama-launcher Design Spec
*Date: 2026-05-02 (updated)*

## Overview

A single self-contained bash script called `ollama-launch` that presents a two-step interactive picker (agent, then model) and runs `ollama launch <agent> --model <model>`. Published as an npm package and installable via curl.

## Goals

- Zero-friction agent + model selection — one command, pick and go
- Dev-tool quality polish (colors, clean UX, clear errors)
- Easy open-source contribution (single file, no build step)
- Works anywhere bash runs; fzf enhances but is not required
- Installable via `npm install -g ollama-launch` or curl one-liner

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
├── package.json        # npm package config
├── .npmignore          # excludes docs/, install.sh from npm bundle
├── README.md
└── LICENSE             # MIT
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

`install.sh` copies `ollama-launch` to `/usr/local/bin/ollama-launch` and sets executable bit.

---

## Agent List

Hardcoded bash array inside the script, sorted alphabetically:

```
claude
codex
hermes
openclaw
opencode
```

---

## Model List

Hardcoded bash array inside the script, sorted alphabetically. 24 popular models:

```
codellama:7b         deepseek-coder:6.7b   deepseek-r1:7b
gemma3:1b            gemma3:4b             glm4:9b
llama3.2:1b          llama3.2:3b           llama3.3:70b
mistral:7b           mistral-nemo:12b      mixtral:8x7b
nomic-embed-text     phi4:14b              phi4-mini:3.8b
qwen2.5:0.5b         qwen2.5:7b            qwen2.5:14b
qwen2.5-coder:7b     qwen2.5-coder:14b     smollm2:135m
smollm2:1.7b         starcoder2:3b         starcoder2:7b
```

---

## Selection UI — Two Steps

### Step 1: Pick Agent
### Step 2: Pick Model

Both steps use the same UI logic:

**With fzf (preferred):**
- Detected via `command -v fzf`
- List piped to fzf with header and prompt label per step
- On Escape/Ctrl-C: exits cleanly, exit code 0

**Without fzf (fallback):**
- Prints numbered list
- Colored prompt, validates input, re-prompts on invalid entry
- On Ctrl-C: exits cleanly

A helper function `pick_fzf` handles the fzf path; `pick_menu` handles the fallback. Both are called twice — once for agents, once for models.

---

## Final Command

```bash
exec ollama launch <agent> --model <model>
```

A confirmation line is printed before launch:
```
Running: ollama launch claude --model glm4:9b
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

| Flag             | Behavior                                      |
|------------------|-----------------------------------------------|
| `--help`         | Print usage and exit 0                        |
| `--version`      | Print version string (hardcoded) and exit 0   |
| `--list-agents`  | Print all agents, one per line, and exit 0    |
| `--list-models`  | Print all models, one per line, and exit 0    |

---

## Colors

ANSI colors used throughout. Auto-disabled when stdout is not a TTY (`[ -t 1 ]` check).

| Element          | Style        |
|------------------|--------------|
| Header border    | Bold cyan    |
| Header text      | Bold white   |
| Model/agent names| White        |
| Prompt / numbers | Bold green   |
| Errors           | Bold red     |

---

## Error Handling

| Condition                  | Behavior                                                   |
|----------------------------|------------------------------------------------------------|
| `ollama` not in PATH       | Print error with install link, exit 1                      |
| User cancels (Esc/Ctrl-C)  | Exit cleanly, exit 0, no message                           |
| Invalid menu number        | Re-prompt, do not exit                                     |

---

## npm Package

`package.json` uses the `bin` field to register `ollama-launch` as a global binary. The `files` field includes only `ollama-launch` (the script). `.npmignore` excludes `docs/` and `install.sh` from the published bundle.

```json
{
  "name": "ollama-launch",
  "bin": { "ollama-launch": "./ollama-launch" },
  "files": ["ollama-launch"]
}
```

---

## Version

Hardcoded `VERSION="1.0.0"` at top of script and mirrored in `package.json`. Bump both on release.

## Open Source Conventions

- MIT License
- README covers: what it is, install (npm + curl + manual), usage (fzf and fallback), switches, agents table, models table, contributing
- Published to npm as `ollama-launch`
- Hosted at github.com/quantanow/ollama-launcher
