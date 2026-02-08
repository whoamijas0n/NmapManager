#!/bin/bash

################################################################################
# Script: Instalador de Dependencias - Sistemas Arch
# Autor: Network Security Auditor
# Descripcion: Instala todas las dependencias necesarias para Nmap Manager
#              en sistemas basados en Arch (BlackArch, Manjaro, etc.)
# Version: 2.0
# Fecha: $(date +%Y-%m-%d)
################################################################################

################################################################################
# Funcion: verificar_root
# Descripcion: Verifica que el script se ejecute con privilegios de root
# Parametros: Ninguno
# Retorno: Exit 1 si no tiene permisos
################################################################################
verificar_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "\033[31m[ERROR] Este script requiere permisos de root\033[0m"
        echo -e "\033[33m[INFO] Ejecute: sudo $0\033[0m"
        exit 1
    fi
}

################################################################################
# Funcion: actualizar_sistema
# Descripcion: Actualiza el sistema y la base de datos de paquetes
# Parametros: Ninguno
# Retorno: 0 si exitoso, codigo de error si falla
################################################################################
actualizar_sistema() {
    echo -e "\033[33m[-] Actualizando sistema y base de datos de paquetes...\033[0m"
    
    pacman -Syu --noconfirm
    
    if [ $? -eq 0 ]; then
        echo -e "\033[32m[OK] Sistema actualizado correctamente\033[0m"
        echo ""
        return 0
    else
        echo -e "\033[31m[ERROR] Fallo la actualizacion del sistema\033[0m"
        echo ""
        return 1
    fi
}

################################################################################
# Funcion: instalar_paquete
# Descripcion: Instala un paquete y verifica su instalacion
# Parametros: $1 - Nombre del paquete
# Retorno: 0 si exitoso, 1 si falla
################################################################################
instalar_paquete() {
    local paquete="$1"
    
    echo -e "\033[33m[-] Instalando $paquete...\033[0m"
    
    pacman -S --noconfirm "$paquete"
    
    if [ $? -eq 0 ]; then
        echo -e "\033[32m[OK] $paquete instalado correctamente\033[0m"
        echo ""
        return 0
    else
        echo -e "\033[31m[ERROR] Fallo la instalacion de $paquete\033[0m"
        echo ""
        return 1
    fi
}

################################################################################
# Funcion: verificar_instalacion
# Descripcion: Verifica que un comando este disponible en el sistema
# Parametros: $1 - Comando a verificar
# Retorno: 0 si existe, 1 si no existe
################################################################################
verificar_instalacion() {
    local comando="$1"
    
    if command -v "$comando" &> /dev/null; then
        local version=$($comando --version 2>&1 | head -n1)
        echo -e "\033[32m[OK] $comando esta disponible: $version\033[0m"
        return 0
    else
        echo -e "\033[31m[ERROR] $comando no esta disponible\033[0m"
        return 1
    fi
}

################################################################################
# PUNTO DE ENTRADA PRINCIPAL
################################################################################

echo ""
echo -e "\033[33m========================================\033[0m"
echo -e "\033[33m  Instalador de Dependencias - Arch    \033[0m"
echo -e "\033[33m========================================\033[0m"
echo ""

# Verificar permisos de root
verificar_root

# Actualizar sistema
actualizar_sistema

if [ $? -ne 0 ]; then
    echo -e "\033[31m[ERROR] No se pudo actualizar el sistema\033[0m"
    echo -e "\033[33m[INFO] Verifique su conexion a internet y repositorios\033[0m"
    exit 1
fi

# Lista de paquetes a instalar
declare -a paquetes=(
    "nmap"
    "figlet"
    "tree"
    "macchanger"
)

# Contador de errores
errores=0

# Instalar cada paquete
for paquete in "${paquetes[@]}"; do
    instalar_paquete "$paquete"
    if [ $? -ne 0 ]; then
        ((errores++))
    fi
done

echo ""
echo -e "\033[33m========================================\033[0m"
echo -e "\033[33m      Verificando instalaciones        \033[0m"
echo -e "\033[33m========================================\033[0m"
echo ""

# Verificar instalaciones
verificar_instalacion "nmap"
verificar_instalacion "figlet"
verificar_instalacion "tree"
verificar_instalacion "macchanger"


echo ""

# Resumen final
if [ $errores -eq 0 ]; then
    echo -e "\033[32m========================================\033[0m"
    echo -e "\033[32m[OK] Todas las dependencias se instalaron correctamente\033[0m"
    echo -e "\033[32m========================================\033[0m"
    echo ""
    exit 0
else
    echo -e "\033[31m========================================\033[0m"
    echo -e "\033[31m[ADVERTENCIA] Se encontraron $errores error(es) durante la instalacion\033[0m"
    echo -e "\033[31m========================================\033[0m"
    echo ""
    exit 1
fi
