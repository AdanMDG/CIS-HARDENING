#!/bin/bash
# CIS Audit - Verificar que ufw este instalado 

# Verificar si ufw este instalado
if dpkg-query -W -f='${binary:Package}\t${Status}\t${db:Status-Status}\n' ufw | grep -q "not-installed"; then
    echo -e "\n- Audit Result:\n  \033[0;31m ** FAIL ** \033[0m "
    echo "- ufw no esta instalado."    
else
    echo -e "\n- Audit Result:\n  \033[0;32m ** PASS ** \033[0m "
    echo "- ufw esta instalado correctamente"
fi