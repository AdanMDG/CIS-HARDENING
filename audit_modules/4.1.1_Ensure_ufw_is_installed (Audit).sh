#!/bin/bash
# CIS Audit - Verificar que ufw este instalado 

# Verificar si ufw este instalado
if dpkg-query -W -f='${binary:Package}\t${Status}\t${db:Status-Status}\n' ufw | grep -q "not-installed"; then
    echo -e " Audit Result:  \033[1;31;47m ** [FAIL] ** \033[0;39;49m  "
    echo "- ufw no esta instalado."    
else
    echo -e " Audit Result:  \033[1;32;47m ** [PASS] ** \033[0;39;49m "
    echo "- ufw esta instalado correctamente"
fi