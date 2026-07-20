# Monorepo Packages Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Split the single `ollama-launch` npm package into 9 independently versioned scoped packages inside a single npm-workspaces monorepo, while keeping each package fully self-contained.

**Architecture:** Move each CLI tool into `packages/<name>/` with its own `package.json`, `bin/`, `tests/`, and `README.md`. Root becomes a private workspace host with Changesets for independent versioning. No runtime dependencies between packages.

**Tech Stack:** npm workspaces, @changesets/cli, bats, GitHub Actions

---

## File Structure

**New directories (9 packages):**
- `packages/ollama-launch/` — `bin/ollama-launch`, `models.json`, `scripts/`, `tests/`
- `packages/ollama-clean/` — `bin/ollama-clean`, `tests/`
- `packages/ollama-compare/` — `bin/ollama-compare`, `tests/`
- `packages/ollama-batch/` — `bin/ollama-batch`, `tests/`
- `packages/ollama-bench/` — `bin/ollama-bench`, `tests/`
- `packages/ollama-chat/` — `bin/ollama-chat`, `tests/`
- `packages/ollama-modelfile/` — `bin/ollama-modelfile`, `tests/`
- `packages/ollama-vision/` — `bin/ollama-vision`, `tests/`
- `packages/ollama-pipe/` — `bin/ollama-pipe`, `tests/`

**Files to create:**
- `packages/*/package.json` (9 files)
- `packages/*/README.md` (9 files, stubs)
- `.changeset/config.json`
- `.changeset/README.md`

**Files to modify:**
- `package.json` (root — convert to private workspace host)
- `.github/workflows/test.yml`
- `.github/workflows/publish.yml`
- `.github/workflows/update-models.yml`
- `install.sh`
- `README.md` (root — update install instructions)

**Files to move (not copy):**
- `bin/ollama-launch` → `packages/ollama-launch/bin/ollama-launch`
- `bin/ollama-clean` → `packages/ollama-clean/bin/ollama-clean`
- `bin/ollama-compare` → `packages/ollama-compare/bin/ollama-compare`
- `bin/ollama-batch` → `packages/ollama-batch/bin/ollama-batch`
- `bin/ollama-bench` → `packages/ollama-bench/bin/ollama-bench`
- `bin/ollama-chat` → `packages/ollama-chat/bin/ollama-chat`
- `bin/ollama-modelfile` → `packages/ollama-modelfile/bin/ollama-modelfile`
- `bin/ollama-vision` → `packages/ollama-vision/bin/ollama-vision`
- `bin/ollama-pipe` → `packages/ollama-pipe/bin/ollama-pipe`
- `models.json` → `packages/ollama-launch/models.json`
- `scripts/fetch-models.js` → `packages/ollama-launch/scripts/fetch-models.js`
- `scripts/generate-model-data.js` → `packages/ollama-launch/scripts/generate-model-data.js`
- `tests/test_flags.bats` → `packages/ollama-launch/tests/test_flags.bats`
- `tests/test_data_inlined.bats` → `packages/ollama-launch/tests/test_data_inlined.bats`
- `tests/test_end_to_end.bats` → `packages/ollama-launch/tests/test_end_to_end.bats`
- `tests/test_clean_flags.bats` → `packages/ollama-clean/tests/test_clean_flags.bats`
- `tests/test_compare_flags.bats` → `packages/ollama-compare/tests/test_compare_flags.bats`
- `tests/test_batch_flags.bats` → `packages/ollama-batch/tests/test_batch_flags.bats`
- `tests/test_bench_flags.bats` → `packages/ollama-bench/tests/test_bench_flags.bats`
- `tests/test_chat_flags.bats` → `packages/ollama-chat/tests/test_chat_flags.bats`
- `tests/test_modelfile_flags.bats` → `packages/ollama-modelfile/tests/test_modelfile_flags.bats`
- `tests/test_vision_flags.bats` → `packages/ollama-vision/tests/test_vision_flags.bats`
- `tests/test_pipe_flags.bats` → `packages/ollama-pipe/tests/test_pipe_flags.bats`

---

### Task 1: Create Package Directories

