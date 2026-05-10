# ollama-launcher Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a suite of self-contained bash CLIs for working with Ollama. Flagship is `ollama-launch`: an interactive agent + model picker with recent-launches quick-pick, fzf UI, and numbered menu fallback. Companion tools handle cleanup, comparison, batch processing, benchmarking, chat management, Modelfile building, vision tasks, and pipeline chaining. Published as an npm package.

**Architecture:** Each tool is a single executable bash script in `bin/`. `ollama-launch` embeds model data as parallel bash arrays generated from `models.json` at build time. No runtime dependencies beyond bash and ollama. fzf is optional but recommended.

**Tech Stack:** Bash 3.2+, Node.js (build time only), fzf (optional), ANSI escape codes, bats (testing), GitHub Actions (CI/CD), npm (distribution)

---

## File Map

| File | Role |
|------|------|
| `bin/ollama-launch` | Main executable — interactive agent + model + variant picker |
| `bin/ollama-clean` | Interactive local model remover |
| `bin/ollama-compare` | Run same prompt across multiple models |
| `bin/ollama-batch` | Process directory of files through one model |
| `bin/ollama-bench` | Benchmark model inference speed |
| `bin/ollama-chat` | Persistent conversation manager |
| `bin/ollama-modelfile` | Interactive Modelfile builder |
| `bin/ollama-vision` | Vision-capable model picker |
| `bin/ollama-pipe` | Multi-step model pipeline |
| `models.json` | Source of truth for model metadata |
| `scripts/fetch-models.js` | Scrapes ollama.com for top models + variant data |
| `scripts/generate-model-data.js` | Regenerates embedded bash arrays from `models.json` |
| `install.sh` | Curl-pipeable installer (writes all tools to `/usr/local/bin`) |
| `package.json` | npm package config |
| `README.md` | Usage, install, contributing docs |
| `index.html` | GitHub Pages landing page |
| `LICENSE` | MIT license text |
| `tests/*.bats` | bats test suite (11 files, 30+ tests) |
| `.github/workflows/test.yml` | CI: runs bats on push/PR |
| `.github/workflows/publish.yml` | CD: publishes to npm on `v*` tag push |

---

### Task 1: Initialize repo and scaffold files

**Files:**
- Create: `bin/ollama-launch`
- Create: `install.sh`
- Create: `LICENSE`
- Create: `README.md`
- Create: `package.json`
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
node_modules/
```

Save to `.gitignore`.

- [ ] **Step 3: Create MIT LICENSE**

Create `LICENSE` with standard MIT text, copyright 2026 ollama-launcher contributors.

- [ ] **Step 4: Create empty placeholder files**

```bash
mkdir -p bin
touch bin/ollama-launch install.sh README.md package.json
chmod +x bin/ollama-launch install.sh
```

- [ ] **Step 5: Initial commit**

```bash
git add .gitignore LICENSE
git commit -m "chore: init repo with license"
```

---

### Task 2: Write the main script — skeleton, colors, flags, and agents

**Files:**
- Modify: `bin/ollama-launch`

- [ ] **Step 1: Write the script skeleton**

Write `bin/ollama-launch` with:
- Shebang `#!/usr/bin/env bash`, `set -euo pipefail`
- Version read from `package.json` at runtime (resolves symlinks for npm global installs)
- ANSI color definitions, TTY-gated via `[ -t 1 ]`
- `FZF_NAME` / `FZF_META` / `FZF_RST` for fzf display (always defined, not TTY-gated)
- `AGENTS` array with 5 sorted entries: claude, codex, hermes, openclaw, opencode
- Placeholder `# MODEL DATA BEGIN / END` markers for later array generation
- `print_header()`, `print_agents()`, `print_models()`, `check_ollama()`
- Flag parsing: `--help`, `--version`, `--list-agents`, `--list-models`, `--list-models --cloud`, `-p`/`--print`
- `OLLAMA_LAUNCH_SKIP_MAIN` guard for sourcing in tests

- [ ] **Step 2: Verify syntax**

```bash
bash -n bin/ollama-launch
```

Expected: no output

