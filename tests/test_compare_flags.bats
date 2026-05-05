#!/usr/bin/env bats

@test "--help exits 0 and shows usage" {
  run ./bin/ollama-compare --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "--version exits 0 and prints version" {
  run ./bin/ollama-compare --version
  [ "$status" -eq 0 ]
  [[ "$output" == *"ollama-compare"* ]]
}

@test "-v exits 0 and prints version" {
  run ./bin/ollama-compare -v
  [ "$status" -eq 0 ]
  [[ "$output" == *"ollama-compare"* ]]
}

@test "unknown flag exits 1 with error" {
  run ./bin/ollama-compare --bogus
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown option"* ]]
}

@test "test mode with --prompt and --models prints commands" {
  run bash -c 'OLLAMA_COMPARE_TEST=1 ./bin/ollama-compare --prompt "Hello" --models gemma4:latest,llama3.1:latest 2>&1'
  [ "$status" -eq 0 ]
  [[ "$output" == *"Would run:"* ]]
  [[ "$output" == *"gemma4:latest"* ]]
  [[ "$output" == *"llama3.1:latest"* ]]
  [[ "$output" == *"RESULTS"* ]]
}

@test "test mode requires at least 2 models" {
  run bash -c 'OLLAMA_COMPARE_TEST=1 ./bin/ollama-compare --prompt "Hello" --models gemma4:latest 2>&1'
  [ "$status" -eq 1 ]
  [[ "$output" == *"at least 2 models"* ]]
}

@test "piped stdin works as prompt with --models" {
  run bash -c 'echo "test prompt" | OLLAMA_COMPARE_TEST=1 ./bin/ollama-compare --models gemma4:latest,llama3.1:latest 2>&1'
  [ "$status" -eq 0 ]
  [[ "$output" == *"test prompt"* ]]
  [[ "$output" == *"Would run:"* ]]
}
