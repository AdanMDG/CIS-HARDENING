#!/bin/bash

{
    if sshd -T -C user=root -C host="$(hostname)" -C addr="$(hostname -I | cut -d ' ' -f1)" | grep permitrootlogin | grep -q "no"; then        
        if grep -Psi -- '^\h*PermitRootLogin\h+"?(yes|without-password|prohibit-password|forced-commands-only)"?\b' /etc/ssh/sshd_config /etc/ssh/ssh_config.d/*.conf 2>/dev/null | grep -q .; then
            echo " Se encontraron configuraciones inseguras en los archivos de configuración"
            echo -e " Audit Result:  \033[1;31;47m ** [FAIL] ** \033[0;39;49m  "
            grep -Psi -- '^\h*PermitRootLogin\h+"?(yes|without-password|prohibit-password|forced-commands-only)"?\b' /etc/ssh/sshd_config /etc/ssh/ssh_config.d/*.conf 2>/dev/null
        else
            echo -e " Audit Result: \033[1;32;47m ** [PASS] ** \033[0;39;49m "
        fi

    else
        echo -e " Audit Result:  \033[1;31;47m ** [FAIL] ** \033[0;39;49m  "
        sshd -T -C user=root -C host="$(hostname)" -C addr="$(hostname -I | cut -d ' ' -f1)" | grep permitrootlogin
        echo -e "\n- Debe retornar: 'permitrootlogin no' para prohibir completamente el acceso SSH como root"
    fi

}
