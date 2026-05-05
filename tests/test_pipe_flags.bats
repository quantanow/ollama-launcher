#!/usr/bin/env bats

@test "--help exits 0 and shows usage" {
  run ./bin/ollama-pipe --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "--version exits 0 and prints version" {
  run ./bin/ollama-pipe --version
  [ "$status" -eq 0 ]
  [[ "$output" == *"ollama-pipe"* ]]
}

@test "-v exits 0 and prints version" {
  run ./bin/ollama-pipe -v
  [ "$status" -eq 0 ]
  [[ "$output" == *"ollama-pipe"* ]]
}

@test "unknown flag exits 1 with error" {
  run ./bin/ollama-pipe --bogus
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown option"* ]]
}

@test "test mode with --step and --input prints command" {
  tmpin=$(mktemp)
  echo "Hello world" > "$tmpin"
  OLLAMA_PIPE_TEST=1 run ./bin/ollama-pipe --input "$tmpin" --step "llama3.1 Summarize this"
  rm -f "$tmpin"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Would run:"* ]]
  [[ "$output" == *"llama3.1"* ]]
}

@test "test mode with --chain prints commands for all steps" {
  tmpin=$(mktemp)
  echo "Hello world" > "$tmpin"
  OLLAMA_PIPE_TEST=1 run ./bin/ollama-pipe --input "$tmpin" --chain summarize,json --model llama3.1
  rm -f "$tmpin"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Step 1/2:"* ]]
  [[ "$output" == *"Step 2/2:"* ]]
}

@test "missing input file exits 1 with error" {
  run ./bin/ollama-pipe --input /nonexistent.txt --step "llama3.1 Summarize"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Input file not found"* ]]
}

@test "unknown chain step exits 1 with error" {
  tmpin=$(mktemp)
  echo "test" > "$tmpin"
  OLLAMA_PIPE_TEST=1 run ./bin/ollama-pipe --input "$tmpin" --chain bogus
  rm -f "$tmpin"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown chain step"* ]]
}

@test "--step without space exits 1 with error" {
  tmpin=$(mktemp)
  echo "test" > "$tmpin"
  OLLAMA_PIPE_TEST=1 run ./bin/ollama-pipe --input "$tmpin" --step "llama3.1"
  rm -f "$tmpin"
  [ "$status" -eq 1 ]
  [[ "$output" == *"must include a model and a prompt"* ]]
}
