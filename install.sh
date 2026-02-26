#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run as root"
  exit 1
fi

REPO_OWNER="nikulov"
REPO_NAME="server-manager"
INSTALL_DIR="/root/server-manager"

echo "=== Server Manager Installer ==="
echo ""

if [[ -d "$INSTALL_DIR/.git" ]]; then
  echo "Server Manager already installed."
  read -rp "Reinstall? (y/N): " ans
  if [[ "$ans" != "y" && "$ans" != "Y" ]]; then
    exec "$INSTALL_DIR/main.sh"
  fi
  rm -rf "$INSTALL_DIR"
fi

read -s -p "GitHub Token (fine-grained, Contents: Read): " GHTOKEN
echo ""

BASIC_AUTH="$(printf 'x-access-token:%s' "$GHTOKEN" | base64 -w0)"

git -c http.extraHeader="Authorization: Basic $BASIC_AUTH" \
  clone "https://github.com/${REPO_OWNER}/${REPO_NAME}.git" "$INSTALL_DIR"

unset GHTOKEN BASIC_AUTH

cd "$INSTALL_DIR"

chmod +x install.sh main.sh lib.sh
chmod +x modules/*.sh

echo ""
echo "Installation completed."
echo "Launching Server Manager..."
echo ""

exec "$INSTALL_DIR/main.sh"