#!/bin/bash

################################################################################
# Script: Instalador de Dependencias - Sistemas Arch
# Descripcion: Instala dependencias necesarias para Nmap Manager
# Version: 2.0
################################################################################

# Verificar permisos de root
if [ "$EUID" -ne 0 ]; then
    echo -e "\033[31m[ERROR] Este script requiere permisos de root\033[0m"
    echo -e "\033[33m[INFO] Ejecute: sudo $0\033[0m"
    exit 1
fi

echo ""
echo -e "\033[33m========================================\033[0m"
echo -e "\033[33m  Instalador de Dependencias - Arch    \033[0m"
echo -e "\033[33m========================================\033[0m"
echo ""

# Actualizar sistema
echo -e "\033[33m[-] Actualizando sistema y base de datos de paquetes...\033[0m"
pacman -Syu --noconfirm

if [ $? -ne 0 ]; then
    echo -e "\033[31m[ERROR] No se pudo actualizar el sistema\033[0m"
    exit 1
fi

echo -e "\033[32m[OK] Sistema actualizado correctamente\033[0m"
echo ""

# Instalar dependencias
echo -e "\033[33m[-] Instalando dependencias: nmap, figlet, tree\033[0m"
pacman -S --noconfirm nmap figlet tree

if [ $? -eq 0 ]; then
    echo ""
    echo -e "\033[32m========================================\033[0m"
    echo -e "\033[32m[OK] Dependencias instaladas correctamente\033[0m"
    echo -e "\033[32m========================================\033[0m"
    echo ""
    exit 0
else
    echo ""
    echo -e "\033[31m========================================\033[0m"
    echo -e "\033[31m[ERROR] Fallo la instalacion de dependencias\033[0m"
    echo -e "\033[31m========================================\033[0m"
    echo ""
    exit 1
fi