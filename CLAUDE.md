# ollama-launcher — CLAUDE.md

## Project Overview

Suite of bash script CLIs for working with Ollama. `ollama-launch` is the flagship: an interactive launcher for ollama agents and models. On each run it first offers a **recent-launches quick-pick** (last 5 agent+model combos from `~/.ollama-launch-history`); if the user picks a recent entry it skips all further steps, if they select an agent it proceeds to the model+variant pickers, and if there is no history it goes straight to the three-step flow: agent → model → variant. Ends with `exec ollama launch <agent> --model <model>`. `ollama-clean` removes local models interactively. `ollama-compare` runs the same prompt across multiple models and shows outputs side-by-side. `ollama-batch` processes a directory of text files through a single model. `ollama-bench` benchmarks model inference speed with warmup + timed runs. `ollama-chat` manages persistent conversation threads with forking and history. `ollama-modelfile` builds custom models interactively via Modelfile generation. Published to npm as `ollama-launch`.

## Key Files

| File | Purpose |
|------|---------|
| `packages/ollama-launch/bin/ollama-launch` | Interactive agent + model launcher |
| `packages/ollama-clean/bin/ollama-clean` | Interactive local model remover |
| `packages/ollama-compare/bin/ollama-compare` | Run same prompt across multiple models |
| `packages/ollama-batch/bin/ollama-batch` | Process directory of files through one model |
| `packages/ollama-bench/bin/ollama-bench` | Benchmark model inference speed |
| `packages/ollama-chat/bin/ollama-chat` | Persistent conversation manager |
| `packages/ollama-modelfile/bin/ollama-modelfile` | Interactive Modelfile builder |
| `packages/ollama-vision/bin/ollama-vision` | Vision-capable model picker with image question support |
| `packages/ollama-pipe/bin/ollama-pipe` | Multi-step model pipeline (chain operations) |
| `packages/ollama-launch/models.json` | Source of truth for model metadata |
| `packages/ollama-launch/scripts/fetch-models.js` | Scrapes ollama.com for top 100 models + variant data, writes `models.json` |
| `packages/ollama-launch/scripts/generate-model-data.js` | Regenerates embedded bash arrays in `bin/ollama-launch` from `models.json` |
| `install.sh` | Curl one-liner installer (writes all tools to `/usr/local/bin`) |
| `packages/ollama-launch/package.json` | npm package config (`ollama-launch` v1.1.18) |
| `index.html` | GitHub Pages site — usage and features landing page |
| `packages/*/tests/` | bats test suites (one per package) |
| `.github/workflows/test.yml` | CI: runs bats on push/PR to main |
| `.github/workflows/publish.yml` | CD: publishes to npm on `v*` tag push |
| `.github/workflows/update-models.yml` | Scheduled weekly model data refresh (Mon 06:00 UTC) |

## Development Commands

```bash
# Run the scripts locally
./packages/ollama-launch/bin/ollama-launch
./packages/ollama-clean/bin/ollama-clean
./packages/ollama-compare/bin/ollama-compare
./packages/ollama-batch/bin/ollama-batch
./packages/ollama-bench/bin/ollama-bench
./packages/ollama-chat/bin/ollama-chat
./packages/ollama-modelfile/bin/ollama-modelfile
./packages/ollama-vision/bin/ollama-vision
./packages/ollama-pipe/bin/ollama-pipe

# Dry-run (prints command instead of executing)
OLLAMA_LAUNCH_TEST=1 ./packages/ollama-launch/bin/ollama-launch
OLLAMA_CLEAN_TEST=1 ./packages/ollama-clean/bin/ollama-clean
OLLAMA_COMPARE_TEST=1 ./packages/ollama-compare/bin/ollama-compare
OLLAMA_BATCH_TEST=1 ./packages/ollama-batch/bin/ollama-batch
OLLAMA_BENCH_TEST=1 ./packages/ollama-bench/bin/ollama-bench
OLLAMA_CHAT_TEST=1 ./packages/ollama-chat/bin/ollama-chat
OLLAMA_MODELFILE_TEST=1 ./packages/ollama-modelfile/bin/ollama-modelfile
OLLAMA_VISION_TEST=1 ./packages/ollama-vision/bin/ollama-vision
OLLAMA_PIPE_TEST=1 ./packages/ollama-pipe/bin/ollama-pipe

# Source without running main (for unit testing)
OLLAMA_LAUNCH_SKIP_MAIN=1 source ./packages/ollama-launch/bin/ollama-launch

# Run tests for all packages
npm test

# Run tests for a single package
cd packages/ollama-launch && bats tests/

# Regenerate embedded model data after editing models.json
cd packages/ollama-launch && node scripts/generate-model-data.js
```

