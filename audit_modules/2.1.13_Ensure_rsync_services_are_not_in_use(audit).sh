#!/bin/bash
# Verificar que rsync no este instalado
output=""
if dpkg-query -W -f='${binary:Package}\t${Status}\t${db:Status-Status}\n' rsync 2>/dev/null | grep -q "installed"; then
    echo "- rsync este instalado."

    # Verificar si el servicio este habilitado
    rsync_enabled=$(systemctl is-enabled rsync.service 2>/dev/null)
    rsync_active=$(systemctl is-active rsync.service 2>/dev/null)

    # Evaluar condiciones de falla
    if [[ "$rsync_enabled" == "enabled" || "$rsync_active" == "active" ]]; then
        echo -e " Audit Result: \033[1;31;47m ** [FAIL] ** \033[0;39;49m \n - Reason(s) for audit failure:"
        [[ "$rsync_enabled" == "enabled" ]] && echo "   - rsync.service esta habilitado"
        [[ "$rsync_active" == "active" ]] && echo "   - rsync.service esta activo"
    else
        echo " - rsync esta instalado pero correctamente deshabilitado."
        echo -e " Audit Result:  \033[1;32;47m ** [PASS] ** \033[0;39;49m "
    fi

else
    echo -e " Audit Result:  \033[1;32;47m ** [PASS] ** \033[0;39;49m "
    echo "\n- rsync no este instalado."
fi
