# Monorepo Packages Refactor — Design Document

Date: 2026-05-24
Status: Draft (pending approval)

## Context

The `ollama-launcher` repository currently publishes a single npm package (`ollama-launch@1.1.18`) containing nine CLI tools as bundled binaries:

- `ollama-launch`, `ollama-clean`, `ollama-compare`, `ollama-batch`, `ollama-bench`, `ollama-chat`, `ollama-modelfile`, `ollama-vision`, `ollama-pipe`

Motivation to split into separate packages: smaller installs (A), independent versioning (B), better npm discoverability (C).

## Goals

- Each CLI tool becomes its own independently versioned npm package
- Single repository is preserved (monorepo)
- Every published package is fully self-contained at runtime (no cross-package runtime dependencies)
- Existing `bin/` names and global CLI commands remain unchanged
- Publishing workflow is automated and handles independent versioning correctly

## Non-Goals

- Extract shared libraries or core packages between tools (every package stays self-contained)
- Rename any CLI binaries or commands
- Support non-npm install methods (curl installer may be updated later, but not in this scope)

## Architecture

### Repository Layout

```
ollama-launcher/
├── .changeset/                          # changesets config + unreleased changeset files
│   ├── config.json
│   └── README.md
├── packages/
│   ├── ollama-launch/
│   │   ├── package.json
│   │   ├── README.md
│   │   ├── bin/ollama-launch
│   │   ├── models.json
│   │   ├── scripts/
│   │   │   ├── fetch-models.js
│   │   │   └── generate-model-data.js
│   │   └── tests/
│   │       ├── test_flags.bats
│   │       ├── test_data_inlined.bats
│   │       └── test_end_to_end.bats
│   ├── ollama-clean/
│   │   ├── package.json
│   │   ├── README.md
│   │   ├── bin/ollama-clean
│   │   └── tests/test_clean_flags.bats
│   ├── ollama-compare/
│   │   ├── package.json
│   │   ├── README.md
│   │   ├── bin/ollama-compare
│   │   └── tests/test_compare_flags.bats
│   ├── ollama-batch/
│   │   ├── package.json
│   │   ├── README.md
│   │   ├── bin/ollama-batch
│   │   └── tests/test_batch_flags.bats
│   ├── ollama-bench/
│   │   ├── package.json
│   │   ├── README.md
│   │   ├── bin/ollama-bench
│   │   └── tests/test_bench_flags.bats
│   ├── ollama-chat/
│   │   ├── package.json
│   │   ├── README.md
│   │   ├── bin/ollama-chat
│   │   └── tests/test_chat_flags.bats
│   ├── ollama-modelfile/
│   │   ├── package.json
│   │   ├── README.md
│   │   ├── bin/ollama-modelfile
│   │   └── tests/test_modelfile_flags.bats
│   ├── ollama-vision/
│   │   ├── package.json
│   │   ├── README.md
│   │   ├── bin/ollama-vision
│   │   └── tests/test_vision_flags.bats
│   └── ollama-pipe/
│       ├── package.json
│       ├── README.md
│       ├── bin/ollama-pipe
│       └── tests/test_pipe_flags.bats
├── .github/
│   └── workflows/
│       ├── test.yml                       # run tests for changed packages on PR/push
│       ├── publish.yml                    # changesets publish on merge to main
│       └── update-models.yml              # weekly model refresh (only touches ollama-launch)
├── package.json                           # root private workspace host
├── install.sh                             # curl installer (repo-wide, unchanged)
├── index.html                             # GitHub Pages landing page (repo-wide)
└── README.md                              # repo overview with install matrix
```

### Package Naming

All packages published under the `@quantanow/` scope:

| Package | Binary Name |
|---------|-------------|
| `@quantanow/ollama-launch` | `ollama-launch` |
| `@quantanow/ollama-clean` | `ollama-clean` |
| `@quantanow/ollama-compare` | `ollama-compare` |
| `@quantanow/ollama-batch` | `ollama-batch` |
| `@quantanow/ollama-bench` | `ollama-bench` |
| `@quantanow/ollama-chat` | `ollama-chat` |
| `@quantanow/ollama-modelfile` | `ollama-modelfile` |
| `@quantanow/ollama-vision` | `ollama-vision` |
| `@quantanow/ollama-pipe` | `ollama-pipe` |

`package.json` `name` field is scoped (`@quantanow/ollama-clean`). `bin` keys inside each package remain unscoped so `npm install -g` registers the familiar command name.

