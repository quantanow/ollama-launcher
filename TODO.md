# Project Todo List

## Bugs

- [x] **generate-model-data.js broken path** — `scriptPath = 'ollama-launch'` should be `'bin/ollama-launch'` (line 4). Causes ENOENT when running `node scripts/generate-model-data.js` from project root. Model data regeneration is non-functional.

## Improvements

- [x] **mktemp hardcoded /tmp/** — 10 occurrences across 7 scripts use `mktemp /tmp/ollama-*` or `mktemp -d /tmp/ollama-*` instead of bare `mktemp` (which respects `$TMPDIR` on macOS). Affected: ollama-launch, ollama-chat (2 of 3 uses), ollama-bench, ollama-compare (2 uses), ollama-clean, ollama-modelfile, ollama-vision. Only ollama-chat line 279 already used the portable pattern.

## Pending Tasks

- [ ] Commit all new tools and version bump

## Completed Tasks

- [x] Add GitHub Actions CI/CD to publish to npm — trigger on `v*` tag push; verify tag matches package.json, then `npm publish`
- [x] Restructure project to single package, multiple bins (`bin/` directory)
- [x] Build `ollama-clean` — interactive local model remover with fzf multi-select
- [x] Build `ollama-compare` — run same prompt across multiple models, side-by-side output
- [x] Build `ollama-batch` — process directory of text files through one model with resume
- [x] Build `ollama-bench` — benchmark model inference speed with warmup + timed runs
- [x] Build `ollama-chat` — persistent conversation manager with forking and history
- [x] Build `ollama-modelfile` — interactive Modelfile builder for custom models
- [x] Build `ollama-vision` — vision-capable model picker, select image(s), ask question, get response
- [x] Build `ollama-pipe` — model pipelines (chains: summarize → translate → json-format)
- [x] Update index.html landing page with new tools
