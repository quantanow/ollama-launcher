#!/usr/bin/env bats

setup() {
  TEST_DIR="$(mktemp -d /tmp/ollama-batch-test-XXXXXX)"
  printf 'Hello world\n' > "$TEST_DIR/a.txt"
  printf 'Second file\n' > "$TEST_DIR/b.txt"
}

teardown() {
  rm -rf "$TEST_DIR" "${TEST_DIR}_out" 2>/dev/null || true
}

@test "--help exits 0 and shows usage" {
  run ./bin/ollama-batch --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "--version exits 0 and prints version" {
  run ./bin/ollama-batch --version
  [ "$status" -eq 0 ]
  [[ "$output" == *"ollama-batch"* ]]
}

@test "-v exits 0 and prints version" {
  run ./bin/ollama-batch -v
  [ "$status" -eq 0 ]
  [[ "$output" == *"ollama-batch"* ]]
}

@test "unknown flag exits 1 with error" {
  run ./bin/ollama-batch --bogus
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown option"* ]]
}

@test "test mode processes files and creates outputs" {
  run bash -c "OLLAMA_BATCH_TEST=1 ./bin/ollama-batch --dir '$TEST_DIR' --model llama3.1 2>&1"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Would run:"* ]]
  [[ "$output" == *"a.txt"* ]]
  [[ "$output" == *"b.txt"* ]]
  [[ "$output" == *"2 processed, 0 skipped"* ]]
}

@test "test mode skips existing outputs on resume" {
  # First run creates outputs
  OLLAMA_BATCH_TEST=1 ./bin/ollama-batch --dir "$TEST_DIR" --model llama3.1 >/dev/null 2>&1
  # Second run skips
  run bash -c "OLLAMA_BATCH_TEST=1 ./bin/ollama-batch --dir '$TEST_DIR' --model llama3.1 2>&1"
  [ "$status" -eq 0 ]
  [[ "$output" == *"0 processed, 2 skipped"* ]]
}

@test "errors when dir does not exist" {
  run bash -c 'OLLAMA_BATCH_TEST=1 ./bin/ollama-batch --dir /nonexistent/path --model llama3.1 2>&1'
  [ "$status" -eq 1 ]
  [[ "$output" == *"Directory not found"* ]]
}

@test "errors when no matching files" {
  empty_dir="$(mktemp -d /tmp/ollama-batch-empty-XXXXXX)"
  run bash -c "OLLAMA_BATCH_TEST=1 ./bin/ollama-batch --dir '$empty_dir' --model llama3.1 2>&1"
  rm -rf "$empty_dir"
  [ "$status" -eq 1 ]
  [[ "$output" == *"No files matching"* ]]
}
