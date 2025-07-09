#!/bin/bash
# CIS Audit de /etc/shadow
output=""
FILE="/etc/shadow"
NIVEL_ACC_ESPERADO=640
UID_ESPERADO="root"
NUM_UID_ESPERADO="0"
GID_ESPERADO="shadow"
GID_ROOT="root"


if [ ! -e "$FILE" ]; then
    echo -e " Audit Result:  \033[1;31;47m ** [FAIL] ** \033[0;39;49m \n"
    echo "- /etc/shadow no existe y esto es grave ya que este almacena los hashes de las contraseñas de los usuarios del sistema."   
    exit 1
fi
NIVEL_ACC=$(stat -c "%#a" "$FILE")
_UID=$(stat -c "%U" "$FILE")
NUM_UID=$(stat -c "%u" "$FILE")
_GID=$(stat -c "%G" "$FILE")
NUM_GID=$(stat -c "%g" "$FILE")
FAIL=0


# Verificar permisos
if [ "$NIVEL_ACC" -gt "$NIVEL_ACC_ESPERADO" ]; then
    output="$output $(echo -e "\n- Permisos muy permisivos ($NIVEL_ACC), se esperaba 640 o menos")"
    FAIL=1
fi

# Verificar UID
if [ "$_UID" != "$UID_ESPERADO" ] || [ "$NUM_UID" != "$NUM_UID_ESPERADO" ]; then
    output="$output $(echo -e "\n- UID debe ser 0/root (actual: $NUM_UID/$_UID)")"
    FAIL=1
fi

# Verificar GID
if [ "$_GID" != "$GID_ESPERADO" ] && [ "$_GID" != "$GID_ROOT" ]; then
    output="$output $(echo -e " \n- GID debe ser root o shadow (actual: $_GID)")"
    FAIL=1
fi

# Resultado final
if [ "$FAIL" -eq 0 ]; then
    echo -e "  Audit Result: \033[1;32;47m ** [PASS] ** \033[0;39;49m  $FILE esta correctamente configurado."
else
    output="$output \n $FILE debe ser 'Access: (0640/-rw-r-----) Uid: ( 0/ root) Gid: ( 42/ shadow)' pero es: "
    output="$output \n $(stat -Lc 'Access: (%#a/%A) Uid: ( %u/ %U) Gid: ( %g/ %G)' "$FILE")"
    echo -e " Audit Result: \033[1;31;47m ** [FAIL] ** \033[0;39;49m \n Razones: \n $output"
    
fi
