#!/bin/bash
# Debian 12 CIS Benchmark Hardening Script
# Autor: Adan Matias Diaz Graziano
# Fecha: 02/07/25
# Uso: Ejecutar como root

#\e[1;32;47m \e[1;32;47m \e[1;39;49m

#==============================#
#         CONFIGURACION        #
#==============================#
#audit.log registra todo
LOG_FILE="/home/debian-adan/Desktop/Tesis/CIS-HARDENING/logs/audit.log"
CIS_SECTION="$1"

function log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

function check_root() {
    if [[ "$EUID" -ne 0 ]]; then
        echo "Este script debe ejecutarse como root." >&2
        exit 1
    fi
}

#==============================#
#      SECCION 1: INICIO       #
#==============================#

function update_system() {
    log "Actualizando el sistema y los paquetes base"
    apt update && apt upgrade -y
    echo -e ">>> [Sistema y paquetes base actualizados] <<<"
}

#==============================#
#         AUDITORIA            #
#==============================#

# Ejecutar todos los scripts de test recursivamente
function audit_modulos() {
    TEMP_PASS_COUNT=$(mktemp)
    TEMP_FAIL_COUNT=$(mktemp)
    TEMP_TOTAL=$(mktemp)

    echo 0 > "$TEMP_PASS_COUNT"
    echo 0 > "$TEMP_FAIL_COUNT"
    echo 0 > "$TEMP_TOTAL"

    TEST_DIR="./audit_modules"
    echo -e "\3[1;34;47m RESULTADO DE LA AUDITORIA \e[1;39;49m "
    find "$TEST_DIR" -type f -name "*.sh" | while read -r script; do
        echo -e "\e[33m==============================\e[0m"
        output=$(bash "$script")
        echo -e "\033[34m Auditando => $script => $output \033[0m"
        echo -e "\e[33m==============================\e[0m"
        if echo "$output" | grep -q "PASS"; then
            pass=$(<"$TEMP_PASS_COUNT")
            echo $((pass + 1)) > "$TEMP_PASS_COUNT"
        elif echo "$output" | grep -q "FAIL"; then
            fail=$(<"$TEMP_FAIL_COUNT")
            echo $((fail + 1)) > "$TEMP_FAIL_COUNT"
        fi
        
        total=$(<"$TEMP_TOTAL")
        echo $((total + 1)) > "$TEMP_TOTAL"
    done

    FAIL_COUNT=$(<"$TEMP_FAIL_COUNT")
    PASS_COUNT=$(<"$TEMP_PASS_COUNT")
    TOTAL=$(<"$TEMP_TOTAL")
    
    log "==== RESULTADOS ===="
    log " Totales: $TOTAL"
    log " OK (PASS): $PASS_COUNT"
    log " Fallos (FAIL): $FAIL_COUNT"

    if (( TOTAL > 0 )); then
        SCORE=$(( PASS_COUNT * 100 / TOTAL ))
        log " Puntaje de cumplimiento: $SCORE%"
        log "[$(date)] Score: $SCORE% ($PASS_COUNT/$TOTAL)" >> /var/log/test_score.log
    else
        log "Sin tests ejecutados."
    fi
    echo -e ">>> [Auditoria finalizada] <<<"
}

#==============================#
#         HARDENING            #
#==============================#

function hardening_modulos() {
    TEST_DIR="./hardening_modules"
    find "$TEST_DIR" -type f -name "*.sh" | while read -r script; do
        echo -e "\e[33m==============================\e[0m"
        echo -e "\e[33m Hardenizando => $script \e[0m"
        echo -e "\e[33m==============================\e[0m"
        bash "$script" </dev/tty
    done
    echo -e ">>> [Hardening finalizado] <<<"
}


#==============================#
#        MENU PRINCIPAL        #
#==============================#

function mostrar_ayuda() {
    echo "Uso: $0 [seccion]"
    echo "Secciones disponibles:"
    echo "  update_system      -> Actualizar sistema y paquetes base"
    echo "  audit              -> Audita el sistema "
    echo "  hardening          -> Hardeniza el sistema "
    echo "  todo               -> Ejecutar todo"
}

function ejecutar_todo() {
    update_system
    audit
    hardening
    audit
}

#==============================#
#         EJECUCION            #
#==============================#

check_root

case "$CIS_SECTION" in
    update_system) update_system ;;
    audit) audit_modulos ;;
    hardening) hardening_modulos ;;
    todo) ejecutar_todo ;;
    *) mostrar_ayuda ;;
esac

