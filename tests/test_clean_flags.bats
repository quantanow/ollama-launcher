#!/usr/bin/env bats

@test "--help exits 0 and shows usage" {
  run ./bin/ollama-clean --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "--version exits 0 and prints version" {
  run ./bin/ollama-clean --version
  [ "$status" -eq 0 ]
  [[ "$output" == *"ollama-clean"* ]]
}

@test "-v exits 0 and prints version" {
  run ./bin/ollama-clean -v
  [ "$status" -eq 0 ]
  [[ "$output" == *"ollama-clean"* ]]
}
