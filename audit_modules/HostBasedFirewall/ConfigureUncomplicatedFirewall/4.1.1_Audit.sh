#!/bin/bash
# CIS Audit - Verificar que ufw no este instalado o este deshabilitado

# Verificar si ufw este instalado
if dpkg-query -W -f='${binary:Package}\t${Status}\t${db:Status-Status}\n' ufw | grep -q "installed"; then
    echo -e "\n- Audit Result:\n  \033[0;32m ** PASS ** \033[0m "
    echo "- ufw esta instalado correctamente"
else
    echo -e "\n- Audit Result:\n  \033[0;32m ** FAIL ** \033[0m "
    echo "- ufw no esta instalado."
fi