#!/usr/bin/env bats

setup_file() {
  mkdir -p "$BATS_TEST_DIRNAME/mock_bin"

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
}

teardown_file() {
  rm -rf "$BATS_TEST_DIRNAME/mock_bin"
}

@test "fzf path with 0-variant model uses base name" {
  export FZF_SELECT="deepseek-v4-flash"
  run bash -c 'OLLAMA_LAUNCH_TEST=1 ./ollama-launch 2>&1'
  [ "$status" -eq 0 ]
  [[ "$output" == *"ollama launch claude --model deepseek-v4-flash"* ]]
}

@test "fzf path with 1-variant model auto-selects variant" {
  export FZF_SELECT="kimi-k2.6"
  run bash -c 'OLLAMA_LAUNCH_TEST=1 ./ollama-launch 2>&1'
  [ "$status" -eq 0 ]
  [[ "$output" == *"ollama launch claude --model kimi-k2.6:cloud"* ]]
}

@test "fzf path with 3-variant model selects first by default" {
  unset FZF_SELECT
  run bash -c 'OLLAMA_LAUNCH_TEST=1 ./ollama-launch 2>&1'
  [ "$status" -eq 0 ]
  [[ "$output" == *"ollama launch claude --model granite4.1:3b"* ]]
}

@test "menu path with 0-variant model" {
  mv "$BATS_TEST_DIRNAME/mock_bin/fzf" "$BATS_TEST_DIRNAME/mock_bin/fzf.bak"
  run bash -c 'echo -e "1\n7\n" | OLLAMA_LAUNCH_TEST=1 ./ollama-launch 2>&1'
  mv "$BATS_TEST_DIRNAME/mock_bin/fzf.bak" "$BATS_TEST_DIRNAME/mock_bin/fzf"
  [ "$status" -eq 0 ]
  [[ "$output" == *"ollama launch claude --model deepseek-v4-flash"* ]]
}

@test "menu path with 3-variant model selects second variant" {
  mv "$BATS_TEST_DIRNAME/mock_bin/fzf" "$BATS_TEST_DIRNAME/mock_bin/fzf.bak"
  run bash -c 'echo -e "1\n1\n2\n" | OLLAMA_LAUNCH_TEST=1 ./ollama-launch 2>&1'
  mv "$BATS_TEST_DIRNAME/mock_bin/fzf.bak" "$BATS_TEST_DIRNAME/mock_bin/fzf"
  [ "$status" -eq 0 ]
  [[ "$output" == *"ollama launch claude --model granite4.1:8b"* ]]
}

@test "fzf path selects non-first agent (codex)" {
  export FZF_SELECT="codex"
  run bash -c "FZF_SELECT=codex OLLAMA_LAUNCH_TEST=1 ./ollama-launch 2>&1"
  [ "$status" -eq 0 ]
  [[ "$output" == *"ollama launch codex --model"* ]]
}

@test "fzf path with 2-variant model auto-selects first variant" {
  export FZF_SELECT="mistral-medium-3.5"
  run bash -c 'FZF_SELECT="mistral-medium-3.5" OLLAMA_LAUNCH_TEST=1 ./ollama-launch 2>&1'
  [ "$status" -eq 0 ]
  [[ "$output" == *"ollama launch claude --model mistral-medium-3.5:latest"* ]]
}

@test "menu path with 1-variant model auto-selects variant" {
  mv "$BATS_TEST_DIRNAME/mock_bin/fzf" "$BATS_TEST_DIRNAME/mock_bin/fzf.bak"
  # agent=1 (claude), model=5 (kimi-k2.6, 1 variant — no sub-menu needed)
  run bash -c 'echo -e "1\n5\n" | OLLAMA_LAUNCH_TEST=1 ./ollama-launch 2>&1'
  mv "$BATS_TEST_DIRNAME/mock_bin/fzf.bak" "$BATS_TEST_DIRNAME/mock_bin/fzf"
  [ "$status" -eq 0 ]
  [[ "$output" == *"ollama launch claude --model kimi-k2.6:cloud"* ]]
}

@test "exits with error when ollama not in PATH" {
  run bash -c 'PATH=/usr/bin:/bin OLLAMA_LAUNCH_TEST=1 ./ollama-launch 2>&1'
  [ "$status" -eq 1 ]
  [[ "$output" == *"ollama is not installed"* ]]
}
