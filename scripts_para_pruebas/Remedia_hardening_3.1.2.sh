#!/usr/bin/env bash

echo -e "\n🔍 Verificando estado de los módulos Wi-Fi...\n"

# Buscar interfaces inalámbricas
if [ -n "$(find /sys/class/net/*/ -type d -name wireless)" ]; then
    l_dname=$(for driverdir in $(find /sys/class/net/*/ -type d -name wireless | xargs dirname); do basename "$(readlink -f "$driverdir"/device/driver/module)"; done | sort -u)

    for l_mname in $l_dname; do
        conf_path="/etc/modprobe.d/$l_mname.conf"
        backup_path="/etc/modprobe.d/$l_mname.conf.bak"

        echo -e "\n📦 Procesando módulo: $l_mname"

        if [ -f "$conf_path" ]; then
            if [ ! -f "$backup_path" ]; then
                echo "📝 Creando copia de seguridad: $conf_path → $backup_path"
                sudo cp "$conf_path" "$backup_path"
            else
                echo "✅ Backup ya existe: $backup_path"
            fi
        else
            echo "⚠️ Archivo de configuración no encontrado: $conf_path"
            echo "🔁 Intentando revertir el hardening si el módulo está bloqueado..."

            # Revertir manualmente si fue endurecido en otro archivo
            if modprobe -n -v "$l_mname" | grep -q "/bin/false"; then
                echo "🧹 Quitando override con 'install $l_mname /bin/false' (si existe en otros archivos)"
                sudo sed -i "/install $l_mname \/bin\/false/d" /etc/modprobe.d/*.conf
            fi

            if grep -Pq -- "^\h*blacklist\h+$l_mname\b" /etc/modprobe.d/*; then
                echo "🧹 Quitando blacklist de otros archivos"
                sudo sed -i "/blacklist $l_mname/d" /etc/modprobe.d/*.conf
            fi

            echo "🔄 Intentando cargar el módulo $l_mname..."
            if sudo modprobe "$l_mname"; then
                echo "✅ Módulo '$l_mname' cargado correctamente."
            else
                echo "⚠️ No se pudo cargar el módulo '$l_mname' (quizás no esté disponible o esté embebido en el kernel)."
            fi
        fi
    done
else
    echo "ℹ️ No se detectaron interfaces Wi-Fi (wireless) en este sistema."
fi

echo -e "\n✅ Verificación y restauración completada.\n"
