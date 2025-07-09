#!/bin/bash

# Obtener ruta del directorio donde está este script (no el que llama)
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$BASE_DIR/logs"
LOG_FILE="$LOG_DIR/$2"

# Obtener timestamp
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Verificar que haya contenido para guardar
if [ -z "$1" ]; then
    echo "[ERROR] No se recibió texto para registrar en el log." >&2
    exit 1
fi

# Guardar en log
if echo "$1" | grep -q "FAIL|WARNING" ; then
    echo "$1" >> "$LOG_FILE"
fi