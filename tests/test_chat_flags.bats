#!/usr/bin/env bats

setup() {
  export CHAT_DIR="$(mktemp -d /tmp/ollama-chat-test-XXXXXX)"
  mkdir -p "$CHAT_DIR"

  cat > "$CHAT_DIR/demo.txt" <<'EOF'
# ollama-chat: demo
MODEL: llama3.1
SYSTEM: You are a test assistant.

USER: Hello
ASSISTANT: Hi there!
EOF
}

teardown() {
  rm -rf "$CHAT_DIR" 2>/dev/null || true
}

@test "--help exits 0 and shows usage" {
  run ./bin/ollama-chat --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "--version exits 0 and prints version" {
  run ./bin/ollama-chat --version
  [ "$status" -eq 0 ]
  [[ "$output" == *"ollama-chat"* ]]
}

@test "-v exits 0 and prints version" {
  run ./bin/ollama-chat -v
  [ "$status" -eq 0 ]
  [[ "$output" == *"ollama-chat"* ]]
}

@test "unknown flag exits 1 with error" {
  run ./bin/ollama-chat --bogus
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown option"* ]]
}

@test "--list shows existing chats" {
  run env CHAT_DIR="$CHAT_DIR" bash -c 'CHAT_DIR="'"$CHAT_DIR"'" OLLAMA_CHAT_TEST=1 ./bin/ollama-chat --list 2>&1'
  [ "$status" -eq 0 ]
  [[ "$output" == *"demo"* ]]
}

@test "--list empty shows no chats" {
  empty_dir="$(mktemp -d /tmp/ollama-chat-empty-XXXXXX)"
  run env CHAT_DIR="$empty_dir" bash -c 'CHAT_DIR="'"$empty_dir"'" OLLAMA_CHAT_TEST=1 ./bin/ollama-chat --list 2>&1'
  rm -rf "$empty_dir"
  [ "$status" -eq 0 ]
  [[ "$output" == *"No chats"* ]]
}

@test "--info shows chat metadata" {
  run env CHAT_DIR="$CHAT_DIR" bash -c 'CHAT_DIR="'"$CHAT_DIR"'" OLLAMA_CHAT_TEST=1 ./bin/ollama-chat --info demo 2>&1'
  [ "$status" -eq 0 ]
  [[ "$output" == *"demo"* ]]
  [[ "$output" == *"llama3.1"* ]]
  [[ "$output" == *"test assistant"* ]]
}

@test "--info nonexistent exits 1" {
  run env CHAT_DIR="$CHAT_DIR" bash -c 'CHAT_DIR="'"$CHAT_DIR"'" OLLAMA_CHAT_TEST=1 ./bin/ollama-chat --info nonexistent 2>&1'
  [ "$status" -eq 1 ]
  [[ "$output" == *"not found"* ]]
}

@test "test mode --resume processes input and appends" {
  run bash -c 'CHAT_DIR="'"$CHAT_DIR"'" echo "Whats 2+2?" | OLLAMA_CHAT_TEST=1 ./bin/ollama-chat --resume demo 2>&1'
  [ "$status" -eq 0 ]
  [[ "$output" == *"MOCK RESPONSE"* ]]
  # Verify file was appended
  grep -q "Whats 2+2?" "$CHAT_DIR/demo.txt"
  grep -q "MOCK RESPONSE" "$CHAT_DIR/demo.txt"
}

@test "--fork copies chat" {
  run env CHAT_DIR="$CHAT_DIR" bash -c 'CHAT_DIR="'"$CHAT_DIR"'" OLLAMA_CHAT_TEST=1 ./bin/ollama-chat --fork demo demo2 2>&1'
  [ "$status" -eq 0 ]
  [[ "$output" == *"Forked:"* ]]
  [ -f "$CHAT_DIR/demo2.txt" ]
  grep -q "llama3.1" "$CHAT_DIR/demo2.txt"
}

@test "--delete removes chat" {
  run bash -c 'printf "y\n" | CHAT_DIR="'"$CHAT_DIR"'" OLLAMA_CHAT_TEST=1 ./bin/ollama-chat --delete demo 2>&1'
  [ "$status" -eq 0 ]
  [[ "$output" == *"Deleted"* ]]
  [ ! -f "$CHAT_DIR/demo.txt" ]
}

@test "--delete nonexistent exits 1" {
  run env CHAT_DIR="$CHAT_DIR" bash -c 'CHAT_DIR="'"$CHAT_DIR"'" OLLAMA_CHAT_TEST=1 ./bin/ollama-chat --delete nonexistent 2>&1'
  [ "$status" -eq 1 ]
  [[ "$output" == *"not found"* ]]
}
