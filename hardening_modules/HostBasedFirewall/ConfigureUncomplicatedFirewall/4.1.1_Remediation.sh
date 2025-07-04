#!/bin/bash
#CIS Hardening 
if dpkg-query -W -f='${binary:Package}\t${Status}\t${db:Status-Status}\n' ufw | grep -q "not-installed"; then
    echo "- ufw no esta instalado. Se ejecutara "
    apt install ufw -y
else
    echo "- ufw este instalado. No se requiere accion."
fi
echo -e "\n - remediation of module:  \033[0;32m > 4.1.1 > ** COMPLETE ** \033[0m \n"