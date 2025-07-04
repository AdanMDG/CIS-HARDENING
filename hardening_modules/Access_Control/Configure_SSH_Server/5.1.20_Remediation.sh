#!/bin/bash

echo "¿Desea realizar el hardening X? (s/n)"
read -r respuesta
if [[ "$respuesta" =~ ^[Ss]$ ]]; then

    CONFIG_FILE="/etc/ssh/sshd_config"

    # Eliminar configuraciones inseguras anteriores
    echo "Eliminando líneas inseguras de PermitRootLogin..."
    sed -i '/^\s*PermitRootLogin\s\+\(yes\|without-password\|prohibit-password\|forced-commands-only\)/Id' "$CONFIG_FILE"

    # Insertar PermitRootLogin no antes de Match/Include si existen
    if grep -qE '^\s*(Include|Match)' "$CONFIG_FILE"; then
        FIRST_LINE=$(grep -nE '^\s*(Include|Match)' "$CONFIG_FILE" | head -n1 | cut -d: -f1)
        sed -i "${FIRST_LINE}i PermitRootLogin no" "$CONFIG_FILE"
        echo "Insertado 'PermitRootLogin no' antes de Include/Match (línea $FIRST_LINE)"
    else
        echo "PermitRootLogin no" >> "$CONFIG_FILE"
        echo "Agregado 'PermitRootLogin no' al final del archivo"
    fi

    # Reiniciar el servicio
    systemctl restart ssh && echo " SSH reiniciado correctamente" || echo " Fallo al reiniciar SSH"

    # Verificación final
    echo "Verificación de la configuración aplicada:"
    if sshd -T -C user=root -C host="$(hostname)" -C addr="$(hostname -I | cut -d ' ' -f1)" | grep permitrootlogin | grep -q "no"; then        
            echo -e "\n - remediation of module:  \033[0;32m > 2.1.13 > ** COMPLETE ** \033[0m \n"
    else
        echo "Error al hardenizar"
    fi
else
    echo "\033[0;32m > 2.1.13 > ** Se omitio el hardening de '5.1.20 Ensure sshd PermitRootLogin is disabled' ** \033[0m"
fi