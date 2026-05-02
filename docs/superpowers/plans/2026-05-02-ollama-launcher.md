# ollama-launcher Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a single self-contained bash script `ollama-launch` that shows an interactive model picker (fzf or numbered menu) and runs `ollama run <model>`.

**Architecture:** One executable bash script containing the model list, color helpers, flag parsing, fzf path, and numbered-menu fallback. An `install.sh` copies the script to `/usr/local/bin`. No external dependencies beyond bash and optional fzf.

**Tech Stack:** Bash 3.2+, fzf (optional), ANSI escape codes, git

---

## File Map

| File | Role |
|------|------|
| `ollama-launch` | Main executable script |
| `install.sh` | Curl-pipeable installer |
| `README.md` | Usage, install, contributing docs |
| `LICENSE` | MIT license text |

---

### Task 1: Initialize repo and scaffold files

**Files:**
- Create: `ollama-launch`
- Create: `install.sh`
- Create: `LICENSE`
- Create: `README.md`
- Create: `.gitignore`

- [ ] **Step 1: Initialize git repo**

```bash
cd /Users/saleem/Documents/quantanow/ollama-launcher
git init
```

Expected: `Initialized empty Git repository in .../ollama-launcher/.git/`

- [ ] **Step 2: Create .gitignore**

```
.DS_Store
*.swp
```

Save to `.gitignore`.

- [ ] **Step 3: Create MIT LICENSE**

Create `LICENSE` with this content (replace `<year>` with 2026, `<name>` with the repo owner):

```
MIT License

Copyright (c) 2026 ollama-launcher contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

- [ ] **Step 4: Create empty placeholder files**

```bash
touch ollama-launch install.sh README.md
chmod +x ollama-launch install.sh
```

- [ ] **Step 5: Initial commit**

```bash
git add .gitignore LICENSE
git commit -m "chore: init repo with license"
```

---

### Task 2: Write the main script — skeleton, colors, and flags

**Files:**
- Modify: `ollama-launch`

- [ ] **Step 1: Write the script skeleton with shebang, version, color setup, and flag parsing**

Write `ollama-launch` with this full content:

```bash
#!/usr/bin/env bash
set -euo pipefail

VERSION="1.0.0"

# ── colors (disabled when stdout is not a TTY) ────────────────────────────────
if [ -t 1 ]; then
  BOLD='\033[1m'
  CYAN='\033[36m'
  WHITE='\033[37m'
  GREEN='\033[32m'
  RED='\033[31m'
  RESET='\033[0m'
else
  BOLD='' CYAN='' WHITE='' GREEN='' RED='' RESET=''
fi

BOLD_CYAN="${BOLD}${CYAN}"
BOLD_WHITE="${BOLD}${WHITE}"
BOLD_GREEN="${BOLD}${GREEN}"
BOLD_RED="${BOLD}${RED}"

# ── model list ────────────────────────────────────────────────────────────────
MODELS=(
  "codellama:7b"
  "deepseek-coder:6.7b"
  "deepseek-r1:7b"
  "gemma3:1b"
  "gemma3:4b"
  "glm4:9b"
  "llama3.2:1b"
  "llama3.2:3b"
  "llama3.3:70b"
  "mistral:7b"
  "mistral-nemo:12b"
  "mixtral:8x7b"
  "nomic-embed-text"
  "phi4:14b"
  "phi4-mini:3.8b"
  "qwen2.5:0.5b"
  "qwen2.5:7b"
  "qwen2.5:14b"
  "qwen2.5-coder:7b"
  "qwen2.5-coder:14b"
  "smollm2:135m"
  "smollm2:1.7b"
  "starcoder2:3b"
  "starcoder2:7b"
)

