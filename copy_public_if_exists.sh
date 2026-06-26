#!/bin/sh
SRC_DIR="/app/frontend/public"
DEST_DIR="/app/frontend/public"
if [ -d "$SRC_DIR" ]; then
  echo "Pasta public encontrada, copiando para destino..."
  cp -r "$SRC_DIR" "$DEST_DIR"
else
  echo "Pasta public não encontrada, nada a copiar."
fi
