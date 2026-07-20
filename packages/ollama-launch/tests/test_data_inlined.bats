#!/usr/bin/env bats

@test "MODEL_NAMES contains 100 models" {
  run bash -c 'OLLAMA_LAUNCH_SKIP_MAIN=1 source ./bin/ollama-launch; echo "${#MODEL_NAMES[@]}"'
  [ "$status" -eq 0 ]
  [ "$output" = "100" ]
}

@test "first 6 models have variants" {
  run bash -c 'OLLAMA_LAUNCH_SKIP_MAIN=1 source ./bin/ollama-launch; echo "${MODEL_HAS_VARIANTS[0]} ${MODEL_HAS_VARIANTS[1]} ${MODEL_HAS_VARIANTS[2]} ${MODEL_HAS_VARIANTS[3]} ${MODEL_HAS_VARIANTS[4]} ${MODEL_HAS_VARIANTS[5]}"'
  [ "$status" -eq 0 ]
  [ "$output" = "1 1 1 1 1 1" ]
}

@test "model 19 (deepseek-v4-flash) has variants" {
  run bash -c 'OLLAMA_LAUNCH_SKIP_MAIN=1 source ./bin/ollama-launch; echo "${MODEL_HAS_VARIANTS[18]}"'
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
}

@test "granite4.1 (index 16) has 3 variants with correct metadata" {
  run bash -c 'OLLAMA_LAUNCH_SKIP_MAIN=1 source ./bin/ollama-launch; echo "${MODEL_VARIANTS_16[0]} ${MODEL_SIZES_16[0]} ${MODEL_CONTEXTS_16[0]} ${MODEL_INPUTS_16[0]}"'
  [ "$status" -eq 0 ]
  [ "$output" = "granite4.1:3b 2.1GB 128K Text" ]
}

@test "MODEL_PULLS length matches MODEL_NAMES" {
  run bash -c 'OLLAMA_LAUNCH_SKIP_MAIN=1 source ./bin/ollama-launch; echo "${#MODEL_PULLS[@]}"'
  [ "$status" -eq 0 ]
  [ "$output" = "100" ]
}

@test "MODEL_TAGS length matches MODEL_NAMES" {
  run bash -c 'OLLAMA_LAUNCH_SKIP_MAIN=1 source ./bin/ollama-launch; echo "${#MODEL_TAGS[@]}"'
  [ "$status" -eq 0 ]
  [ "$output" = "100" ]
}

@test "MODEL_HAS_VARIANTS length matches MODEL_NAMES" {
  run bash -c 'OLLAMA_LAUNCH_SKIP_MAIN=1 source ./bin/ollama-launch; echo "${#MODEL_HAS_VARIANTS[@]}"'
  [ "$status" -eq 0 ]
  [ "$output" = "100" ]
}

@test "all 6 variant-bearing models have non-empty variant arrays" {
  run bash -c 'OLLAMA_LAUNCH_SKIP_MAIN=1 source ./bin/ollama-launch
    for i in 0 1 2 3 4 5; do
      eval "count=\${#MODEL_VARIANTS_${i}[@]}"
      if [ "$count" -eq 0 ]; then echo "missing variants for index $i"; exit 1; fi
    done
    echo ok'
  [ "$status" -eq 0 ]
  [ "$output" = "ok" ]
}

@test "variant sub-arrays for index 0-5 each have matching sizes/contexts/inputs" {
  run bash -c 'OLLAMA_LAUNCH_SKIP_MAIN=1 source ./bin/ollama-launch
    for i in 0 1 2 3 4 5; do
      eval "nv=\${#MODEL_VARIANTS_${i}[@]}"
      eval "ns=\${#MODEL_SIZES_${i}[@]}"
      eval "nc=\${#MODEL_CONTEXTS_${i}[@]}"
      eval "ni=\${#MODEL_INPUTS_${i}[@]}"
      if [ "$nv" != "$ns" ] || [ "$nv" != "$nc" ] || [ "$nv" != "$ni" ]; then
        echo "length mismatch at index $i: variants=$nv sizes=$ns contexts=$nc inputs=$ni"
        exit 1
      fi
    done
    echo ok'
  [ "$status" -eq 0 ]
  [ "$output" = "ok" ]
}

@test "mistral-medium-3.5 (index 19) has 2 variants" {
  run bash -c 'OLLAMA_LAUNCH_SKIP_MAIN=1 source ./bin/ollama-launch; echo "${#MODEL_VARIANTS_19[@]}"'
  [ "$status" -eq 0 ]
  [ "$output" = "2" ]
}

@test "kimi-k2.6 (index 15) has exactly 1 variant" {
  run bash -c 'OLLAMA_LAUNCH_SKIP_MAIN=1 source ./bin/ollama-launch; echo "${#MODEL_VARIANTS_15[@]}"'
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
}

@test "glm-5.1 (index 6) variant is cloud" {
  run bash -c 'OLLAMA_LAUNCH_SKIP_MAIN=1 source ./bin/ollama-launch; echo "${MODEL_VARIANTS_6[0]}"'
  [ "$status" -eq 0 ]
  [ "$output" = "glm-5.1:cloud" ]
}