**Files:**
- Create: `packages/ollama-launch/`, `packages/ollama-clean/`, `packages/ollama-compare/`, `packages/ollama-batch/`, `packages/ollama-bench/`, `packages/ollama-chat/`, `packages/ollama-modelfile/`, `packages/ollama-vision/`, `packages/ollama-pipe/`
- Create subdirectories: `packages/*/bin/`, `packages/*/tests/`, `packages/ollama-launch/scripts/`

- [ ] **Step 1: Create all directories**

Run:
```bash
mkdir -p packages/ollama-launch/bin packages/ollama-launch/tests packages/ollama-launch/scripts
mkdir -p packages/ollama-clean/bin packages/ollama-clean/tests
mkdir -p packages/ollama-compare/bin packages/ollama-compare/tests
mkdir -p packages/ollama-batch/bin packages/ollama-batch/tests
mkdir -p packages/ollama-bench/bin packages/ollama-bench/tests
mkdir -p packages/ollama-chat/bin packages/ollama-chat/tests
mkdir -p packages/ollama-modelfile/bin packages/ollama-modelfile/tests
mkdir -p packages/ollama-vision/bin packages/ollama-vision/tests
mkdir -p packages/ollama-pipe/bin packages/ollama-pipe/tests
```

Verify: `ls packages/` shows 9 directories.

- [ ] **Step 2: Commit**

```bash
git add packages/
git commit -m "chore: create packages directory structure"
```

---

### Task 2: Move ollama-launch Files

**Files:**
- Move: `bin/ollama-launch` → `packages/ollama-launch/bin/ollama-launch`
- Move: `models.json` → `packages/ollama-launch/models.json`
- Move: `scripts/fetch-models.js` → `packages/ollama-launch/scripts/fetch-models.js`
- Move: `scripts/generate-model-data.js` → `packages/ollama-launch/scripts/generate-model-data.js`
- Move: `tests/test_flags.bats` → `packages/ollama-launch/tests/test_flags.bats`
- Move: `tests/test_data_inlined.bats` → `packages/ollama-launch/tests/test_data_inlined.bats`
- Move: `tests/test_end_to_end.bats` → `packages/ollama-launch/tests/test_end_to_end.bats`

- [ ] **Step 1: Move files**

Run:
```bash
git mv bin/ollama-launch packages/ollama-launch/bin/ollama-launch
git mv models.json packages/ollama-launch/models.json
git mv scripts/fetch-models.js packages/ollama-launch/scripts/fetch-models.js
git mv scripts/generate-model-data.js packages/ollama-launch/scripts/generate-model-data.js
git mv tests/test_flags.bats packages/ollama-launch/tests/test_flags.bats
git mv tests/test_data_inlined.bats packages/ollama-launch/tests/test_data_inlined.bats
git mv tests/test_end_to_end.bats packages/ollama-launch/tests/test_end_to_end.bats
```

Verify: `ls packages/ollama-launch/` shows `bin/`, `models.json`, `scripts/`, `tests/`.

- [ ] **Step 2: Commit**

```bash
git commit -m "refactor: move ollama-launch into packages/ollama-launch"
```

---

### Task 3: Move Remaining Tools into Packages

**Files:**
- Move: `bin/ollama-clean` → `packages/ollama-clean/bin/ollama-clean`
- Move: `tests/test_clean_flags.bats` → `packages/ollama-clean/tests/test_clean_flags.bats`
- Move: `bin/ollama-compare` → `packages/ollama-compare/bin/ollama-compare`
- Move: `tests/test_compare_flags.bats` → `packages/ollama-compare/tests/test_compare_flags.bats`
- Move: `bin/ollama-batch` → `packages/ollama-batch/bin/ollama-batch`
- Move: `tests/test_batch_flags.bats` → `packages/ollama-batch/tests/test_batch_flags.bats`
- Move: `bin/ollama-bench` → `packages/ollama-bench/bin/ollama-bench`
- Move: `tests/test_bench_flags.bats` → `packages/ollama-bench/tests/test_bench_flags.bats`
- Move: `bin/ollama-chat` → `packages/ollama-chat/bin/ollama-chat`
- Move: `tests/test_chat_flags.bats` → `packages/ollama-chat/tests/test_chat_flags.bats`
- Move: `bin/ollama-modelfile` → `packages/ollama-modelfile/bin/ollama-modelfile`
- Move: `tests/test_modelfile_flags.bats` → `packages/ollama-modelfile/tests/test_modelfile_flags.bats`
- Move: `bin/ollama-vision` → `packages/ollama-vision/bin/ollama-vision`
- Move: `tests/test_vision_flags.bats` → `packages/ollama-vision/tests/test_vision_flags.bats`
- Move: `bin/ollama-pipe` → `packages/ollama-pipe/bin/ollama-pipe`
- Move: `tests/test_pipe_flags.bats` → `packages/ollama-pipe/tests/test_pipe_flags.bats`

