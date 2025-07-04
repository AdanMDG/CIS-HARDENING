#!/bin/bash
#CIS Hardening 
{
if dpkg-query -W -f='${binary:Package}\t${Status}\t${db:Status-Status}\n' ufw | grep -q "installed"; then
    echo "- ufw este instalado. No se requiere accion."
else
    echo "- rsync no esta instalado. Se ejecutara "
    apt install ufw
fi
echo -e "\n - remediation of module:  \033[0;32m > 2.1.13 > ** COMPLETE ** \033[0m \n"
}