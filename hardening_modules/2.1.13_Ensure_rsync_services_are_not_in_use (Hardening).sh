#!/bin/bash
#CIS Hardening 
{
if dpkg-query -W -f='${binary:Package}\t${Status}\t${db:Status-Status}\n' rsync | grep -q " installed"; then
    echo "- rsync esta instalado. Se realizara hardening."
    systemctl stop rsync.service
    # Verificar si es dependiente (no podemos saber con certeza desde aquí sin política local)
    if apt purge -y rsync; then
        echo "- rsync purgado exitosamente."
    else
        echo "- No se pudo purgar rsync (puede ser dependencia)."     
        systemctl mask rsync.service 
        echo "- rsync.service fue mask-eado para evitar que se inicie."
    fi
    echo -e "\n - Hardening del modulo 2.1.13 > \033[0;32m ** COMPLETA ** \033[0m \n"
else
    echo "- rsync no esta instalado. No se requiere hardening."
    echo -e "\n - Hardening del modulo 2.1.13 > \033[0;32m ** rsync no esta instalado. No se requiere hardening. ** \033[0m \n"
fi
}