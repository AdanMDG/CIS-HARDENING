#!/bin/bash


# Verificación final
if sshd -T -C user=root -C host="$(hostname)" -C addr="$(hostname -I | cut -d ' ' -f1)" | grep permitrootlogin | grep -q "no"; then        
    echo -e "\n - Hardening del modulo 5.1.20 > \033[0;32m ** No es necesario hardenizar.** \033[0m \n"
else
    read -r -p "¿Desea prohibir el inicio de sesión root mediante SSH? (s/n): " respuesta
    if [[ "$respuesta" =~ ^[Ss]$ ]]; then

        CONFIG_FILE="/etc/ssh/sshd_config"

        # Eliminar configuraciones inseguras anteriores
        echo "Eliminando lineas inseguras de PermitRootLogin..."
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
                echo -e "\n - Hardening del modulo 5.1.20 > \033[0;32m ** COMPLETA ** \033[0m \n"
        else
            echo -e "Hardening del modulo 5.1.20 > \033[0;31m Error al hardenizar \033[0m "
        fi
    else
        echo -e "\n - Hardening del modulo 5.1.20 > \033[0;33m ** Omitido por decision del usuario ** \033[0m \n"
    fi
fi