- [ ] **Step 1: Move all remaining tools**

Run:
```bash
git mv bin/ollama-clean packages/ollama-clean/bin/ollama-clean
git mv tests/test_clean_flags.bats packages/ollama-clean/tests/test_clean_flags.bats
git mv bin/ollama-compare packages/ollama-compare/bin/ollama-compare
git mv tests/test_compare_flags.bats packages/ollama-compare/tests/test_compare_flags.bats
git mv bin/ollama-batch packages/ollama-batch/bin/ollama-batch
git mv tests/test_batch_flags.bats packages/ollama-batch/tests/test_batch_flags.bats
git mv bin/ollama-bench packages/ollama-bench/bin/ollama-bench
git mv tests/test_bench_flags.bats packages/ollama-bench/tests/test_bench_flags.bats
git mv bin/ollama-chat packages/ollama-chat/bin/ollama-chat
git mv tests/test_chat_flags.bats packages/ollama-chat/tests/test_chat_flags.bats
git mv bin/ollama-modelfile packages/ollama-modelfile/bin/ollama-modelfile
git mv tests/test_modelfile_flags.bats packages/ollama-modelfile/tests/test_modelfile_flags.bats
git mv bin/ollama-vision packages/ollama-vision/bin/ollama-vision
git mv tests/test_vision_flags.bats packages/ollama-vision/tests/test_vision_flags.bats
git mv bin/ollama-pipe packages/ollama-pipe/bin/ollama-pipe
git mv tests/test_pipe_flags.bats packages/ollama-pipe/tests/test_pipe_flags.bats
```

Verify: `ls bin/` is empty; `ls tests/` is empty.

- [ ] **Step 2: Commit**

```bash
git commit -m "refactor: move remaining tools into packages/"
```

---

### Task 4: Create Per-Package package.json Files

**Files:**
- Create: `packages/ollama-launch/package.json`
- Create: `packages/ollama-clean/package.json`
- Create: `packages/ollama-compare/package.json`
- Create: `packages/ollama-batch/package.json`
- Create: `packages/ollama-bench/package.json`
- Create: `packages/ollama-chat/package.json`
- Create: `packages/ollama-modelfile/package.json`
- Create: `packages/ollama-vision/package.json`
- Create: `packages/ollama-pipe/package.json`

- [ ] **Step 1: Write ollama-launch package.json**

Create `packages/ollama-launch/package.json`:
```json
{
  "name": "@quantanow/ollama-launch",
  "version": "1.1.18",
  "description": "A fast, polished CLI for picking and launching Ollama agents and models interactively",
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "git+https://github.com/quantanow/ollama-launcher.git",
    "directory": "packages/ollama-launch"
  },
  "homepage": "https://github.com/quantanow/ollama-launcher#readme",
  "bugs": {
    "url": "https://github.com/quantanow/ollama-launcher/issues"
  },
  "keywords": [
    "ollama",
    "llm",
    "cli",
    "launcher",
    "ai",
    "models"
  ],
  "bin": {
    "ollama-launch": "bin/ollama-launch"
  },
  "files": [
    "bin/ollama-launch",
    "models.json",
    "scripts/",
    "README.md"
  ],
  "scripts": {
    "test": "bats tests/"
  },
  "engines": {
    "node": ">=14"
  },
  "preferGlobal": true
}
```