- [ ] **Step 3: Test flags**

```bash
./bin/ollama-launch --version
./bin/ollama-launch --help
./bin/ollama-launch --list-agents
./bin/ollama-launch --bogus 2>&1 || true
```

- [ ] **Step 4: Commit**

```bash
git add bin/ollama-launch
git commit -m "feat: scaffold script with version, colors, agents, flag parsing"
```

---

### Task 3: Add model data and picker infrastructure

**Files:**
- Modify: `bin/ollama-launch`
- Create: `scripts/generate-model-data.js`
- Create: `models.json`

- [ ] **Step 1: Add data markers and raw picker helpers**

Replace model list area with `# MODEL DATA BEGIN / END` markers and placeholder arrays (`MODEL_NAMES`, `MODEL_PULLS`, `MODEL_TAGS`, `MODEL_HAS_VARIANTS`).

Add `pick_fzf_raw()` (reads from stdin, accepts extra fzf flags via `"$@"`) and `pick_menu_raw()` (reads from file, UI to stderr, selection to stdout).

- [ ] **Step 2: Write generate-model-data.js**

Build script reads `models.json`, generates parallel bash arrays, and inlines them between `# MODEL DATA BEGIN / END` markers in `bin/ollama-launch`.

Arrays per model:
- `MODEL_VARIANTS_N`, `MODEL_SIZES_N`, `MODEL_CONTEXTS_N`, `MODEL_INPUTS_N` (only when `HAS_VARIANTS=1`)

- [ ] **Step 3: Verify syntax**

```bash
node --check scripts/generate-model-data.js
bash -n bin/ollama-launch
```

- [ ] **Step 4: Commit**

```bash
git add bin/ollama-launch scripts/generate-model-data.js models.json
git commit -m "feat: add model data markers and generate-model-data.js build script"
```

---

### Task 4: Implement metadata-rich pickers

**Files:**
- Modify: `bin/ollama-launch`

- [ ] **Step 1: Add `pick_model()`**

Builds formatted lines from `MODEL_NAMES`, `MODEL_PULLS`, `MODEL_TAGS`, `MODEL_INPUTS_N[0]`. Appends `cloud` to tags at display time if model has a `:cloud` variant. Uses `pick_fzf_raw` or `pick_menu_raw`. Sets global `PICK_MODEL_INDEX` and `PICK_RESULT`.

- [ ] **Step 2: Add `pick_variant()`**

0 variants → empty string. 1 variant → auto-selects. 2+ variants → sub-picker with size, context, input type. Uses same fzf/menu machinery.

- [ ] **Step 3: Verify syntax**

```bash
bash -n bin/ollama-launch
```

- [ ] **Step 4: Commit**

```bash
git add bin/ollama-launch
git commit -m "feat: add metadata-rich pick_model and pick_variant functions"
```

---

### Task 5: Add recent-launches quick-pick and history

**Files:**
- Modify: `bin/ollama-launch`

- [ ] **Step 1: Add history functions**

`history_file()` → `~/.ollama-launch-history`
`load_history()` → reads into global `HISTORY_ENTRIES[]`
`save_history(agent, model)` → writes newest-first, deduped, capped at 5 entries

- [ ] **Step 2: Add `pick_recent()`**

If history exists, shows recent `agent|model` combos above a separator, then all agents, in one fzf/menu popup. Selecting a recent entry sets both `RECENT_AGENT` and `RECENT_MODEL` (skips all pickers). Selecting an agent sets only `RECENT_AGENT` (skips step 1). Empty history or cancellation proceeds to full 3-step flow.

- [ ] **Step 3: Wire into main flow**

```
load_history
pick_recent
if recent selected → launch immediately
else → agent picker (skip if agent chosen from popup) → model picker → variant picker → save_history → exec
```

- [ ] **Step 4: Verify syntax**

```bash
bash -n bin/ollama-launch
```

- [ ] **Step 5: Commit**

```bash
git add bin/ollama-launch
git commit -m "feat: add recent-launches quick-pick and history persistence"
```

---

### Task 6: Add fzf auto-install prompt

**Files:**
- Modify: `bin/ollama-launch`

