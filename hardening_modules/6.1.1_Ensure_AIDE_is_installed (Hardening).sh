#!/bin/bash
#CIS Hardening 
if dpkg-query -W -f='${binary:Package}\t${Status}\t${db:Status-Status}\n' aide aide-common | grep -q "not-installed"; then
    echo "- AIDE no esta instalado. Se instalara "
    apt install aide aide-common
else
    echo "- AIDE este instalado. No se requiere accion."
fi
echo -e "\n - Hardening del modulo 6.1.1 > \033[0;32m ** COMPLETA ** \033[0m \n"