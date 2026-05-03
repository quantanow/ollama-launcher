#!/usr/bin/env bats

# ── CLI flag tests ─────────────────────────────────────────────────────────────

@test "--help exits 0 and shows usage" {
  run ./ollama-launch --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "-h exits 0 and shows usage" {
  run ./ollama-launch -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "--version exits 0 and prints version" {
  run ./ollama-launch --version
  [ "$status" -eq 0 ]
  [[ "$output" == *"ollama-launch 1.1.4"* ]]
}

@test "-v exits 0 and prints version" {
  run ./ollama-launch -v
  [ "$status" -eq 0 ]
  [[ "$output" == *"ollama-launch 1.1.4"* ]]
}

@test "--list-agents exits 0 and prints all 5 agents" {
  run ./ollama-launch --list-agents
  [ "$status" -eq 0 ]
  [[ "$output" == *"claude"* ]]
  [[ "$output" == *"codex"* ]]
  [[ "$output" == *"hermes"* ]]
  [[ "$output" == *"openclaw"* ]]
  [[ "$output" == *"opencode"* ]]
  [ "$(echo "$output" | wc -l | tr -d ' ')" -eq 5 ]
}

@test "--list-models exits 0 and prints all 100 models" {
  run ./ollama-launch --list-models
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | wc -l | tr -d ' ')" -eq 100 ]
}

@test "--list-models output contains granite4.1 and llama3" {
  run ./ollama-launch --list-models
  [ "$status" -eq 0 ]
  [[ "$output" == *"granite4.1"* ]]
  [[ "$output" == *"llama3"* ]]
}

@test "unknown flag exits 1 with error message" {
  run ./ollama-launch --bogus
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown option"* ]]
}

@test "unknown flag error message includes flag name" {
  run ./ollama-launch --bogus
  [ "$status" -eq 1 ]
  [[ "$output" == *"--bogus"* ]]
}