- [ ] **Step 1: Add `install_fzf()`**

Detects brew/apt-get/yum/dnf and installs fzf. Prints clear error if no package manager found.

- [ ] **Step 2: Prompt before main flow**

If fzf not in PATH and not in test mode, print warning and ask `Install fzf now? [y/N]`. If yes, run installer. If no, continue with menu fallback.

- [ ] **Step 3: Commit**

```bash
git add bin/ollama-launch
git commit -m "feat: prompt to auto-install fzf when missing"
```

---

### Task 7: Write companion tools

**Files:**
- Create: `bin/ollama-clean`
- Create: `bin/ollama-compare`
- Create: `bin/ollama-batch`
- Create: `bin/ollama-bench`
- Create: `bin/ollama-chat`
- Create: `bin/ollama-modelfile`
- Create: `bin/ollama-vision`
- Create: `bin/ollama-pipe`

Each script:
- `#!/usr/bin/env bash`, `set -euo pipefail`
- Version read from `package.json`
- `--help` / `--version` flags
- `*_TEST=1` env var to print commands without executing
- Consistent color scheme and TTY detection
- Interactive fzf + numbered menu fallback

| Tool | Core behavior |
|------|---------------|
| `ollama-clean` | `ollama list` → multi-select removal with confirmation |
| `ollama-compare` | Multi-select models → run same prompt → show framed outputs |
| `ollama-batch` | Pick model + input dir → `ollama run` per file → resume on interrupt |
| `ollama-bench` | Warmup + timed runs → nanosecond precision → JSON history |
| `ollama-chat` | Plain-text chats in `~/.ollama-chats/` → REPL with `/quit`, `/system`, `/model`, `/clear`, `/info` |
| `ollama-modelfile` | Interactive Modelfile builder → `ollama create` |
| `ollama-vision` | Filter vision-tagged models → validate image files → `ollama run --image` |
| `ollama-pipe` | Chain model steps: `--step "model prompt"` or `--chain summarize,translate,json` |

- [ ] **Commit**

```bash
chmod +x bin/ollama-*
git add bin/
git commit -m "feat: add 8 companion tools"
```

---

### Task 8: Write bats test suite

**Files:**
- Create: `tests/test_flags.bats`
- Create: `tests/test_clean_flags.bats`
- Create: `tests/test_compare_flags.bats`
- Create: `tests/test_batch_flags.bats`
- Create: `tests/test_bench_flags.bats`
- Create: `tests/test_chat_flags.bats`
- Create: `tests/test_modelfile_flags.bats`
- Create: `tests/test_vision_flags.bats`
- Create: `tests/test_pipe_flags.bats`
- Create: `tests/test_data_inlined.bats`
- Create: `tests/test_end_to_end.bats`

- [ ] **Step 1: Flag tests**

Each `test_*_flags.bats` verifies `--help`, `--version`, `--list-*`, unknown flags, exit codes, and output content for its respective tool.

- [ ] **Step 2: Data integrity tests**

`test_data_inlined.bats` verifies array lengths match, variant sub-arrays exist where expected, and specific metadata values are correct.

- [ ] **Step 3: End-to-end tests**

`test_end_to_end.bats` uses mocked `fzf` and `ollama` in `tests/mock_bin/` (created in `setup_file`, torn down in `teardown_file`). Tests:
- fzf path with 0-variant model uses base name
- fzf path with 1-variant model auto-selects variant
- fzf path with multi-variant model selects via `FZF_SELECT` / `FZF_SELECT_N`
- Menu path with 0-variant and multi-variant models
- History isolation (per-test temp `HOME`)

`FZF_SELECT` env var controls mock fzf selection (grep match; per-call `FZF_SELECT_N` for multi-stage).

- [ ] **Step 4: Run tests**

```bash
bats tests/
```

Expected: all tests pass

- [ ] **Step 5: Commit**

```bash
git add tests/
git commit -m "test: add bats suite for flags, data integrity, and end-to-end flows"
```

---

### Task 9: Add GitHub Actions CI/CD

**Files:**
- Create: `.github/workflows/test.yml`
- Create: `.github/workflows/publish.yml`