## Architecture

The script is entirely self-contained. Model data is embedded as parallel bash arrays (no external files at runtime):

- `MODEL_NAMES[]` — base names (100 entries)
- `MODEL_PULLS[]` — pull counts
- `MODEL_TAGS[]` — capability tags (vision, tools, thinking, etc.)
- `MODEL_HAS_VARIANTS[]` — 1 if model has a sub-picker, 0 otherwise
- `MODEL_VARIANTS_N[]`, `MODEL_SIZES_N[]`, `MODEL_CONTEXTS_N[]`, `MODEL_INPUTS_N[]` — per-model variant data (only for models where `HAS_VARIANTS=1`)

All 100 models have full variant data (332 total variants across all models).

### History file

`~/.ollama-launch-history` — plain text, one `agent|model` pair per line, newest first, capped at 5 entries. Written by `save_history()` after every launch (including test/print mode). Read by `load_history()` into global `HISTORY_ENTRIES[]`.

### Picker flow

0. `load_history` + `pick_recent` → if history exists, shows recent entries above a separator then all agents in one fzf popup. Selecting a recent entry sets `RECENT_AGENT` + `RECENT_MODEL` (skips steps 1–3). Selecting an agent sets `RECENT_AGENT` only (skips step 1). Empty history skips this step entirely.
1. `pick_fzf` / `pick_menu` → agent selection (skipped if agent chosen in step 0)
2. `pick_model` → sets `PICK_RESULT` (model name) and `PICK_MODEL_INDEX`
3. `pick_variant` → if `MODEL_HAS_VARIANTS[$PICK_MODEL_INDEX] == 1`, shows sub-picker for 2+ variants; single-variant models auto-select without a menu
4. `save_history "$agent" "$final_model"` → write to `~/.ollama-launch-history`
5. `exec ollama launch <agent> --model <final_model>`

fzf is used when available; falls back to numbered menus (`pick_menu`, `pick_menu_raw`). ANSI colors are suppressed when stdout is not a TTY (`[ -t 1 ]`).

#### fzf display
- `pick_fzf_raw` accepts extra fzf flags via `"$@"` (shift 2 after label/header).
- Model/variant names are rendered in bold bright cyan (`FZF_NAME=$'\033[1;96m'`); metadata is dimmed (`FZF_META=$'\033[2m'`). These are always defined (not TTY-gated) because fzf reads from a pipe.
- Models with `:cloud` variants have `cloud` appended to their tags column at display time (not stored in `MODEL_TAGS[]`), so searching "cloud" in fzf finds them. Do not use `--with-nth` in the model picker — fzf ≥0.62 restricts search to displayed fields when `--with-nth` is set, breaking hidden-field search.
- After fzf returns, ANSI codes are stripped from the selected name before index lookup (`sed "s/${esc}\[[0-9;]*m//g"`).

## Agents

`claude`, `codex`, `hermes`, `openclaw`, `opencode` — keep sorted alphabetically in the `AGENTS` array.

## CLI Flags

| Flag | Description |
|------|-------------|
| `--help` / `-h` | Show usage and exit |
| `--version` / `-v` | Print version and exit |
| `-p` / `--print` | Print the ollama command instead of executing it |
| `--list-agents` | Print all agent names and exit |
| `--list-models` | Print all 100 model names and exit |
| `--list-models --cloud` | Print only models that have a `:cloud` variant and exit |

Unknown flags exit 1.

## ollama-clean

`packages/ollama-clean/bin/ollama-clean` — interactively remove local models.

- Runs `ollama list`, parses NAME and SIZE columns
- fzf multi-select (`--multi`, Tab to select multiple) or numbered menu with comma-separated input
- Shows models to remove, asks for confirmation, then runs `ollama rm <model>` for each
- Set `OLLAMA_CLEAN_TEST=1` to print commands without executing

