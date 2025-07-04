#!/bin/bash

{
    if sshd -T -C user=root -C host="$(hostname)" -C addr="$(hostname -I | cut -d ' ' -f1)" | grep permitrootlogin | grep -q "no"; then        
        if grep -Psi -- '^\h*PermitRootLogin\h+"?(yes|without-password|prohibit-password|forced-commands-only)"?\b' /etc/ssh/sshd_config /etc/ssh/ssh_config.d/*.conf 2>/dev/null | grep -q .; then
            echo " Se encontraron configuraciones inseguras en los archivos de configuración"
            echo -e "\n- Audit Result:\n  \033[0;31m ** FAIL ** \033[0m "
            grep -Psi -- '^\h*PermitRootLogin\h+"?(yes|without-password|prohibit-password|forced-commands-only)"?\b' /etc/ssh/sshd_config /etc/ssh/ssh_config.d/*.conf 2>/dev/null
        else
            echo -e "\n- Audit Result:\n  \033[0;32m ** PASS ** \033[0m "
        fi

    else
        echo -e "\n- Audit Result:\n  \033[0;31m ** FAIL ** \033[0m "
        sshd -T -C user=root -C host="$(hostname)" -C addr="$(hostname -I | cut -d ' ' -f1)" | grep permitrootlogin
        echo -e " "
        echo -e "Debe retornar: 'permitrootlogin no'"
    fi

    echo "[*] Auditoría finalizada."
}