- [ ] **Step 2: Write ollama-clean package.json**

Create `packages/ollama-clean/package.json`:
```json
{
  "name": "@quantanow/ollama-clean",
  "version": "1.1.18",
  "description": "Interactively remove local Ollama models",
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "git+https://github.com/quantanow/ollama-launcher.git",
    "directory": "packages/ollama-clean"
  },
  "bin": {
    "ollama-clean": "bin/ollama-clean"
  },
  "files": [
    "bin/ollama-clean",
    "README.md"
  ],
  "scripts": {
    "test": "bats tests/"
  },
  "engines": {
    "node": ">=14"
  },
  "preferGlobal": true
}
```

- [ ] **Step 3: Write ollama-compare package.json**

Create `packages/ollama-compare/package.json`:
```json
{
  "name": "@quantanow/ollama-compare",
  "version": "1.1.18",
  "description": "Run the same prompt across multiple Ollama models and compare outputs",
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "git+https://github.com/quantanow/ollama-launcher.git",
    "directory": "packages/ollama-compare"
  },
  "bin": {
    "ollama-compare": "bin/ollama-compare"
  },
  "files": [
    "bin/ollama-compare",
    "README.md"
  ],
  "scripts": {
    "test": "bats tests/"
  },
  "engines": {
    "node": ">=14"
  },
  "preferGlobal": true
}
```

- [ ] **Step 4: Write ollama-batch package.json**

Create `packages/ollama-batch/package.json`:
```json
{
  "name": "@quantanow/ollama-batch",
  "version": "1.1.18",
  "description": "Process a directory of text files through a single Ollama model",
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "git+https://github.com/quantanow/ollama-launcher.git",
    "directory": "packages/ollama-batch"
  },
  "bin": {
    "ollama-batch": "bin/ollama-batch"
  },
  "files": [
    "bin/ollama-batch",
    "README.md"
  ],
  "scripts": {
    "test": "bats tests/"
  },
  "engines": {
    "node": ">=14"
  },
  "preferGlobal": true
}
```

- [ ] **Step 5: Write ollama-bench package.json**

Create `packages/ollama-bench/package.json`:
```json
{
  "name": "@quantanow/ollama-bench",
  "version": "1.1.18",
  "description": "Benchmark Ollama model inference speed",
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "git+https://github.com/quantanow/ollama-launcher.git",
    "directory": "packages/ollama-bench"
  },
  "bin": {
    "ollama-bench": "bin/ollama-bench"
  },
  "files": [
    "bin/ollama-bench",
    "README.md"
  ],
  "scripts": {
    "test": "bats tests/"
  },
  "engines": {
    "node": ">=14"
  },
  "preferGlobal": true
}
```

- [ ] **Step 6: Write ollama-chat package.json**

Create `packages/ollama-chat/package.json`:
```json
{
  "name": "@quantanow/ollama-chat",
  "version": "1.1.18",
  "description": "Persistent conversation manager for Ollama",
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "git+https://github.com/quantanow/ollama-launcher.git",
    "directory": "packages/ollama-chat"
  },
  "bin": {
    "ollama-chat": "bin/ollama-chat"
  },
  "files": [
    "bin/ollama-chat",
    "README.md"
  ],
  "scripts": {
    "test": "bats tests/"
  },
  "engines": {
    "node": ">=14"
  },
  "preferGlobal": true
}
```

- [ ] **Step 7: Write ollama-modelfile package.json**

Create `packages/ollama-modelfile/package.json`:
```json
{
  "name": "@quantanow/ollama-modelfile",
  "version": "1.1.18",
  "description": "Interactive Modelfile builder for creating custom Ollama models",
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "git+https://github.com/quantanow/ollama-launcher.git",
    "directory": "packages/ollama-modelfile"
  },
  "bin": {
    "ollama-modelfile": "bin/ollama-modelfile"
  },
  "files": [
    "bin/ollama-modelfile",
    "README.md"
  ],
  "scripts": {
    "test": "bats tests/"
  },
  "engines": {
    "node": ">=14"
  },
  "preferGlobal": true
}
```

- [ ] **Step 8: Write ollama-vision package.json**