# ── helpers ───────────────────────────────────────────────────────────────────
print_header() {
  echo -e "${BOLD_CYAN}┌─────────────────────────────┐${RESET}"
  echo -e "${BOLD_CYAN}│${RESET}  ${BOLD_WHITE}ollama-launch  🦙${RESET}           ${BOLD_CYAN}│${RESET}"
  echo -e "${BOLD_CYAN}│${RESET}  ${WHITE}Pick a model to run${RESET}        ${BOLD_CYAN}│${RESET}"
  echo -e "${BOLD_CYAN}└─────────────────────────────┘${RESET}"
  echo
}

print_models() {
  for model in "${MODELS[@]}"; do
    echo "$model"
  done
}

check_ollama() {
  if ! command -v ollama &>/dev/null; then
    echo -e "${BOLD_RED}Error:${RESET} ollama is not installed or not in PATH."
    echo "  Install it at: https://ollama.com/download"
    exit 1
  fi
}

# ── flag parsing ──────────────────────────────────────────────────────────────
case "${1:-}" in
  --help|-h)
    echo "Usage: ollama-launch [--help] [--version] [--list]"
    echo
    echo "  (no args)   Show interactive model picker"
    echo "  --list      Print all available models and exit"
    echo "  --version   Print version and exit"
    echo "  --help      Show this help and exit"
    exit 0
    ;;
  --version|-v)
    echo "ollama-launch $VERSION"
    exit 0
    ;;
  --list)
    print_models
    exit 0
    ;;
  "")
    ;;
  *)
    echo -e "${BOLD_RED}Error:${RESET} Unknown option: ${1}"
    echo "Run 'ollama-launch --help' for usage."
    exit 1
    ;;
esac

# ── main ──────────────────────────────────────────────────────────────────────
check_ollama
print_header
```

- [ ] **Step 2: Verify syntax**

```bash
bash -n ollama-launch
```

Expected: no output (no syntax errors)

- [ ] **Step 3: Test flags**

```bash
./ollama-launch --version
./ollama-launch --help
./ollama-launch --list | head -5
./ollama-launch --bogus 2>&1 || true
```

Expected:
```
ollama-launch 1.0.0
Usage: ollama-launch [--help] [--version] [--list]
...
codellama:7b
deepseek-coder:6.7b
deepseek-r1:7b
...
Error: Unknown option: --bogus
```

- [ ] **Step 4: Commit**

```bash
git add ollama-launch
git commit -m "feat: scaffold script with version, colors, model list, flag parsing"
```

---

### Task 3: Add fzf selection path

**Files:**
- Modify: `ollama-launch`

- [ ] **Step 1: Append fzf selection function to `ollama-launch`**

Append after the `print_header` call at the bottom of the script:

```bash
# ── selection ─────────────────────────────────────────────────────────────────
if command -v fzf &>/dev/null; then
  selected=$(print_models | fzf \
    --height=40% \
    --layout=reverse \
    --border \
    --prompt="  Model: " \
    --header="  ↑↓ navigate  /  type to filter  /  Enter to run  /  Esc to quit" \
    --color="header:italic,border:cyan" \
    2>/dev/null || true)

  if [ -z "$selected" ]; then
    exit 0
  fi

  exec ollama run "$selected"
fi
```

- [ ] **Step 2: Verify syntax**

```bash
bash -n ollama-launch
```

Expected: no output

- [ ] **Step 3: Smoke test fzf path (if fzf is installed)**

```bash
command -v fzf && echo "fzf present — run './ollama-launch' manually to test picker" || echo "fzf not present, skip"
```

- [ ] **Step 4: Commit**

```bash
git add ollama-launch
git commit -m "feat: add fzf selection path"
```

---

### Task 4: Add numbered menu fallback

**Files:**
- Modify: `ollama-launch`

- [ ] **Step 1: Append numbered menu fallback after the fzf block**

Append to the bottom of `ollama-launch`:

```bash
# ── numbered menu fallback ────────────────────────────────────────────────────
echo -e "${BOLD_WHITE}Available models:${RESET}"
echo

