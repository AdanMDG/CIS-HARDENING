#!/usr/bin/env bash
{
    l_output="" l_output2=""
    module_chk()
    {
        # Verificar cómo se cargará el módulo
        l_loadable="$(modprobe -n -v "$l_mname")"
        if grep -Pq -- '^\h*install \/bin\/(true|false)' <<< "$l_loadable"; then
            l_output="$l_output\n - module: \"$l_mname\" is not loadable: \"$l_loadable\""
        else
            l_output2="$l_output2\n - module: \"$l_mname\" is loadable: \"$l_loadable\""
        fi
        # Verificar si el módulo está cargado actualmente
        if ! lsmod | grep "$l_mname" > /dev/null 2>&1; then
            l_output="$l_output\n - module: \"$l_mname\" is not loaded"
        else
            l_output2="$l_output2\n - module: \"$l_mname\" is loaded"
        fi
        # Verificar si el módulo está en la lista de denegados
        if modprobe --showconfig | grep -Pq -- "^\h*blacklist\h+$l_mname\b"; then
            l_output="$l_output\n - module: \"$l_mname\" is deny listed in: \"$(grep -Pl -- "^\h*blacklist\h+$l_mname\b" /etc/modprobe.d/*)\""
        else
            l_output2="$l_output2\n - module: \"$l_mname\" is not deny listed"
        fi
    }
    #Busca todos los directorios llamados wireless dentro de cada interfaz de red en /sys/class/net/
    if [ -n "$(find /sys/class/net/*/ -type d -name wireless)" ]; then
        #| xargs -0 dirname -> Elimina /wireless del final para obtener solo la ruta a la interfaz.
        # for driverdir in ...; do ...; done -> Este for recorre cada una de las interfaces Wi-Fi detectadas
        # readlink -f "$driverdir"/device/driver/module -> Sigue los enlaces simbólicos dentro de /sys para llegar al módulo del kernel (driver) que está manejando esa interfaz. -> ejemplo readlink -f /sys/class/net/wlp3s0/device/driver/module
        # basename ... -> Este comando extrae el nombre final del path, que es el nombre del módulo.
        # | sort -u ->  Ordena los nombres de los drivers y elimina duplicados.
        # La variable l_dname contiene una lista de drivers de Wi-Fi que están actualmente en uso en tu sistema.
        l_dname=$(for driverdir in $(find /sys/class/net/*/ -type d -name wireless | xargs -0 dirname); do basename "$(readlink -f "$driverdir"/device/driver/module)";done | sort -u)
        for l_mname in $l_dname; do
            module_chk
        done
    fi
    # Report results. If no failures output in l_output2, we pass
    if [ -z "$l_output2" ]; then
        echo -e " Audit Result: \033[1;32;47m ** [PASS] ** \033[0;39;49m "
        if [ -z "$l_output" ]; then
            echo -e "\n - El sistema no tiene wireless NICs instaladas"
        else
            echo -e "\n$l_output\n"
        fi
    else
        echo -e " Audit Result:s \033[1;31;47m ** [FAIL] ** \033[0;39;49m \n - Reason(s) for audit failure:\n$l_output2\n"
        [ -n "$l_output" ] && echo -e "\n- Configurado correctamente:\n$l_output\n"
    fi
}