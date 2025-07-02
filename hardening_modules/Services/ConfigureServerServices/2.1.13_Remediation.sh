#!/bin/bash
#CIS Hardening 
{
if dpkg-query -W -f='${binary:Package}\t${Status}\t${db:Status-Status}\n' rsync | grep -q "installed"; then
    echo "- rsync este instalado."
    
    systemctl stop rsync.service
    echo "- rsync se acaba de detener"
    # Verificar si es dependiente (no podemos saber con certeza desde aquí sin política local)
    echo "- Intentando purgar rsync..."

    if apt purge -y rsync; then
        echo "- rsync purgado exitosamente."
    else
        echo "- No se pudo purgar rsync (puede ser dependencia)."
        echo "- mask-eando el servicio..."
        
        systemctl mask rsync.service 

        echo "- rsync.service fue detenido y mask-eado para evitar que se inicie."
    fi

else
    echo "- rsync no esta instalado. No se requiere accion."
fi
echo -e "\n - remediation of module:  \033[0;32m > 2.1.13 > ** COMPLETE ** \033[0m \n"
}