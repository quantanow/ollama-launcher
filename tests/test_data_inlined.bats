#!/usr/bin/env bats

@test "MODEL_NAMES contains 80 models" {
  run bash -c 'OLLAMA_LAUNCH_SKIP_MAIN=1 source ./ollama-launch; echo "${#MODEL_NAMES[@]}"'
  [ "$status" -eq 0 ]
  [ "$output" = "80" ]
}

@test "first 6 models have variants" {
  run bash -c 'OLLAMA_LAUNCH_SKIP_MAIN=1 source ./ollama-launch; echo "${MODEL_HAS_VARIANTS[0]} ${MODEL_HAS_VARIANTS[1]} ${MODEL_HAS_VARIANTS[2]} ${MODEL_HAS_VARIANTS[3]} ${MODEL_HAS_VARIANTS[4]} ${MODEL_HAS_VARIANTS[5]}"'
  [ "$status" -eq 0 ]
  [ "$output" = "1 1 1 1 1 1" ]
}

@test "model 7 (deepseek-v4-flash) has no variants" {
  run bash -c 'OLLAMA_LAUNCH_SKIP_MAIN=1 source ./ollama-launch; echo "${MODEL_HAS_VARIANTS[6]}"'
  [ "$status" -eq 0 ]
  [ "$output" = "0" ]
}

@test "granite4.1 has 3 variants with correct metadata" {
  run bash -c 'OLLAMA_LAUNCH_SKIP_MAIN=1 source ./ollama-launch; echo "${MODEL_VARIANTS_0[0]} ${MODEL_SIZES_0[0]} ${MODEL_CONTEXTS_0[0]} ${MODEL_INPUTS_0[0]}"'
  [ "$status" -eq 0 ]
  [ "$output" = "granite4.1:3b 2.1GB 128K Text" ]
}