total=${#MODELS[@]}
for i in "${!MODELS[@]}"; do
  printf "  ${BOLD_GREEN}%2d${RESET}  ${WHITE}%s${RESET}\n" "$((i + 1))" "${MODELS[$i]}"
done

echo
selected=""
while true; do
  printf "${BOLD_GREEN}Enter number [1-%d]:${RESET} " "$total"
  read -r choice 2>/dev/null || { echo; exit 0; }

  if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "$total" ]; then
    selected="${MODELS[$((choice - 1))]}"
    break
  fi

  echo -e "${BOLD_RED}Invalid choice.${RESET} Enter a number between 1 and ${total}."
done

echo
exec ollama run "$selected"
```

- [ ] **Step 2: Verify syntax**

```bash
bash -n ollama-launch
```

Expected: no output

- [ ] **Step 3: Test menu renders correctly (with ollama check bypassed)**

Temporarily verify the menu output by commenting out `check_ollama` and running with fzf absent. Or just syntax-check and trust the manual test below.

```bash
bash -n ollama-launch && echo "syntax OK"
```

- [ ] **Step 4: Commit**

```bash
git add ollama-launch
git commit -m "feat: add numbered menu fallback when fzf is not installed"
```

---

### Task 5: Write install.sh

**Files:**
- Modify: `install.sh`

- [ ] **Step 1: Write install.sh**

```bash
#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="ollama-launch"
REPO_URL="https://raw.githubusercontent.com/YOUR_USERNAME/ollama-launcher/main"

echo "Installing ${SCRIPT_NAME}..."

if ! curl -fsSL "${REPO_URL}/${SCRIPT_NAME}" -o "/tmp/${SCRIPT_NAME}"; then
  echo "Error: Failed to download ${SCRIPT_NAME}" >&2
  exit 1
fi

chmod +x "/tmp/${SCRIPT_NAME}"

if [ -w "$INSTALL_DIR" ]; then
  mv "/tmp/${SCRIPT_NAME}" "${INSTALL_DIR}/${SCRIPT_NAME}"
else
  sudo mv "/tmp/${SCRIPT_NAME}" "${INSTALL_DIR}/${SCRIPT_NAME}"
fi

echo "Installed to ${INSTALL_DIR}/${SCRIPT_NAME}"
echo "Run: ollama-launch"
```

- [ ] **Step 2: Verify syntax**

```bash
bash -n install.sh
```

Expected: no output

- [ ] **Step 3: Commit**

```bash
git add install.sh
git commit -m "feat: add curl-pipeable install.sh"
```

---

### Task 6: Write README.md

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Write README.md**

```markdown
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
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/ollama-launcher/main/install.sh | bash
```

**Manual:**
```bash
git clone https://github.com/YOUR_USERNAME/ollama-launcher
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
```

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs: add README with install, usage, and contributing guide"
```

---

### Task 7: Final verification

**Files:** none (read-only checks)

- [ ] **Step 1: Full syntax check**

```bash
bash -n ollama-launch && bash -n install.sh
echo "All syntax OK"
```

Expected: `All syntax OK`

- [ ] **Step 2: Test all flags**

```bash
./ollama-launch --version
./ollama-launch --help
./ollama-launch --list
./ollama-launch --bogus 2>&1 || true
```

Expected:
```
ollama-launch 1.0.0
Usage: ollama-launch ...
codellama:7b
deepseek-coder:6.7b
...
Error: Unknown option: --bogus
```

- [ ] **Step 3: Test ollama-not-found error**

Temporarily test with PATH cleared:

```bash
PATH="" ./ollama-launch 2>&1 || true
```

Expected:
```
Error: ollama is not installed or not in PATH.
  Install it at: https://ollama.com/download
```

- [ ] **Step 4: Verify file is executable and has no extension**

```bash
ls -la ollama-launch install.sh
```

Expected: both show `-rwxr-xr-x`

- [ ] **Step 5: Commit docs spec files**

```bash
git add docs/
git commit -m "docs: add design spec and implementation plan"
```
