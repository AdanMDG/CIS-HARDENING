#!/bin/bash
#CIS Hardening 
if dpkg-query -W -f='${binary:Package}\t${Status}\t${db:Status-Status}\n' ufw | grep -q "installed"; then
    echo "- ufw este instalado. No se requiere accion."
else
    echo "- ufw no esta instalado. Se instalara "
    apt install ufw -y
fi
echo -e "\n - Hardening del modulo 4.1.1 > \033[0;32m ** COMPLETA ** \033[0m \n"