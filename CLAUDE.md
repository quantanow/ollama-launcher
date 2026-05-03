# ollama-launcher — CLAUDE.md

## Project Overview

Single bash script CLI (`ollama-launch`) that presents a three-step interactive picker — agent → model → variant — then runs `exec ollama launch <agent> --model <model>`. Published to npm as `ollama-launch`.

## Key Files

| File | Purpose |
|------|---------|
| `ollama-launch` | The entire CLI — one self-contained bash script |
| `models.json` | Source of truth for model metadata |
| `scripts/fetch-models.js` | Scrapes ollama.com for top 100 models + variant data, writes `models.json` |
| `scripts/generate-model-data.js` | Regenerates embedded bash arrays in `ollama-launch` from `models.json` |
| `install.sh` | Curl one-liner installer (writes to `/usr/local/bin`) |
| `package.json` | npm package config (`ollama-launch` v1.1.1) |
| `tests/` | bats test suite |
| `.github/workflows/test.yml` | CI: runs bats on push/PR to main |
| `.github/workflows/publish.yml` | CD: publishes to npm on `v*` tag push |

## Development Commands

```bash
# Run the script locally
./ollama-launch

# Dry-run (prints command instead of executing)
OLLAMA_LAUNCH_TEST=1 ./ollama-launch

# Source without running main (for unit testing)
OLLAMA_LAUNCH_SKIP_MAIN=1 source ./ollama-launch

# Run tests
bats tests/

# Regenerate embedded model data after editing models.json
node scripts/generate-model-data.js
```

## Architecture

The script is entirely self-contained. Model data is embedded as parallel bash arrays (no external files at runtime):

- `MODEL_NAMES[]` — base names (100 entries)
- `MODEL_PULLS[]` — pull counts
- `MODEL_TAGS[]` — capability tags (vision, tools, thinking, etc.)
- `MODEL_HAS_VARIANTS[]` — 1 if model has a sub-picker, 0 otherwise
- `MODEL_VARIANTS_N[]`, `MODEL_SIZES_N[]`, `MODEL_CONTEXTS_N[]`, `MODEL_INPUTS_N[]` — per-model variant data (only for models where `HAS_VARIANTS=1`)

All 100 models have full variant data (332 total variants across all models).

### Picker flow

1. `pick_fzf` / `pick_menu` → agent selection
2. `pick_model` → sets `PICK_RESULT` (model name) and `PICK_MODEL_INDEX`
3. `pick_variant` → if `MODEL_HAS_VARIANTS[$PICK_MODEL_INDEX] == 1`, shows sub-picker for 2+ variants; single-variant models auto-select without a menu
4. `exec ollama launch <agent> --model <final_model>`

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
| `--list-agents` | Print all agent names and exit |
| `--list-models` | Print all 100 model names and exit |
| `--list-models --cloud` | Print only models that have a `:cloud` variant and exit |

Unknown flags exit 1.

## Refreshing Model Data

To pull a fresh top-100 list from ollama.com:

```bash
node scripts/fetch-models.js              # fetches 100 models, writes models.json
node scripts/fetch-models.js --dry-run    # preview without writing
node scripts/fetch-models.js --count 50  # fetch fewer models
node scripts/generate-model-data.js       # regenerate bash arrays from models.json
```

To add or edit a model manually:
1. Edit `models.json`
2. Run `node scripts/generate-model-data.js` — rewrites the `# MODEL DATA BEGIN … END` block in `ollama-launch`
3. Commit the updated `ollama-launch`

## Testing

Three bats files in `tests/`:

| File | What it covers |
|------|---------------|
| `test_flags.bats` | All CLI flags (exit codes, output content) |
| `test_data_inlined.bats` | Array lengths, variant sub-array consistency, specific metadata values |
| `test_end_to_end.bats` | fzf and menu interactive flows, agent selection, variant selection, `check_ollama` error path |

End-to-end tests use a mock `fzf` and mock `ollama` in `tests/mock_bin/` (created/torn down by `setup_file`/`teardown_file`). Use `FZF_SELECT_N` env vars to control which item fzf selects on call N.

## Publishing to npm

Requires an npm access token stored as a GitHub secret named `NPM_TOKEN`. Publish by tagging:

```bash
# Bump version in package.json first, then:
git tag v1.0.1
git push origin v1.0.1
```

The CI workflow verifies the tag matches `package.json` version before publishing.

## Bash Compatibility

Script targets bash 3.2+ (ships with macOS). Key constraint: `local` variable declarations must be on a separate line from assignments — `local foo; foo=$(...)` not `local foo=$(...)`.