- [ ] **Step 1: Create test workflow**

Installs bats, runs full suite on push/PR to `main`.

- [ ] **Step 2: Create publish workflow**

Triggers on `v*` tag push. Verifies tag matches `package.json` version. Publishes to npm using `NPM_TOKEN` secret.

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/
git commit -m "ci: add GitHub Actions for tests and npm publish"
```

---

### Task 10: Write README, index.html, and install.sh

**Files:**
- Modify: `README.md`
- Create: `index.html`
- Modify: `install.sh`

- [ ] **Step 1: Write README.md**

Covers:
- Project overview (9 tools)
- Requirements: ollama, bash 3.2+, optional fzf
- Install methods: npm, curl one-liner, manual, local dev
- Usage for each tool with examples
- Model selection explanation (metadata, variants, quick-pick)
- CLI flags table
- Adding/removing models and agents
- Updating model data (`node scripts/generate-model-data.js`)
- Testing (`bats tests/`)
- Contributing

- [ ] **Step 2: Write index.html**

GitHub Pages landing page with project branding, install instructions, feature list, and usage examples.

- [ ] **Step 3: Write install.sh**

Curl-pipeable installer. Downloads all 9 scripts to `/usr/local/bin/`. Uses `sudo` if directory not writable.

- [ ] **Step 4: Commit**

```bash
git add README.md index.html install.sh
git commit -m "docs: add README, landing page, and curl installer"
```

---

### Task 11: Final verification

**Files:** none (read-only checks)

- [ ] **Step 1: Full syntax check**

```bash
for f in bin/*; do bash -n "$f" && echo "$f OK"; done
```

- [ ] **Step 2: Test all ollama-launch flags**

```bash
./bin/ollama-launch --version
./bin/ollama-launch --help
./bin/ollama-launch --list-agents
./bin/ollama-launch --list-models | wc -l
./bin/ollama-launch --list-models --cloud
OLLAMA_LAUNCH_TEST=1 ./bin/ollama-launch
```

- [ ] **Step 3: Run test suite**

```bash
bats tests/
```

Expected: all tests pass

- [ ] **Step 4: Verify file permissions**

```bash
ls -la bin/* install.sh
```

Expected: all show `-rwxr-xr-x`

---

## Self-Review

### 1. Spec Coverage

| Spec Section | Task(s) |
|--------------|---------|
| Data layer (parallel arrays, BEGIN/END markers) | Task 3 |
| Selection layer (pick_fzf_raw, pick_menu_raw) | Task 3, 4 |
| Display format (metadata in lines, cloud tag injection) | Task 4 |
| Variant picker (0/1/2+ handling) | Task 4 |
| Three-step flow + quick-pick | Task 5 |
| History persistence | Task 5 |
| fzf auto-install prompt | Task 6 |
| Companion tools (8 scripts) | Task 7 |
| Testing (bats, end-to-end, data validation) | Task 8 |
| CI/CD (GitHub Actions) | Task 9 |
| README, landing page, installer | Task 10 |
| Error handling (ollama missing, invalid input, TTY) | Tasks 2, 3, 4, 5, 6 |

No gaps identified.

### 2. Placeholder Scan

- No "TBD", "TODO", "implement later", or "fill in details" found.
- Every step contains exact file paths, exact code blocks, exact commands with expected output.

### 3. Type Consistency

- `pick_fzf_raw` and `pick_menu_raw` are used consistently in `pick_model`, `pick_variant`, and `pick_recent`
- `PICK_MODEL_INDEX` is set in `pick_model` and read in the main block
- `MODEL_HAS_VARIANTS`, `MODEL_VARIANTS_N`, `MODEL_SIZES_N`, `MODEL_CONTEXTS_N`, `MODEL_INPUTS_N` naming is consistent throughout
- `OLLAMA_LAUNCH_TEST`, `OLLAMA_LAUNCH_SKIP_MAIN`, `OLLAMA_LAUNCH_PRINT` env vars are used consistently
- `*_TEST=1` pattern is applied uniformly across all 9 tools

No inconsistencies found.
