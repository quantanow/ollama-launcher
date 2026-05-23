#!/usr/bin/env bats

@test "--help exits 0 and shows usage" {
  run ./bin/ollama-modelfile --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "--version exits 0 and prints version" {
  run ./bin/ollama-modelfile --version
  [ "$status" -eq 0 ]
  [[ "$output" == *"ollama-modelfile"* ]]
}

@test "-v exits 0 and prints version" {
  run ./bin/ollama-modelfile -v
  [ "$status" -eq 0 ]
  [[ "$output" == *"ollama-modelfile"* ]]
}

@test "unknown flag exits 1 with error" {
  run ./bin/ollama-modelfile --bogus
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown option"* ]]
}

@test "test mode with all flags prints modelfile and command" {
  run bash -c 'echo "" | OLLAMA_MODELFILE_TEST=1 ./bin/ollama-modelfile --name mybot --from llama3.1 --system "You are helpful" --temperature 0.5 --num-ctx 8192 2>&1'
  [ "$status" -eq 0 ]
  [[ "$output" == *"FROM llama3.1"* ]]
  [[ "$output" == *"SYSTEM You are helpful"* ]]
  [[ "$output" == *"PARAMETER temperature 0.5"* ]]
  [[ "$output" == *"PARAMETER num_ctx 8192"* ]]
  [[ "$output" == *"Would run:"* ]]
  [[ "$output" == *"ollama create mybot"* ]]
}

@test "test mode without system prompt omits SYSTEM line" {
  run bash -c 'echo "" | OLLAMA_MODELFILE_TEST=1 ./bin/ollama-modelfile --name mybot --from llama3.1 2>&1'
  [ "$status" -eq 0 ]
  [[ "$output" == *"FROM llama3.1"* ]]
  [[ "$output" != *"SYSTEM"* ]]
}

@test "test mode with top-p includes top_p parameter" {
  run bash -c 'echo "" | OLLAMA_MODELFILE_TEST=1 ./bin/ollama-modelfile --name mybot --from llama3.1 --top-p 0.9 2>&1'
  [ "$status" -eq 0 ]
  [[ "$output" == *"PARAMETER top_p 0.9"* ]]
}
