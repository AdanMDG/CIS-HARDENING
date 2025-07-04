#!/usr/bin/env bash
{
    module_fix()
    {
        
        if ! modprobe -n -v "$l_mname" | grep -P -- '^\h*install \/bin\/(true|false)'; then
            echo -e " - setting module: \"$l_mname\" to be un-loadable"
            echo -e "install $l_mname /bin/false" >> /etc/modprobe.d/"$l_mname".conf
        fi
        if lsmod | grep "$l_mname" > /dev/null 2>&1; then
            echo -e " - unloading module \"$l_mname\""
            modprobe -r "$l_mname"
        fi
        if ! grep -Pq -- "^\h*blacklist\h+$l_mname\b" /etc/modprobe.d/*; then
            echo -e " - deny listing \"$l_mname\""
            echo -e "blacklist $l_mname" >> /etc/modprobe.d/"$l_mname".conf
        fi
    }
    # En directorios llamados wireless carga en l_dname una lista de drivers de Wi-Fi que están actualmente en uso en tu sistema.
    if [ -n "$(find /sys/class/net/*/ -type d -name wireless)" ]; then
        l_dname=$(for driverdir in $(find /sys/class/net/*/ -type d -name wireless | xargs -0 dirname); do basename "$(readlink -f "$driverdir"/device/driver/module)";done | sort -u)
        for l_mname in $l_dname; do
            module_fix
        done
    else
        echo -e " No existe driver de wifi en uso en el sistema. "
    fi
    echo -e "\n - remediation of module:  \033[0;32m > 2.1.13 > ** COMPLETE ** \033[0m \n"
# echo -e " - Existe el Script para desabilitarlo pero esta comentado ya que en la creacion del script necesitaba internet y no queria desactivarlo, solo detectarlo."
}