## ollama-compare

`packages/ollama-compare/bin/ollama-compare` — run the same prompt across multiple local models and display outputs side-by-side.

- Select models via fzf multi-select or numbered menu (needs at least 2)
- Prompt from `--prompt "text"`, piped stdin, or interactive input
- Runs `ollama run <model> "<prompt>"` sequentially (avoids GPU contention)
- Displays each model's output in a framed block
- Set `OLLAMA_COMPARE_TEST=1` to print commands and dummy output without executing

## ollama-batch

`packages/ollama-batch/bin/ollama-batch` — process a directory of text files through a single model.

- Pick model interactively or via `--model <name>`
- Input directory via `--dir <path>` or interactive prompt
- File pattern via `--pattern <glob>` (default `*.txt`)
- Output directory via `--out <path>` (default `<input_dir>_out/`)
- Skips files that already have non-empty output (resume on interrupt)
- Runs `ollama run <model> "$(cat <file>)"` for each file
- Set `OLLAMA_BATCH_TEST=1` to print commands without executing

## ollama-bench

`packages/ollama-bench/bin/ollama-bench` — benchmark model inference speed.

- Pick model interactively or via `--model <name>`
- Custom prompt via `--prompt <text>` (default: built-in story prompt)
- Multiple runs via `--runs <n>` (default: 1, averaged)
- Warmup run before timing (to load model into memory)
- Measures wall-clock time with nanosecond precision
- Results stored in `~/.ollama-bench-history` as JSON lines
- View history with `--history`
- Set `OLLAMA_BENCH_TEST=1` to print commands and fake timings without executing

## ollama-chat

`packages/ollama-chat/bin/ollama-chat` — persistent conversation manager.

- Chats stored as plain text in `~/.ollama-chats/<name>.txt`
- Each chat has a model and optional system prompt
- `ollama-chat` (no args) → list chats, pick one to resume
- `ollama-chat --new` → create chat (prompts for name, model, system)
- `ollama-chat --resume <name>` → enter REPL with that chat's history
- `ollama-chat --fork <old> <new>` → copy chat
- `ollama-chat --delete <name>` → delete chat
- `ollama-chat --info <name>` → show metadata
- `ollama-chat --list` → list all chats
- REPL commands: `/quit`, `/system <text>`, `/model <name>`, `/clear`, `/info`
- Full conversation history is passed to `ollama run` on each turn (context window permitting)
- Set `OLLAMA_CHAT_TEST=1` to mock `ollama run` responses and read REPL input from stdin
- `CHAT_DIR` env var overrides the default `~/.ollama-chats` (used in tests)

## ollama-modelfile

`packages/ollama-modelfile/bin/ollama-modelfile` — interactive Modelfile builder for creating custom ollama models.

- Pick base model interactively or via `--from <model>`
- Set model name via `--name <name>` or interactive prompt
- System prompt via `--system <text>` or interactive prompt
- Temperature via `--temperature <n>` (default 0.7)
- Context length via `--num-ctx <n>` (default 4096)
- Top-p via `--top-p <n>` (optional)
- Preview Modelfile before confirming
- Runs `ollama create <name> -f <modelfile>`
- Set `OLLAMA_MODELFILE_TEST=1` to print command and Modelfile contents without executing

## ollama-vision

`packages/ollama-vision/bin/ollama-vision` — vision-capable model picker. Select a vision model, provide image file(s), ask a question, and get a response.

- Embedded vision model arrays filter only models tagged with `vision`
- Cross-references `ollama list` to highlight installed models
- Image path(s) via `--image <path>` (comma-separated for multiple) or interactive prompt
- Prompt via `--prompt <text>` or interactive prompt
- Model via `--model <name>` or interactive picker
- Validates that each image path is a regular file before running
- Runs `ollama run <model> "<prompt>" --image <img>...`
- Set `OLLAMA_VISION_TEST=1` to print the command without executing

## ollama-pipe

`packages/ollama-pipe/bin/ollama-pipe` — chain model operations into multi-step pipelines. Pipe text through a series of model instructions where the output of each step feeds into the next.

