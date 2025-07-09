#!/bin/bash
# CIS Audit - Verificar que AIDE este instalado

# Verificar si AIDE este instalado
if dpkg-query -W -f='${binary:Package}\t${Status}\t${db:Status-Status}\n' aide aide-common | grep -q "not-installed"; then
    echo -e " Audit Result: \033[1;31;47m ** [FAIL] ** \033[0;39;49m"
    echo "\n-- AIDE no esta instalado y se recomienda que le esté."    
else
    echo -e " Audit Result:  \033[1;32;47m ** [PASS] ** \033[0;39;49m  "
    echo "\n-- AIDE esta instalado correctamente."
fi