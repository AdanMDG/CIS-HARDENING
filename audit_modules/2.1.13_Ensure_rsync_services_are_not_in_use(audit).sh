#!/bin/bash
# Verificar si rsync este instalado
if dpkg-query -W -f='${binary:Package}\t${Status}\t${db:Status-Status}\n' rsync | grep -q "installed"; then
    echo "- rsync este instalado."

    # Verificar si el servicio este habilitado
    rsync_enabled=$(systemctl is-enabled rsync.service 2>/dev/null)
    rsync_active=$(systemctl is-active rsync.service 2>/dev/null)

    # Evaluar condiciones de falla
    if [[ "$rsync_enabled" == "enabled" || "$rsync_active" == "active" ]]; then
        echo -e "\n- Audit Result: \033[0;31m **[FAIL] ** \033[0m "
        echo " - Reason(s) for audit failure:"
        [[ "$rsync_enabled" == "enabled" ]] && echo "   - rsync.service esta habilitado"
        [[ "$rsync_active" == "active" ]] && echo "   - rsync.service esta activo"
    else
        echo " - rsync esta instalado pero correctamente deshabilitado."
        echo -e "\n- Audit Result:  \033[0;32m ** [PASS] ** \033[0m "
    fi

else
    echo "- rsync no este instalado."
    echo -e "\n- Audit Result:  \033[0;32m ** [PASS] ** \033[0m "
fi