Create `packages/ollama-vision/package.json`:
```json
{
  "name": "@quantanow/ollama-vision",
  "version": "1.1.18",
  "description": "Vision-capable model picker for Ollama with image question support",
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "git+https://github.com/quantanow/ollama-launcher.git",
    "directory": "packages/ollama-vision"
  },
  "bin": {
    "ollama-vision": "bin/ollama-vision"
  },
  "files": [
    "bin/ollama-vision",
    "README.md"
  ],
  "scripts": {
    "test": "bats tests/"
  },
  "engines": {
    "node": ">=14"
  },
  "preferGlobal": true
}
```

- [ ] **Step 9: Write ollama-pipe package.json**

Create `packages/ollama-pipe/package.json`:
```json
{
  "name": "@quantanow/ollama-pipe",
  "version": "1.1.18",
  "description": "Chain Ollama model operations into multi-step pipelines",
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "git+https://github.com/quantanow/ollama-launcher.git",
    "directory": "packages/ollama-pipe"
  },
  "bin": {
    "ollama-pipe": "bin/ollama-pipe"
  },
  "files": [
    "bin/ollama-pipe",
    "README.md"
  ],
  "scripts": {
    "test": "bats tests/"
  },
  "engines": {
    "node": ">=14"
  },
  "preferGlobal": true
}
```

- [ ] **Step 10: Commit**

```bash
git add packages/*/package.json
git commit -m "chore: add package.json for each workspace package"
```

---

### Task 5: Create Per-Package README Stubs

**Files:**
- Create: `packages/*/README.md` (9 files)

- [ ] **Step 1: Write all 9 README stubs**

Create `packages/ollama-launch/README.md`:
```markdown
# @quantanow/ollama-launch

A fast, polished CLI for picking and launching Ollama agents and models interactively.

## Install

```bash
npm install -g @quantanow/ollama-launch
```

## Usage

```bash
ollama-launch
```

See the [main repository](https://github.com/quantanow/ollama-launcher) for full documentation.
```

Create `packages/ollama-clean/README.md`:
```markdown
# @quantanow/ollama-clean

Interactively remove local Ollama models.

## Install

```bash
npm install -g @quantanow/ollama-clean
```

## Usage

```bash
ollama-clean
```

See the [main repository](https://github.com/quantanow/ollama-launcher) for full documentation.
```

Create `packages/ollama-compare/README.md`:
```markdown
# @quantanow/ollama-compare

Run the same prompt across multiple Ollama models and compare outputs side-by-side.

## Install

```bash
npm install -g @quantanow/ollama-compare
```

## Usage

```bash
ollama-compare
```

See the [main repository](https://github.com/quantanow/ollama-launcher) for full documentation.
```

Create `packages/ollama-batch/README.md`:
```markdown
# @quantanow/ollama-batch

Process a directory of text files through a single Ollama model.

## Install

```bash
npm install -g @quantanow/ollama-batch
```

## Usage

```bash
ollama-batch
```

See the [main repository](https://github.com/quantanow/ollama-launcher) for full documentation.
```

Create `packages/ollama-bench/README.md`:
```markdown
# @quantanow/ollama-bench

Benchmark Ollama model inference speed.

## Install

```bash
npm install -g @quantanow/ollama-bench
```

## Usage

```bash
ollama-bench
```

See the [main repository](https://github.com/quantanow/ollama-launcher) for full documentation.
```

Create `packages/ollama-chat/README.md`:
```markdown
# @quantanow/ollama-chat

Persistent conversation manager for Ollama.

## Install

```bash
npm install -g @quantanow/ollama-chat
```

## Usage

```bash
ollama-chat
```

See the [main repository](https://github.com/quantanow/ollama-launcher) for full documentation.
```

Create `packages/ollama-modelfile/README.md`:
```markdown
# @quantanow/ollama-modelfile

Interactive Modelfile builder for creating custom Ollama models.

## Install

```bash
npm install -g @quantanow/ollama-modelfile
```

## Usage

```bash
ollama-modelfile
```

See the [main repository](https://github.com/quantanow/ollama-launcher) for full documentation.
```

