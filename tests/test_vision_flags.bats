#!/usr/bin/env bats

@test "--help exits 0 and shows usage" {
  run ./bin/ollama-vision --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "--version exits 0 and prints version" {
  run ./bin/ollama-vision --version
  [ "$status" -eq 0 ]
  [[ "$output" == *"ollama-vision"* ]]
}

@test "-v exits 0 and prints version" {
  run ./bin/ollama-vision -v
  [ "$status" -eq 0 ]
  [[ "$output" == *"ollama-vision"* ]]
}

@test "unknown flag exits 1 with error" {
  run ./bin/ollama-vision --bogus
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown option"* ]]
}

@test "test mode with all flags prints command" {
  tmpimg=$(mktemp)
  run bash -c "OLLAMA_VISION_TEST=1 ./bin/ollama-vision --model llava --image $tmpimg --prompt 'Describe this' 2>&1"
  rm -f "$tmpimg"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Would run:"* ]]
  [[ "$output" == *"ollama run llava"* ]]
  [[ "$output" == *"Describe this"* ]]
  [[ "$output" == *"--image"* ]]
}

@test "test mode with multiple images prints all --image args" {
  tmpimg=$(mktemp)
  run bash -c "OLLAMA_VISION_TEST=1 ./bin/ollama-vision --model llava --image ${tmpimg},${tmpimg} --prompt 'Compare' 2>&1"
  rm -f "$tmpimg"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Would run:"* ]]
  [[ "$output" == *"--image"* ]]
}

@test "missing image file exits 1 with error" {
  run ./bin/ollama-vision --model llava --image /nonexistent.png --prompt "test"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Image not found"* ]]
}
