#!/bin/bash
# CIS Audit - Verificar que rsync no este instalado o este deshabilitado

# Verificar si rsync este instalado
if dpkg-query -W -f='${binary:Package}\t${Status}\t${db:Status-Status}\n' rsync | grep -q "installed"; then
    echo "- rsync este instalado."

    # Verificar si el servicio este habilitado
    rsync_enabled=$(systemctl is-enabled rsync.service 2>/dev/null)
    rsync_active=$(systemctl is-active rsync.service 2>/dev/null)

    echo "- Estado del servicio rsync:"
    echo "  - Habilitado: ${rsync_enabled:-no instalado}"
    echo "  - Activo:     ${rsync_active:-no instalado}"

    # Evaluar condiciones de falla
    if [[ "$rsync_enabled" == "enabled" || "$rsync_active" == "active" ]]; then
        echo -e "\n- Audit Result:\n  \033[0;31m ** FAIL ** \033[0m "
        echo " - Reason(s) for audit failure:"
        [[ "$rsync_enabled" == "enabled" ]] && echo "   - rsync.service esta habilitado"
        [[ "$rsync_active" == "active" ]] && echo "   - rsync.service esta activo"
    else
        echo -e "\n- Audit Result:\n  \033[0;32m ** PASS ** \033[0m "
        echo " - rsync esta instalado pero correctamente deshabilitado."
    fi

else
    echo "- rsync no este instalado."
    echo -e "\n- Audit Result:\n  \033[0;32m ** PASS ** \033[0m "
fi