Create `packages/ollama-vision/README.md`:
```markdown
# @quantanow/ollama-vision

Vision-capable model picker for Ollama with image question support.

## Install

```bash
npm install -g @quantanow/ollama-vision
```

## Usage

```bash
ollama-vision
```

See the [main repository](https://github.com/quantanow/ollama-launcher) for full documentation.
```

Create `packages/ollama-pipe/README.md`:
```markdown
# @quantanow/ollama-pipe

Chain Ollama model operations into multi-step pipelines.

## Install

```bash
npm install -g @quantanow/ollama-pipe
```

## Usage

```bash
ollama-pipe
```

See the [main repository](https://github.com/quantanow/ollama-launcher) for full documentation.
```

- [ ] **Step 2: Commit**

```bash
git add packages/*/README.md
git commit -m "docs: add per-package README stubs"
```

---

### Task 6: Update Root package.json

**Files:**
- Modify: `package.json`

- [ ] **Step 1: Rewrite root package.json**

Replace the entire content of `package.json`:
```json
{
  "name": "ollama-launcher",
  "private": true,
  "description": "Monorepo for ollama-launcher CLI tools",
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "git+https://github.com/quantanow/ollama-launcher.git"
  },
  "workspaces": [
    "packages/*"
  ],
  "scripts": {
    "test": "npm run test --workspaces",
    "changeset": "changeset",
    "version-packages": "changeset version"
  },
  "devDependencies": {
    "@changesets/cli": "^2.27.0"
  }
}
```

Verify: `cat package.json | grep workspaces` shows `"workspaces": ["packages/*"]`.

- [ ] **Step 2: Commit**

```bash
git add package.json
git commit -m "chore: convert root to private npm workspace host"
```

---

### Task 7: Set Up Changesets

**Files:**
- Create: `.changeset/config.json`
- Create: `.changeset/README.md`

- [ ] **Step 1: Create .changeset directory and config**

Run:
```bash
mkdir -p .changeset
```

Create `.changeset/config.json`:
```json
{
  "$schema": "https://unpkg.com/@changesets/config@3.0.0/schema.json",
  "changelog": "@changesets/cli/changelog",
  "commit": false,
  "fixed": [],
  "linked": [],
  "access": "public",
  "baseBranch": "main",
  "updateInternalDependencies": "patch",
  "ignore": []
}
```

Create `.changeset/README.md`:
```markdown
# Changesets

This directory contains changeset files generated by `npx changeset`.

Each changeset describes a package change and its bump type (patch, minor, major).
When changesets are consumed, packages are versioned and published independently.
```

Verify: `cat .changeset/config.json | grep access` shows `"access": "public"`.

- [ ] **Step 2: Commit**

```bash
git add .changeset/
git commit -m "chore: add changesets config for independent versioning"
```

---

### Task 8: Update CI Workflows

**Files:**
- Modify: `.github/workflows/test.yml`
- Modify: `.github/workflows/publish.yml`
- Modify: `.github/workflows/update-models.yml`

- [ ] **Step 1: Rewrite test.yml**

Replace `.github/workflows/test.yml`:
```yaml
name: Tests

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install dependencies
        run: npm ci

      - name: Install bats
        run: |
          git clone --depth 1 https://github.com/bats-core/bats-core.git /tmp/bats
          sudo /tmp/bats/install.sh /usr/local
          bats --version

      - name: Run workspace tests
        run: npm test
```

Verify: `cat .github/workflows/test.yml | grep "npm test"` shows `run: npm test`.

- [ ] **Step 2: Rewrite publish.yml**

Replace `.github/workflows/publish.yml`:
```yaml
name: Publish to npm

on:
  push:
    branches:
      - main

concurrency: ${{ github.workflow }}-${{ github.ref }}

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          registry-url: 'https://registry.npmjs.org'

      - name: Install dependencies
        run: npm ci

      - name: Create Release Pull Request or Publish to npm
        id: changesets
        uses: changesets/action@v1
        with:
          publish: npx changeset publish
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
```

Verify: `cat .github/workflows/publish.yml | grep changesets/action` shows `uses: changesets/action@v1`.