### Per-Package `package.json` Template

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
  "files": ["bin/", "README.md"],
  "engines": { "node": ">=14" },
  "preferGlobal": true
}
```

`ollama-launch` package additionally includes `models.json` and `scripts/` in its `files` array.

### Root `package.json`

```json
{
  "name": "ollama-launcher",
  "private": true,
  "workspaces": ["packages/*"],
  "scripts": {
    "test": "npm run test --workspaces",
    "version-packages": "changeset version"
  },
  "devDependencies": {
    "@changesets/cli": "^2.27.0"
  }
}
```

Root is `private: true` — never published to npm.

### Workspace Tool Decision

**Options considered:**

1. **npm workspaces** — built into npm ≥7, no extra tool. Simpler setup.
2. **pnpm workspaces** — faster install, better monorepo features, but adds pnpm dependency for contributors.
3. **Yarn workspaces** — stable but Yarn is an extra dependency.

**Decision:** Use **npm workspaces**. No extra tool to install. The project is pure bash/JS with simple cross-package needs. npm workspaces handles `npm install` at root + `npm run test --workspaces` correctly. Changesets CLI works with npm workspaces natively.

### Versioning with Changesets

`@changesets/cli` provides the exact workflow needed for independent versioning in a monorepo.

**Workflow:**

1. Developer edits one or more packages.
2. Run `npx changeset` (or `npm run changeset`). CLI interactively asks:
   - Which packages changed?
   - Bump type per package (`patch`, `minor`, `major`)?
3. Changesets writes a Markdown file to `.changeset/<random-id>.md` describing the change.
4. Developer commits the changeset file alongside code changes.
5. On merge to `main`, the Changesets GitHub app opens a "Version Packages" PR if unreleased changesets exist.
6. The Version PR bumps each affected package's version in its `package.json`, updates per-package `CHANGELOG.md`, deletes consumed changeset files, and creates git tags per package (`@quantanow/ollama-clean@1.1.19`).
7. Merging the Version PR triggers `publish.yml`, which runs `changeset publish` to publish only changed packages to npm.

**Key configuration** (`.changeset/config.json`):

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

`access: public` is required because scoped packages default to private on npm.

### CI/CD Updates

#### `test.yml`

Runs on push/PR to `main`. Uses `npm run test --workspaces` to run all package tests. Could optionally filter to only changed packages for speed, but the test suite is small (bats, fast) so full run is acceptable.

#### `publish.yml`

Replaces the existing tag-based publish workflow. Triggered on pushes to `main` (after Version PR merge). Uses the Changesets action:

```yaml
- uses: changesets/action@v1
  with:
    publish: npx changeset publish
  env:
    NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

`changeset publish` runs `npm publish` for each package whose version does not yet exist on npm. Because each package is self-contained, no `npm publish --workspace` or cross-package build order is needed.

#### `update-models.yml`

Weekly scheduled workflow. Still only updates `packages/ollama-launch/models.json` and runs `node scripts/generate-model-data.js` inside that package. If model data changes, developer adds a changeset file (or the workflow could auto-generate one via `npx changeset --empty` + commit).

### Install Paths for Users

After publish, users can install individual tools:

```bash
npm install -g @quantanow/ollama-launch
npm install -g @quantanow/ollama-clean
# ... etc
```

Or use `npx` without installing:

```bash
npx @quantanow/ollama-launch
npx @quantanow/ollama-clean
```

The old `ollama-launch` package name on npm will be deprecated with a message pointing users to the scoped packages. This can be done manually after the first scoped publish:

```bash
npm deprecate ollama-launch "This package has been split into scoped packages. Install @quantanow/ollama-launch instead."
```

### Self-Contained Guarantee

Each package's `files` array includes only its own `bin/` and `README.md`. The `ollama-launch` package also includes `models.json` and `scripts/` inside its own directory. No package references files outside its directory. This satisfies the "fully self-contained" requirement.

### Bats Test Paths

Each package keeps its own `tests/` directory. Mock binaries and test helpers that were in `tests/mock_bin/` need to be replicated or moved to a shared test-helpers location. Decision: each package's test directory is self-contained. Common mock binaries (`mock_fzf`, `mock_ollama`) are copied into each package's `tests/mock_bin/` during test setup, or each package's `setup_file` creates them inline. Since the mocks are small bash scripts (~20 lines each), duplication is acceptable and keeps packages independent.

### History / State Files

The bash scripts reference `~/.ollama-launch-history`, `~/.ollama-bench-history`, `~/.ollama-chats/`. These remain in the user's home directory regardless of which package creates them. No change needed.

### Backward Compatibility

- CLI flags, behavior, and output of every script remain unchanged.
- Global binary names remain unchanged.
- The old `ollama-launch` npm package is deprecated (not deleted) so existing installs continue to work.

## Error Handling

- `changeset publish` skips packages already at that version on npm — idempotent, safe to re-run.
- If a publish fails (network, auth), the Version PR stays open and can be re-run.
- Scoped packages require `access: public` in config — missing this causes silent private-package publish failure. Config is validated in the spec.

## Testing Plan

- Move existing bats tests into per-package `tests/` directories.
- Update any hardcoded relative paths in tests (e.g., `../../bin/ollama-launch` becomes `../bin/ollama-launch` inside the package).
- Root `npm test` runs all workspace tests.
- CI verifies the full test suite still passes after the move.

## Open Questions (resolved)

- **Workspace tool?** npm workspaces (simplest, no extra dependency).
- **Package scope?** `@quantanow/` to avoid npm name collisions and brand consistency.
- **Shared code between packages?** None — each package is fully self-contained per user requirement.
- **Old package deprecation?** Yes, after first scoped publish.

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Users confused by scoped package names | Deprecate old package with clear message; update root README with install matrix |
| Changesets setup is unfamiliar | Document the `npx changeset` workflow in root README; run it once manually to verify |
| npm scoped packages require `access: public` | Explicitly set in `.changeset/config.json` |
| Test paths break during move | Update relative paths in bats files; run full test suite before committing |
| `install.sh` still references old paths | Update `install.sh` to install scoped packages or defer to post-migration phase |

## Success Criteria

- [ ] All 9 packages exist in `packages/` with correct `package.json` and `README.md`
- [ ] Root `package.json` uses `workspaces: ["packages/*"]` and is `private: true`
- [ ] `.changeset/config.json` exists with `access: public`
- [ ] `test.yml` runs workspace tests and passes
- [ ] `publish.yml` uses `changesets/action@v1` and publishes on merge
- [ ] At least one scoped package is published to npm successfully
- [ ] Old `ollama-launch` package is deprecated on npm
- [ ] All bats tests pass after path updates

## Appendix: Package Version Starting Points

All packages start at `1.1.18` (current single-package version) to avoid confusion. Independent bumps happen from there.
