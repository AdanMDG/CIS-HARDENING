#!/bin/bash
#CIS Hardening 
if dpkg-query -W -f='${binary:Package}\t${Status}\t${db:Status-Status}\n' aide aide-common | grep -q "installed"; then
    echo "- AIDE este instalado. Para probar el hardening se desinstalara."
    apt remove aide aide-common -y
    echo -e "\n - 6.1.1 > \033[0;33m ** Se desinstalo AIDE. ** \033[0m \n"
else
    echo "- AIDE no esta instalado. No requiere accion. "
fi