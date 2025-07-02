#!/bin/bash
# Debian 12 CIS Benchmark Hardening Script
# Autor: Adan Matias Diaz Graziano
# Fecha: 02/07/25
# Uso: Ejecutar como root

#==============================#
#         CONFIGURACION        #
#==============================#
#audit.log registra todo
LOG_FILE="/var/log/audit.log"
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

function inicio() {
    log "Iniciando script de hardening..."
    apt update && apt upgrade -y
}

#==============================#
#         AUDITORIA            #
#==============================#

# Ejecutar todos los scripts de test recursivamente
function audit_modulos() {
    TEST_DIR="./audit_modules"
    find "$TEST_DIR" -type f -name "*.sh" | while read -r script; do
        echo -e "\e[33m==============================\e[0m"
        echo -e "\e[33m Auditando => $script \e[0m"
        echo -e "\e[33m==============================\e[0m"
        bash "$script"
    done
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
        bash "$script"
    done
}


#==============================#
#        MENU PRINCIPAL        #
#==============================#

function mostrar_ayuda() {
    echo "Uso: $0 [seccion]"
    echo "Secciones disponibles:"
    echo "  inicio             -> Actualizar sistema y paquetes base"
    echo "  audit              -> Audita el sistema "
    echo "  hardening          -> Hardeniza el sistema "
    echo "  todo               -> Ejecutar todo"
}

function ejecutar_todo() {
    inicio
    audit
    hardening
    audit
}

#==============================#
#         EJECUCION            #
#==============================#

check_root

case "$CIS_SECTION" in
    inicio) inicio ;;
    audit) audit_modulos ;;
    hardening) hardening_modulos ;;
    todo) ejecutar_todo ;;
    *) mostrar_ayuda ;;
esac

log "Script finalizado."