- [ ] **Step 3: Rewrite update-models.yml**

Read the existing `.github/workflows/update-models.yml` first to preserve schedule and other settings. Then replace the job steps that reference paths.

Find the lines that reference `models.json`, `scripts/fetch-models.js`, or `scripts/generate-model-data.js` and prefix them with `packages/ollama-launch/`. For example:
- `node scripts/fetch-models.js` → `node packages/ollama-launch/scripts/fetch-models.js`
- `node scripts/generate-model-data.js` → `node packages/ollama-launch/scripts/generate-model-data.js`
- Any `git add models.json` → `git add packages/ollama-launch/models.json`
- Any `git add bin/ollama-launch` → `git add packages/ollama-launch/bin/ollama-launch`

Verify: `grep -n "packages/ollama-launch" .github/workflows/update-models.yml` shows updated paths.

- [ ] **Step 4: Commit**

```bash
git add .github/workflows/
git commit -m "ci: update workflows for npm workspaces and changesets"
```

---

### Task 9: Update install.sh

**Files:**
- Modify: `install.sh`

- [ ] **Step 1: Update install.sh path references**

Read `install.sh` to find lines like:
```bash
src="${REPO_URL}/bin/${tool}"
```

Replace with:
```bash
src="${REPO_URL}/packages/${tool}/bin/${tool}"
```

Also update the tool list if it enumerates tools manually — ensure all 9 tools are listed.

Verify: `grep -n "packages/" install.sh` shows the updated path pattern.

- [ ] **Step 2: Commit**

```bash
git add install.sh
git commit -m "chore: update install.sh for packages/ layout"
```

---

### Task 10: Update Root README

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Update install instructions**

Find the `npm install -g ollama-launch` section and replace with an install matrix showing all 9 scoped packages. Keep the curl installer section.

Replace:
```markdown
### npm (recommended)

```bash
npm install -g ollama-launch
```
```

