#!/usr/bin/env bats

setup_file() {
  mkdir -p "$BATS_TEST_DIRNAME/mock_bin"
  mkdir -p "$BATS_TEST_DIRNAME/temp_home"

  cat > "$BATS_TEST_DIRNAME/mock_bin/fzf" <<'EOF'
#!/usr/bin/env bash
lines=$(cat)
if [ -n "${FZF_SELECT:-}" ]; then
  matched=$(echo "$lines" | grep -F "$FZF_SELECT" | head -n 1)
  if [ -n "$matched" ]; then
    echo "$matched"
  else
    echo "$lines" | head -n 1
  fi
else
  echo "$lines" | head -n 1
fi
EOF
  chmod +x "$BATS_TEST_DIRNAME/mock_bin/fzf"

  cat > "$BATS_TEST_DIRNAME/mock_bin/ollama" <<'EOF'
#!/usr/bin/env bash
echo "ollama $*"
EOF
  chmod +x "$BATS_TEST_DIRNAME/mock_bin/ollama"
}

setup() {
  export PATH="$BATS_TEST_DIRNAME/mock_bin:/usr/bin:/bin"
  export HOME="$BATS_TEST_DIRNAME/temp_home"
  rm -f "$HOME/.ollama-launch-history"
}

teardown_file() {
  rm -rf "$BATS_TEST_DIRNAME/mock_bin"
  rm -rf "$BATS_TEST_DIRNAME/temp_home"
}

@test "fzf path with 1-variant model auto-selects cloud variant" {
  export FZF_SELECT="deepseek-v4-flash"
  run bash -c 'OLLAMA_LAUNCH_TEST=1 ./bin/ollama-launch 2>&1'
  [ "$status" -eq 0 ]
  [[ "$output" == *"ollama launch claude --model deepseek-v4-flash:cloud"* ]]
}

@test "fzf path with 1-variant model auto-selects variant" {
  export FZF_SELECT="kimi-k2.6"
  run bash -c 'OLLAMA_LAUNCH_TEST=1 ./bin/ollama-launch 2>&1'
  [ "$status" -eq 0 ]
  [[ "$output" == *"ollama launch claude --model kimi-k2.6:cloud"* ]]
}

@test "fzf path with multi-variant model selects first by default" {
  export FZF_SELECT="qwen3.6"
  run bash -c 'OLLAMA_LAUNCH_TEST=1 ./bin/ollama-launch 2>&1'
  [ "$status" -eq 0 ]
  [[ "$output" == *"ollama launch claude --model qwen3.6:latest"* ]]
}

@test "menu path with 1-variant model auto-selects variant" {
  mv "$BATS_TEST_DIRNAME/mock_bin/fzf" "$BATS_TEST_DIRNAME/mock_bin/fzf.bak"
  # agent=1 (claude), model=24 (deepseek-v4-flash, 1 variant — no sub-menu)
  run bash -c 'echo -e "1\n24\n" | OLLAMA_LAUNCH_TEST=1 ./bin/ollama-launch 2>&1'
  mv "$BATS_TEST_DIRNAME/mock_bin/fzf.bak" "$BATS_TEST_DIRNAME/mock_bin/fzf"
  [ "$status" -eq 0 ]
  [[ "$output" == *"ollama launch claude --model deepseek-v4-flash:cloud"* ]]
}

@test "menu path with 3-variant model selects second variant" {
  mv "$BATS_TEST_DIRNAME/mock_bin/fzf" "$BATS_TEST_DIRNAME/mock_bin/fzf.bak"
  # agent=1 (claude), model=21 (granite4.1), variant=2 (granite4.1:8b)
  run bash -c 'echo -e "1\n21\n2\n" | OLLAMA_LAUNCH_TEST=1 ./bin/ollama-launch 2>&1'
  mv "$BATS_TEST_DIRNAME/mock_bin/fzf.bak" "$BATS_TEST_DIRNAME/mock_bin/fzf"
  [ "$status" -eq 0 ]
  [[ "$output" == *"ollama launch claude --model granite4.1:8b"* ]]
}

@test "fzf path selects non-first agent (codex)" {
  export FZF_SELECT="codex"
  run bash -c "FZF_SELECT=codex OLLAMA_LAUNCH_TEST=1 ./bin/ollama-launch 2>&1"
  [ "$status" -eq 0 ]
  [[ "$output" == *"ollama launch codex --model"* ]]
}

@test "fzf path with 2-variant model auto-selects first variant" {
  export FZF_SELECT="mistral-medium-3.5"
  run bash -c 'FZF_SELECT="mistral-medium-3.5" OLLAMA_LAUNCH_TEST=1 ./bin/ollama-launch 2>&1'
  [ "$status" -eq 0 ]
  [[ "$output" == *"ollama launch claude --model mistral-medium-3.5:latest"* ]]
}

