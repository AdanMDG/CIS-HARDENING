#!/bin/bash

FILE="/etc/shadow"
GRUPO_SEGURIDAD="shadow"  # Podes usar "root" si querés más restricción

# Verificar existencia del archivo
if [ ! -e "$FILE" ]; then
    echo -e "\033[0;31m[ERROR]\033[0m El archivo $FILE no existe."
    exit 1
fi

# Establecer propietario y grupo
chown root:$GRUPO_SEGURIDAD "$FILE"

# Establecer permisos correctos
chmod u-x,g-wx,o-rwx "$FILE"

# Confirmar resultado final
stat -Lc 'Access: (%#a/%A) Uid: ( %u/ %U) Gid: ( %g/ %G)' "$FILE"
echo -e "\n - remediation of module:  \033[0;32m > 7.1.5 > ** COMPLETE ** \033[0m \n"
