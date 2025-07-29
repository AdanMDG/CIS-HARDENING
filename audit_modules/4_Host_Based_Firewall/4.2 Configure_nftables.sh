#!/bin/bash
# CIS Audit - Verificar que nftables este instalado 

fail_count=0
audit_log=""

# ========================================================================================================================
# 4.1.1 Ensure ufw is installed
if dpkg-query -s nftables | grep 'Status: install ok installed'; then
        audit_log+="\n \033[1;32;47m ** [PASS] ** \033[0;39;49m - 4.1.1 - UFW está instalado"

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