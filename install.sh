#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="/usr/local/bin"
REPO_URL="https://raw.githubusercontent.com/quantanow/ollama-launcher/main"

TOOLS=(
  "ollama-launch"
  "ollama-clean"
  "ollama-compare"
  "ollama-batch"
  "ollama-bench"
  "ollama-chat"
  "ollama-modelfile"
  "ollama-vision"
  "ollama-pipe"
)

echo "Installing ollama-launcher tools..."

for tool in "${TOOLS[@]}"; do
  src="${REPO_URL}/bin/${tool}"
  dst="${INSTALL_DIR}/${tool}"

  echo "  Downloading ${tool}..."
  if ! curl -fsSL "${src}" -o "/tmp/${tool}"; then
    echo "Error: Failed to download ${tool}" >&2
    exit 1
  fi

  chmod +x "/tmp/${tool}"

  if [ -w "$INSTALL_DIR" ]; then
    mv "/tmp/${tool}" "$dst"
  else
    sudo mv "/tmp/${tool}" "$dst"
  fi

echo "  Installed ${tool}"
done

echo
echo "All tools installed to ${INSTALL_DIR}:"
for tool in "${TOOLS[@]}"; do
  echo "  ${tool}"
done
echo
echo "Run: ollama-launch"
echo "Run: ollama-clean"
echo "Run: ollama-compare"
echo "Run: ollama-batch"
echo "Run: ollama-bench"
echo "Run: ollama-chat"
echo "Run: ollama-modelfile"
echo "Run: ollama-vision"
echo "Run: ollama-pipe"
