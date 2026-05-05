#!/usr/bin/env bats

@test "--help exits 0 and shows usage" {
  run ./bin/ollama-bench --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "--version exits 0 and prints version" {
  run ./bin/ollama-bench --version
  [ "$status" -eq 0 ]
  [[ "$output" == *"ollama-bench"* ]]
}

@test "-v exits 0 and prints version" {
  run ./bin/ollama-bench -v
  [ "$status" -eq 0 ]
  [[ "$output" == *"ollama-bench"* ]]
}

@test "unknown flag exits 1 with error" {
  run ./bin/ollama-bench --bogus
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown option"* ]]
}

@test "test mode with --model and --runs prints results" {
  run bash -c 'OLLAMA_BENCH_TEST=1 ./bin/ollama-bench --model llama3.1 --runs 2 2>&1'
  [ "$status" -eq 0 ]
  [[ "$output" == *"Would run:"* ]]
  [[ "$output" == *"Results"* ]]
  [[ "$output" == *"Avg:"* ]]
  [[ "$output" == *"Total:"* ]]
}

@test "test mode with single run shows time" {
  run bash -c 'OLLAMA_BENCH_TEST=1 ./bin/ollama-bench --model llama3.1 --runs 1 2>&1'
  [ "$status" -eq 0 ]
  [[ "$output" == *"Time:"* ]]
}

@test "--history shows no history when empty" {
  run ./bin/ollama-bench --history 2>&1
  [ "$status" -eq 0 ]
  [[ "$output" == *"No benchmark history"* ]]
}

@test "invalid --runs exits with error" {
  run ./bin/ollama-bench --model llama3.1 --runs 0 2>&1
  [ "$status" -eq 1 ]
  [[ "$output" == *"positive integer"* ]]
}