With:
```markdown
### npm (recommended)

Install individual tools as needed:

```bash
npm install -g @quantanow/ollama-launch
npm install -g @quantanow/ollama-clean
npm install -g @quantanow/ollama-compare
npm install -g @quantanow/ollama-batch
npm install -g @quantanow/ollama-bench
npm install -g @quantanow/ollama-chat
npm install -g @quantanow/ollama-modelfile
npm install -g @quantanow/ollama-vision
npm install -g @quantanow/ollama-pipe
```

The original `ollama-launch` package is deprecated. Use `@quantanow/ollama-launch` instead.
```

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs: update root README with scoped package install instructions"
```

---

### Task 11: Clean Up Empty Directories

**Files:**
- Delete: `bin/` (should be empty after moves)
- Delete: `tests/` (should be empty after moves)
- Delete: `scripts/` (should be empty after moves)

- [ ] **Step 1: Verify directories are empty and remove them**

Run:
```bash
rmdir bin 2>/dev/null || true
rmdir tests 2>/dev/null || true
rmdir scripts 2>/dev/null || true
```

If any directory is not empty, stop and investigate. Nothing should remain in these directories.

Verify: `ls bin/ tests/ scripts/ 2>&1 | grep "No such file"` confirms they are gone.

- [ ] **Step 2: Commit**

```bash
git add -A
git commit -m "chore: remove empty bin, tests, and scripts directories"
```

---

### Task 12: Run Tests Locally

**Files:**
- Test: all `packages/*/tests/*.bats`

- [ ] **Step 1: Install root dependencies**

Run:
```bash
npm install
```

Expected: `@changesets/cli` installs into `node_modules/`. `npm ls @changesets/cli` shows it.

- [ ] **Step 2: Run workspace tests**

Run:
```bash
npm test
```

Expected: npm runs `bats tests/` in each workspace directory. All 30 tests should pass (9 flag suites + data inlined + end-to-end).

If tests fail with path errors, check that bats CWD is the package directory when run via `npm test --workspaces`. If paths are wrong, update the test scripts in each `package.json` to use `cd` or absolute paths. For example, change `"test": "bats tests/"` to `"test": "cd tests && bats ."` if needed. But the current `./bin/` references should work because `npm test` from the package directory makes `./bin/` resolve to `packages/<name>/bin/`.

- [ ] **Step 3: Verify ollama-launch specific tests**

Run:
```bash
cd packages/ollama-launch && bats tests/
```

Expected: all 30 tests pass (the ollama-launch package has the most tests).

- [ ] **Step 4: Commit (if no test changes needed)**

If tests pass without modifications, no commit needed. If test scripts needed adjustment, commit:

```bash
git add packages/*/package.json
git commit -m "fix: adjust test scripts for workspace paths"
```

---

### Task 13: Add Initial Changeset

**Files:**
- Create: `.changeset/*.md` (auto-generated)

- [ ] **Step 1: Generate changeset for all packages**

Run:
```bash
npx changeset
```

Interactive prompts:
- Select all 9 packages (use space to select, enter to confirm).
- Choose `patch` bump type for each.
- Enter summary: `refactor: split monorepo into independently versioned scoped packages`

Verify: `.changeset/` contains a new `.md` file with all 9 packages listed.

- [ ] **Step 2: Commit**

```bash
git add .changeset/
git commit -m "chore: add changeset for monorepo refactor"
```

---

### Task 14: Update CLAUDE.md

**Files:**
- Modify: `CLAUDE.md`

- [ ] **Step 1: Update key files table and paths**

Read `CLAUDE.md`. Update the Key Files table to reflect `packages/<name>/` paths. Update any command examples that reference `./bin/ollama-launch` or `scripts/` to use the new paths.

For example:
- `bin/ollama-launch` → `packages/ollama-launch/bin/ollama-launch`
- `models.json` → `packages/ollama-launch/models.json`
- `scripts/fetch-models.js` → `packages/ollama-launch/scripts/fetch-models.js`
- `bats tests/` → `npm test` (or `cd packages/ollama-launch && bats tests/`)

- [ ] **Step 2: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: update CLAUDE.md for monorepo layout"
```

---

### Task 15: Final Verification

**Files:**
- Verify: all moved files, all new configs

- [ ] **Step 1: Directory structure sanity check**

Run:
```bash
tree -L 3 packages/ || find packages -maxdepth 3 | sort
```

Expected: 9 package directories, each with `package.json`, `README.md`, `bin/`, `tests/`. `ollama-launch` also has `models.json` and `scripts/`.

- [ ] **Step 2: Git status check**

Run:
```bash
git status
```

Expected: working tree clean. No untracked files in old `bin/`, `tests/`, `scripts/` locations.

- [ ] **Step 3: Package.json validation**

Run:
```bash
npm pkg get workspaces
```

Expected: `["packages/*"]`.

Run:
```bash
cd packages/ollama-launch && npm pkg get name && cd ../..
```

Expected: `"@quantanow/ollama-launch"`.

- [ ] **Step 4: Run full test suite one more time**

Run:
```bash
npm test
```

Expected: all tests pass across all workspaces.

---

## Spec Coverage Check

| Spec Requirement | Plan Task |
|---|---|
| 9 packages in `packages/` with own `package.json` and `README.md` | Task 1, 2, 3, 4, 5 |
| Root `package.json` is private workspace host | Task 6 |
| `.changeset/config.json` with `access: public` | Task 7 |
| `test.yml` runs workspace tests | Task 8 Step 1 |
| `publish.yml` uses changesets/action@v1 | Task 8 Step 2 |
| `update-models.yml` paths updated | Task 8 Step 3 |
| Each package fully self-contained | Task 2, 3 (moves only own files) |
| Install paths for users documented | Task 10 |
| Old package deprecation noted | Task 10 |
| Backward compatibility (CLI unchanged) | Task 2, 3 (no script changes) |
| Bats tests pass after move | Task 12 |
| `install.sh` updated | Task 9 |
| CLAUDE.md updated | Task 14 |
| Initial changeset added | Task 13 |

## Placeholder Scan

- No "TBD", "TODO", "implement later", "fill in details" found.
- No vague error handling instructions.
- All package.json files contain complete content.
- All workflow files contain complete YAML.
- Exact paths provided for all moves.
- Exact commands with expected output for all verification steps.
