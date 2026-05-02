#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="ollama-launch"
REPO_URL="https://raw.githubusercontent.com/quantanow/ollama-launcher/main"

echo "Installing ${SCRIPT_NAME}..."

if ! curl -fsSL "${REPO_URL}/${SCRIPT_NAME}" -o "/tmp/${SCRIPT_NAME}"; then
  echo "Error: Failed to download ${SCRIPT_NAME}" >&2
  exit 1
fi

chmod +x "/tmp/${SCRIPT_NAME}"

if [ -w "$INSTALL_DIR" ]; then
  mv "/tmp/${SCRIPT_NAME}" "${INSTALL_DIR}/${SCRIPT_NAME}"
else
  sudo mv "/tmp/${SCRIPT_NAME}" "${INSTALL_DIR}/${SCRIPT_NAME}"
fi

echo "Installed to ${INSTALL_DIR}/${SCRIPT_NAME}"
echo "Run: ollama-launch"