@test "menu path with 1-variant model (kimi-k2.6) auto-selects variant" {
  mv "$BATS_TEST_DIRNAME/mock_bin/fzf" "$BATS_TEST_DIRNAME/mock_bin/fzf.bak"
  # agent=1 (claude), model=22 (kimi-k2.6, 1 variant — no sub-menu needed)
  run bash -c 'echo -e "1\n22\n" | OLLAMA_LAUNCH_TEST=1 ./bin/ollama-launch 2>&1'
  mv "$BATS_TEST_DIRNAME/mock_bin/fzf.bak" "$BATS_TEST_DIRNAME/mock_bin/fzf"
  [ "$status" -eq 0 ]
  [[ "$output" == *"ollama launch claude --model kimi-k2.6:cloud"* ]]
}

@test "-p flag prints command without executing" {
  export FZF_SELECT="deepseek-v4-flash"
  run bash -c './bin/ollama-launch -p 2>&1'
  [ "$status" -eq 0 ]
  [[ "$output" == *"ollama launch"* ]]
  [[ "$output" == *"deepseek-v4-flash"* ]]
}

@test "--print flag prints command without executing" {
  export FZF_SELECT="deepseek-v4-flash"
  run bash -c './bin/ollama-launch --print 2>&1'
  [ "$status" -eq 0 ]
  [[ "$output" == *"ollama launch"* ]]
  [[ "$output" == *"deepseek-v4-flash"* ]]
}

@test "exits with error when ollama not in PATH" {
  run bash -c 'PATH=/usr/bin:/bin OLLAMA_LAUNCH_TEST=1 ./bin/ollama-launch 2>&1'
  [ "$status" -eq 1 ]
  [[ "$output" == *"ollama is not installed"* ]]
}

# ── history tests ─────────────────────────────────────────────────────────────

@test "history file is written after a successful run" {
  export FZF_SELECT="deepseek-v4-flash"
  run bash -c 'OLLAMA_LAUNCH_TEST=1 ./bin/ollama-launch 2>&1'
  [ "$status" -eq 0 ]
  [ -f "$HOME/.ollama-launch-history" ]
  grep -q "claude|deepseek-v4-flash" "$HOME/.ollama-launch-history"
}

@test "recent picker selects a recent entry and skips 3-step flow" {
  printf 'claude|qwen3:14b\n' > "$HOME/.ollama-launch-history"
  export FZF_SELECT="qwen3:14b"
  run bash -c 'OLLAMA_LAUNCH_TEST=1 ./bin/ollama-launch 2>&1'
  [ "$status" -eq 0 ]
  [[ "$output" == *"ollama launch claude --model qwen3:14b"* ]]
}

@test "selecting an agent from recent popup proceeds to model picker (menu path)" {
  printf 'claude|qwen3:14b\n' > "$HOME/.ollama-launch-history"
  mv "$BATS_TEST_DIRNAME/mock_bin/fzf" "$BATS_TEST_DIRNAME/mock_bin/fzf.bak"
  # menu: 1=recent(claude|qwen3:14b), 2=separator, 3=claude(agent), 4=codex...
  # select 3 (claude agent), then model 24 (deepseek-v4-flash, 1 variant auto-select)
  run bash -c 'echo -e "3\n24\n" | OLLAMA_LAUNCH_TEST=1 ./bin/ollama-launch 2>&1'
  mv "$BATS_TEST_DIRNAME/mock_bin/fzf.bak" "$BATS_TEST_DIRNAME/mock_bin/fzf"
  [ "$status" -eq 0 ]
  [[ "$output" == *"ollama launch claude --model deepseek-v4-flash:cloud"* ]]
}

@test "history deduplicates repeated entries" {
  printf 'claude|qwen3:14b\nhermes|llama3.1:8b\n' > "$HOME/.ollama-launch-history"
  export FZF_SELECT="qwen3:14b"
  run bash -c 'OLLAMA_LAUNCH_TEST=1 ./bin/ollama-launch 2>&1'
  [ "$status" -eq 0 ]
  local count; count=$(grep -c "qwen3:14b" "$HOME/.ollama-launch-history")
  [ "$count" -eq 1 ]
  local top; top=$(head -n 1 "$HOME/.ollama-launch-history")
  [ "$top" = "claude|qwen3:14b" ]
}

@test "history keeps at most 5 entries" {
  printf 'fake1|x1\nfake2|x2\nfake3|x3\nfake4|x4\nfake5|x5\n' > "$HOME/.ollama-launch-history"
  mv "$BATS_TEST_DIRNAME/mock_bin/fzf" "$BATS_TEST_DIRNAME/mock_bin/fzf.bak"
  # menu: 1-5=fake recents, 6=separator, 7=claude(agent); then model 1 (glm-5.2, 1 variant auto-select)
  run bash -c 'echo -e "7\n1\n" | OLLAMA_LAUNCH_TEST=1 ./bin/ollama-launch 2>&1'
  mv "$BATS_TEST_DIRNAME/mock_bin/fzf.bak" "$BATS_TEST_DIRNAME/mock_bin/fzf"
  [ "$status" -eq 0 ]
  local lines; lines=$(wc -l < "$HOME/.ollama-launch-history")
  [ "$lines" -eq 5 ]
  local top; top=$(head -n 1 "$HOME/.ollama-launch-history")
  [ "$top" = "claude|glm-5.2:cloud" ]
}