- Input from `--input <file>`, piped stdin, or interactive typing
- `--step "model prompt"` defines a custom pipeline step (repeatable)
- `--chain <name,name,...>` uses predefined prompts: `summarize`, `translate`, `json`, `polish`, `extract`
- `--model <name>` sets a default model for all steps (otherwise interactive per step)
- `--output <file>` writes final result to disk instead of stdout
- Runs sequentially: `ollama run <model> "<prompt>\n\n<previous_output>"`
- Set `OLLAMA_PIPE_TEST=1` to print commands without executing

## Refreshing Model Data

To pull a fresh top-100 list from ollama.com:

```bash
cd packages/ollama-launch && node scripts/fetch-models.js              # fetches 100 models, writes models.json
cd packages/ollama-launch && node scripts/fetch-models.js --dry-run    # preview without writing
cd packages/ollama-launch && node scripts/fetch-models.js --count 50  # fetch fewer models
cd packages/ollama-launch && node scripts/generate-model-data.js       # regenerate bash arrays from models.json
```

To add or edit a model manually:
1. Edit `packages/ollama-launch/models.json`
2. Run `cd packages/ollama-launch && node scripts/generate-model-data.js` — rewrites the `# MODEL DATA BEGIN … END` block in `packages/ollama-launch/bin/ollama-launch`
3. Commit the updated `packages/ollama-launch/bin/ollama-launch`

## Testing

Eleven bats files across `packages/*/tests/`:

| File | What it covers |
|------|---------------|
| `test_flags.bats` | All `ollama-launch` CLI flags (exit codes, output content) |
| `test_clean_flags.bats` | All `ollama-clean` CLI flags |
| `test_compare_flags.bats` | All `ollama-compare` CLI flags |
| `test_batch_flags.bats` | All `ollama-batch` CLI flags |
| `test_bench_flags.bats` | All `ollama-bench` CLI flags |
| `test_chat_flags.bats` | All `ollama-chat` CLI flags |
| `test_modelfile_flags.bats` | All `ollama-modelfile` CLI flags |
| `test_vision_flags.bats` | All `ollama-vision` CLI flags |
| `test_pipe_flags.bats` | All `ollama-pipe` CLI flags |
| `test_data_inlined.bats` | Array lengths, variant sub-array consistency, specific metadata values |
| `test_end_to_end.bats` | fzf and menu interactive flows, agent selection, variant selection, `check_ollama` error path |

End-to-end tests use a mock `fzf` and mock `ollama` in `packages/ollama-launch/tests/mock_bin/` (created/torn down by `setup_file`/`teardown_file`). Set `FZF_SELECT=<substring>` to control which item the mock fzf selects (grep match; falls back to first line). `setup()` overrides `HOME` to a per-file temp dir and clears `~/.ollama-launch-history` before each test to isolate history state.

## Publishing to npm

Requires an npm **Granular Access Token** with **Bypass 2FA enabled**, stored as a GitHub secret named `NPM_TOKEN`. Classic tokens with 2FA will fail with `EOTP`. Publish by bumping version (which creates a tag) and pushing:

```bash
cd packages/ollama-launch && npm version patch -m "chore: bump version to %s"
git push origin main
git push origin v1.x.x
```

The CI workflow verifies the tag matches `package.json` version before publishing.

**Token setup:**
1. https://www.npmjs.com/settings/YOUR_USERNAME/tokens → "Granular Access Token"
2. Permissions: Read and write, package: `ollama-launch`, Bypass 2FA: enabled
3. Update GitHub secret: https://github.com/quantanow/ollama-launcher/settings/secrets/actions

**Note:** Both scripts read `VERSION` from `package.json` at runtime, checking `SCRIPT_DIR` then `SCRIPT_DIR/..` (resolves symlinks so it works under `npm install -g`). Do not hardcode the version string in either script.

## Bash Compatibility

Script targets bash 3.2+ (ships with macOS). Two key constraints:

1. `local` declarations must be separate from assignments — `local foo; foo=$(...)` not `local foo=$(...)`.
2. **Empty array + `set -u`**: In bash 3.2, `"${empty_array[@]}"` with `set -u` triggers "unbound variable". Guard any loop over a potentially-empty array: `if [ "${#arr[@]}" -gt 0 ]; then for x in "${arr[@]}"; do ...`
