#!/bin/bash
#CIS Hardening 
if dpkg-query -W -f='${binary:Package}\t${Status}\t${db:Status-Status}\n' ufw | grep -q "installed"; then
    echo "- ufw esta instalado. Se desinstalara "
    apt remove ufw -y
    echo -e "\n - 4.1.1 > \033[0;33m ** Se desinstalo ufw. ** \033[0m \n"
else
    echo "- ufw esta desinstalado. No se requiere accion."
fi