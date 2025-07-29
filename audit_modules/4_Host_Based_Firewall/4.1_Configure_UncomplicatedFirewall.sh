#!/bin/bash
# CIS Audit - Verificar que ufw este instalado 

fail_count=0
audit_log=""

read -r -d '' expected <<EOF
Anywhere on lo ALLOW IN Anywhere
Anywhere DENY IN 127.0.0.0/8
Anywhere (v6) on lo ALLOW IN Anywhere (v6)
Anywhere (v6) DENY IN ::1
Anywhere ALLOW OUT Anywhere on lo
Anywhere (v6) ALLOW OUT Anywhere (v6) on lo
EOF
# ========================================================================================================================
# 4.1.1 Ensure ufw is installed
if dpkg-query -W -f='${binary:Package}\t${Status}\t${db:Status-Status}\n' ufw | grep -q "installed"; then
    audit_log+="\n \033[1;32;47m ** [PASS] ** \033[0;39;49m - 4.1.1 - UFW está instalado"

    # 4.1.2 Ensure iptables-persistent is not installed with UFW
    if dpkg-query -s iptables-persistent | grep -q "not installed"; then
        audit_log+="\n \033[1;32;47m ** [PASS] ** \033[0;39;49m - 4.1.2 - iptables-persistent NO instalado (correcto)" 
    else
        audit_log+="\n \033[1;31;47m ** [FAIL] ** \033[0;39;49m - 4.1.2 - iptables-persistent está instalado ( riesgo deconflicto con UFW)"
        ((fail_count++)) 
    fi
    
    # 4.2.2 Ensure ufw is uninstalled or disabled with nftables
    if dpkg-query -s nftables | grep 'Status: install ok installed'; then
        audit_log+="\n \033[1;31;47m ** [FAIL] ** \033[0;39;49m - 4.2.2 - nftables está instalado ( riesgo de conflicto con UFW)"
        ((fail_count++))
    else
        audit_log+="\n \033[1;32;47m ** [PASS] ** \033[0;39;49m - 4.1.2 - nftables NO instalado (correcto)" 
    fi

    # ========================================================================================================================
    # 4.1.3 Ensure ufw service is enabled
    # Verificar si el servicio este habilitado
    ufw_enabled=$(systemctl is-enabled ufw.service 2>/dev/null)
    ufw_active=$(systemctl is-active ufw 2>/dev/null)
    # Evaluar condiciones de falla
    if [[ "$ufw_enabled" == "enabled" && "$ufw_active" == "active" ]]; then
        audit_log+= "\n \033[1;32;47m ** [PASS] ** \033[0;39;49m \n - 4.1.3 - UFW activo y habilitado \n "
    else
        audit_log+="\n \033[1;31;47m ** [FAIL] ** \033[0;39;49m "
        [[ "$ufw_enabled" != "enabled" ]] && audit_log+="\n  - ufw.service no esta habilitado y se recomienda que lo esté."
        [[ "$ufw_active" != "active" ]] && audit_log+="\n   - ufw no esta activo y se recomienda que lo esté."
    fi

    # ========================================================================================================================
    # 4.1.4 Ensure ufw loopback traffic is configured
    # Extraer reglas de UFW (solo la tabla)
    rules=$(ufw status verbose | awk '/^To[[:space:]]+Action[[:space:]]+From/ {flag=1; next} flag' | sed 's/^[[:space:]]*//')

    if diff -q <(echo "$rules") <(echo "$expected") >/dev/null; then
        audit_log+="\n \033[1;32;47m ** [PASS] ** \033[0;39;49m \n  4.1.4 - Reglas de loopback configuradas correctamente"
    else
        audit_log+="\n  \033[1;31;47m ** [FAIL] ** \033[0;39;49m 4.1.4 - Reglas de loopback incompletas o desordenadas"
        ((fail_count++))
    fi

    # ========================================================================================================================
    #4.1.6 Ensure ufw firewall rules exist for all open ports 
    unset a_ufwout;unset a_openports
    while read -r l_ufwport; do
        [ -n "$l_ufwport" ] && a_ufwout+=("$l_ufwport")
    done < <(ufw status verbose | grep -Po '^\h*\d+\b' | sort -u)
    while read -r l_openport; do
        [ -n "$l_openport" ] && a_openports+=("$l_openport")
    done < <(ss -tuln | awk '($5!~/%lo:/ && $5!~/127.0.0.1:/ && $5!~/\[?::1\]?:/) {split($5, a, ":"); print a[2]}' | sort -u)
        a_diff=("$(printf '%s\n' "${a_openports[@]}" "${a_ufwout[@]}" "${a_ufwout[@]}" | sort | uniq -u)")
    if [[ -n "${a_diff[*]}" ]]; then
        audit_log+="\n  \033[1;31;47m ** [FAIL] ** \033[0;39;49m 4.1.6 \n- The following port(s) don't have a rule in UFW: $(printf '%s\n' \\n"${a_diff[*]}")\n- End List"
        ((fail_count++))
    else
        audit_log+="\n \033[1;32;47m ** [PASS] ** \033[0;39;49m \n All open ports have a rule in UFW\n"
    fi

    if ufw status verbose | grep Default ; then

    # ========================================================================================================================
    #4.1.7 Ensure ufw default deny firewall policy
    incoming=$(echo "$default_line" | sed -n 's/.*Default: \([^,]*\),.*/\1/p' | awk '{print tolower($1)}')
    outgoing=$(echo "$default_line" | sed -n 's/.*Default: [^,]*, \([^,]*\),.*/\1/p' | awk '{print tolower($1)}')
    routed=$(echo "$default_line" | sed -n 's/.*Default: [^,]*, [^,]*, \(.*\)/\1/p' | awk '{print tolower($1)}')

    # Comprobar cada política
    if [[ "$incoming" != "disabled" && "$incoming" != "deny" && "$incoming" != "reject"]]; then
        audit_log+="\n Audit Result: \033[1;31;47m ** [FAIL] ** \033[0;39;49m - 4.1.5 - Política de entrada no es 'deny' ($incoming)"
        ((fail_count++))
    else
        audit_log+="\n Audit Result: \033[1;32;47m ** [PASS] ** \033[0;39;49m - Entrada: $incoming"
    fi

    if [[ "$outgoing" != "disabled" && "$outgoing" != "deny" && "$outgoing" != "reject" ]]; then
        audit_log+="\n Audit Result: \033[1;31;47m ** [FAIL] ** \033[0;39;49m - 4.1.5 - Política de salida no es 'deny' o 'reject' ($outgoing)"
        ((fail_count++))
    else
        audit_log+="\n Audit Result: \033[1;32;47m ** [PASS] ** \033[0;39;49m - Salida: $outgoing"
    fi

    if [[ "$routed" != "disabled" && "$routed" != "deny" && "$routed" != "reject" ]]; then
        audit_log+="\n Audit Result: \033[1;31;47m ** [FAIL] ** \033[0;39;49m - 4.1.5 - Política de ruteo no es válida ($routed)"
        ((fail_count++))
    else
        audit_log+="\n Audit Result: \033[1;32;47m ** [PASS] ** \033[0;39;49m - Ruteo: $routed"
    fi
    
else

    audit_log+="\n \033[1;31;47m ** [FAIL] ** \033[0;39;49m - 4.1.1 - UFW no está instalado"
    audit_log+="\n \033[1;33;47m ** [WARNING] ** \033[0;39;49m - 4.1.2 - No se verifica iptables-persistent porque UFW no está instalado"
    ((fail_count++))  # Solo cuenta el fallo de 4.1.1
fi

# Mostrar resultados internos
echo -e "$audit_log"

# Resultado final para el script principal
if (( fail_count == 0 )); then
    echo -e "\n Audit Result: \033[1;32;47m ** [PASS] ** \033[0;39;49m MODULO 4.1 Configure UncomplicatedFirewall - Todos los controles superados \n Recomendaciones $audit_log"
else
    echo -e "\n Audit Result: \033[1;31;47m ** [FAIL] ** \033[0;39;49m MODULO 4.1 Configure UncomplicatedFirewall - $fail_count controles fallaron \n Recomendaciones: $audit_log"
fi