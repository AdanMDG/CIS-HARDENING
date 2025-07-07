#!/bin/bash
# CIS Audit de /etc/shadow

FILE="/etc/shadow"
NIVEL_ACC_ESPERADO=640
UID_ESPERADO="root"
NUM_UID_ESPERADO="0"
GID_ESPERADO="shadow"
GID_ROOT="root"


if [ ! -e "$FILE" ]; then
    echo -e "\n- Audit Result:\n  \033[0;31m ** FAIL ** \033[0m "
    echo "- /etc/shadow no existe."   
    exit 1
fi

NIVEL_ACC=$(stat -c "%a" "$FILE")
UID=$(stat -c "%U" "$FILE")
NUM_UID=$(stat -c "%u" "$FILE")
GID=$(stat -c "%G" "$FILE")
NUM_GID=$(stat -c "%g" "$FILE")

FAIL=0

# Verificar permisos
if [ "$NIVEL_ACC" -gt "$NIVEL_ACC_ESPERADO" ]; then
    echo -e "  \033[0;31mFAIL:\033[0m Permisos muy permisivos ($NIVEL_ACC), se esperaba 640 o menos"
    FAIL=1
fi

# Verificar UID
if [ "$UID" != "$UID_ESPERADO" ] || [ "$NUM_UID" != "$NUM_UID_ESPERADO" ]; then
    echo -e "  \033[0;31mFAIL:\033[0m UID debe ser 0/root (actual: $NUM_UID/$UID)"
    FAIL=1
fi

# Verificar GID
if [ "$GID" != "$GID_ESPERADO" ] && [ "$GID" != "$GID_ROOT" ]; then
    echo -e "  \033[0;31mFAIL:\033[0m GID debe ser root o shadow (actual: $GID)"
    FAIL=1
fi

# Resultado final
if [ "$FAIL" -eq 0 ]; then
    echo -e "  \033[0;32m** PASS **\033[0m $FILE esta correctamente configurado."
else
    echo -e "  \033[0;31m** FAIL **\033[0m $FILE requiere hardening."
fi
