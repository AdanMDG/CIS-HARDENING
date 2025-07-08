#!/bin/bash

FILE="/etc/shadow"
GRUPO_SEGURIDAD="shadow"  

# Verificar existencia del archivo
if [ ! -e "$FILE" ]; then
    echo -e "Hardening del modulo 7.1.5  > \033[0;31m[ERROR] El archivo $FILE no existe. No es posible realizar el Hardening. \033[0m "
    exit 1
fi
echo -e "Antes ->"
stat -Lc 'Access: (%#a/%A) Uid: ( %u/ %U) Gid: ( %g/ %G)' "$FILE"
# Establecer propietario y grupo
chmod 666 /etc/shadow "$FILE"  # Todos pueden leer y escribir (inseguro)

# Confirmar resultado final
echo -e "Despues ->"
stat -Lc 'Access: (%#a/%A) Uid: ( %u/ %U) Gid: ( %g/ %G)' "$FILE"
echo -e "\n - 7.1.5 > $FILE esta vulnerable ahora > \033[0;33m ** Todos pueden leer y escribir (inseguro) ** \033[0m \n"