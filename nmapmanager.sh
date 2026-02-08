#!/bin/bash

################################################################################
# Script: Nmap Manager - Herramienta de Auditorias de Red
# Autor: Network Security Auditor
# Descripcion: Sistema de gestion para auditorias de red automatizadas usando Nmap
# Version: 2.0
################################################################################

# Constantes de configuracion
readonly VERSION="2.0"
readonly LOG_DIR="logs"
readonly METADATA_FILE="audit_metadata.log"

################################################################################
# Funcion: verificar_permisos
# Descripcion: Verifica que el script se ejecute con privilegios de root
# Parametros: Ninguno
# Retorno: Exit 1 si no tiene permisos, continua si los tiene
################################################################################
verificar_permisos() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "\033[31m[ERROR] Este script requiere permisos de root para funcionar correctamente\033[0m"
        echo -e "\033[33m[INFO] Por favor ejecute: sudo $0\033[0m"
        exit 1
    fi
}

################################################################################
# Funcion: crear_estructura_logs
# Descripcion: Crea la estructura de directorios para logs si no existe
# Parametros: Ninguno
# Retorno: 0 si exitoso
################################################################################
crear_estructura_logs() {
    if [ ! -d "$LOG_DIR" ]; then
        mkdir -p "$LOG_DIR"
    fi
}

################################################################################
# Funcion: registrar_inicio_auditoria
# Descripcion: Registra metadata del inicio de auditoria
# Parametros: Ninguno
# Retorno: 0 si exitoso
################################################################################
registrar_inicio_auditoria() {
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local usuario=$(whoami)
    local nmap_version=$(nmap --version | head -n1)
    
    echo "========================================" >> "$LOG_DIR/$METADATA_FILE"
    echo "Inicio de sesion de auditoria" >> "$LOG_DIR/$METADATA_FILE"
    echo "Timestamp: $timestamp" >> "$LOG_DIR/$METADATA_FILE"
    echo "Usuario: $usuario" >> "$LOG_DIR/$METADATA_FILE"
    echo "Version del script: $VERSION" >> "$LOG_DIR/$METADATA_FILE"
    echo "$nmap_version" >> "$LOG_DIR/$METADATA_FILE"
    echo "========================================" >> "$LOG_DIR/$METADATA_FILE"
}

################################################################################
# Funcion: instalar_dependencias
# Descripcion: Menu para seleccionar e instalar dependencias segun el sistema
# Parametros: Ninguno
# Retorno: 0 si exitoso, 1 si error
################################################################################
instalar_dependencias() {
    until [ "$host" = "3" ]
    do
        clear
        echo -e "\e[1;31m$(cat log/log-requeriments)\e[0m"
        echo ""
        echo -e "\033[33m[-] Sistemas operativos disponibles:\033[0m"
        echo ""
        echo "[1] Debian / Ubuntu / Kali linux"
        echo "[2] BlackArch / Arch linux"
        echo "[3] Volver al menu principal"
        echo ""
        read -p "[-] Seleccione su sistema operativo: " host
        echo ""
        
        case $host in
            "1")
                bash scripts/requeriments-deb.sh
                if [ $? -eq 0 ]; then
                    clear
                    echo -e "\033[32m[OK] Dependencias instaladas correctamente\033[0m"
                    echo ""
                    registrar_accion "Dependencias instaladas - Sistema Debian"
                else
                    echo -e "\033[31m[ERROR] Fallo la instalacion de dependencias\033[0m"
                    echo ""
                fi
                break
                ;;
            "2")
                bash scripts/requeriments-arch.sh
                if [ $? -eq 0 ]; then
                    clear
                    echo -e "\033[32m[OK] Dependencias instaladas correctamente\033[0m"
                    echo ""
                    registrar_accion "Dependencias instaladas - Sistema Arch"
                else
                    echo -e "\033[31m[ERROR] Fallo la instalacion de dependencias\033[0m"
                    echo ""
                fi
                break
                ;;
            "3")
                clear
                echo -e "\033[31m[-] Regresando al menu principal...\033[0m"
                echo ""
                ;;
            *)
                clear
                echo -e "\033[31m[ERROR] Opcion no valida: $REPLY\033[0m"
                echo ""
                ;;
        esac
    done
}

################################################################################
# Funcion: registrar_accion
# Descripcion: Registra acciones del usuario en el log
# Parametros: $1 - Descripcion de la accion
# Retorno: 0 si exitoso
################################################################################
registrar_accion() {
    local accion="$1"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $accion" >> "$LOG_DIR/$METADATA_FILE"
}

################################################################################
# Funcion: menu_principal
# Descripcion: Muestra el menu principal de la aplicacion
# Parametros: Ninguno
# Retorno: 0 al salir correctamente
################################################################################
menu_principal() {
    clear
    
    until [ "$opcion" = "2" ]
    do
        bash scripts/log.sh
        
        echo ""
        echo -e "\033[33m[-] Asegurese de ejecutar este script con permisos de root\033[0m"
        echo ""
        echo -e "\033[33m[-] Menu principal de opciones:\033[0m"
        echo ""
        echo "[0] Instalar dependencias"
        echo "[1] Auditorias de red con Nmap"
        echo "[2] Salir"
        echo ""
        read -p "[-] Seleccione una opcion: " opcion
        
        echo ""
        
        case $opcion in
            "0")
                instalar_dependencias
                ;;
            "1")
                clear
                echo ""
                
                registrar_accion "Inicio de auditoria de red"
                
                sudo bash scripts/opt1.sh
                
                if [ $? -eq 0 ]; then
                    clear
                    echo -e "\033[32m[OK] Auditoria completada correctamente\033[0m"
                    echo ""
                    registrar_accion "Auditoria finalizada exitosamente"
                else
                    clear
                    echo -e "\033[31m[ERROR] La auditoria finalizo con errores\033[0m"
                    echo ""
                    registrar_accion "Auditoria finalizada con errores"
                fi
                ;;


            "2")
                registrar_accion "Cierre de sesion normal"
                echo -e "\033[31m[-] Saliendo del menu, gracias por usar Nmap Manager v$VERSION\033[0m"
                echo ""
                ;;


            *)
                clear
                echo -e "\033[31m[ERROR] Opcion no valida: $REPLY\033[0m"
                echo ""
                ;;
        esac
    done
}

################################################################################
# PUNTO DE ENTRADA PRINCIPAL
################################################################################

# Verificar permisos de root
verificar_permisos

# Crear estructura de directorios
crear_estructura_logs

# Registrar inicio de auditoria
registrar_inicio_auditoria

# Ejecutar menu principal
menu_principal

# Fin del script
exit 0
