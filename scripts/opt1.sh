#!/bin/bash

################################################################################
# Script: Nmap Menu - Menu de escaneos de auditoria
# Autor: Network Security Auditor
# Descripcion: Menu interactivo para ejecutar diferentes tipos de escaneos Nmap
# Version: 2.0
# Fecha: $(date +%Y-%m-%d)
################################################################################

# Constantes de configuracion
readonly SCAN_SPEED="-T4"
readonly MIN_RATE="--min-rate=1000"
readonly OUTPUT_FORMATS="-oN"
readonly METADATA_FILE="scan_metadata.txt"
readonly SUMMARY_FILE="audit_summary.html"

################################################################################
# Funcion: validar_ip
# Descripcion: Valida que la entrada sea una IP valida o rango de IPs
# Parametros: $1 - IP o rango a validar
# Retorno: 0 si valido, 1 si invalido
################################################################################
validar_ip() {
    local ip_input="$1"
    
    # Validar IP simple (formato xxx.xxx.xxx.xxx)
    if [[ $ip_input =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        return 0
    fi
    
    # Validar rango CIDR (formato xxx.xxx.xxx.xxx/xx)
    if [[ $ip_input =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}$ ]]; then
        return 0
    fi
    
    # Validar rango con guion (formato xxx.xxx.xxx.xxx-xxx)
    if [[ $ip_input =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}-[0-9]{1,3}$ ]]; then
        return 0
    fi
    
    # Validar hostname
    if [[ $ip_input =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$ ]]; then
        return 0
    fi
    
    return 1
}

################################################################################
# Funcion: solicitar_ip
# Descripcion: Solicita y valida la IP o rango a escanear
# Parametros: Ninguno
# Retorno: IP validada en variable global $ip
################################################################################
solicitar_ip() {
    local ip_valida=false
    
    while [ "$ip_valida" = false ]; do
        read -p "[-] Ingrese la IP, hostname o rango a escanear: " ip
        
        if validar_ip "$ip"; then
            ip_valida=true
            echo -e "\033[32m[OK] Objetivo validado: $ip\033[0m"
            echo ""
        else
            echo ""
            echo -e "\033[31m[ERROR] Formato invalido. Ejemplos validos:\033[0m"
            echo "  - IP simple: 192.168.1.1"
            echo "  - Rango CIDR: 192.168.1.0/24"
            echo "  - Rango: 192.168.1.1-254"
            echo "  - Hostname: example.com"
            echo ""
        fi
    done
}

################################################################################
# Funcion: crear_estructura_auditoria
# Descripcion: Crea la estructura de directorios para la auditoria
# Parametros: Ninguno
# Retorno: 0 si exitoso
################################################################################
crear_estructura_auditoria() {
    local fecha=$(date +%Y-%m-%d_%H-%M-%S)
    AUDIT_DIR="Auditoria_${fecha}"
    
    mkdir -p "$AUDIT_DIR"
    
    if [ $? -ne 0 ]; then
        echo -e "\033[31m[ERROR] No se pudo crear el directorio de auditoria\033[0m"
        exit 1
    fi
    
    echo -e "\033[32m[OK] Directorio de auditoria creado: $AUDIT_DIR\033[0m"
}

################################################################################
# Funcion: registrar_metadata
# Descripcion: Registra metadata del escaneo en archivo
# Parametros: $1 - Tipo de escaneo, $2 - Comando ejecutado, $3 - Codigo de salida
# Retorno: 0 si exitoso
################################################################################
registrar_metadata() {
    local tipo_escaneo="$1"
    local comando="$2"
    local codigo_salida="$3"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local nmap_version=$(nmap --version | head -n1)
    
    cat >> "$AUDIT_DIR/$METADATA_FILE" << EOF
========================================
Tipo de escaneo: $tipo_escaneo
Timestamp: $timestamp
Target: $ip
Comando ejecutado: $comando
Codigo de salida: $codigo_salida
$nmap_version
Usuario: $(whoami)
========================================

EOF
}

################################################################################
# Funcion: ejecutar_escaneo
# Descripcion: Ejecuta un escaneo y maneja errores
# Parametros: $1 - Comando nmap, $2 - Nombre del escaneo, $3 - Directorio
# Retorno: 0 si exitoso, codigo de error si falla
################################################################################
ejecutar_escaneo() {
    local comando="$1"
    local nombre="$2"
    local directorio="$3"
    
    echo -e "\033[31m[-] Iniciando $nombre...\033[0m"
    echo -e "\033[33m[-] Comando: $comando\033[0m"
    echo ""
    
    eval $comando
    local exit_code=$?
    
    registrar_metadata "$nombre" "$comando" "$exit_code"
    
    if [ $exit_code -eq 0 ]; then
        clear
        echo -e "\033[32m[OK] $nombre completado exitosamente\033[0m"
        echo -e "\033[32m[-] Resultados guardados en: $AUDIT_DIR/$directorio\033[0m"
        echo ""
        return 0
    else
        echo -e "\033[31m[ERROR] $nombre finalizo con errores (codigo: $exit_code)\033[0m"
        echo ""
        return $exit_code
    fi
}

################################################################################
# Funcion: generar_resumen_html
# Descripcion: Genera un resumen HTML de todos los escaneos realizados
# Parametros: Ninguno
# Retorno: 0 si exitoso
################################################################################
generar_resumen_html() {
    local html_file="$AUDIT_DIR/$SUMMARY_FILE"
    local fecha=$(date +"%Y-%m-%d %H:%M:%S")
    
    cat > "$html_file" << 'EOF'
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Resumen de Auditoria de Red</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f4f4f4;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #2c3e50;
            border-bottom: 3px solid #3498db;
            padding-bottom: 10px;
        }
        h2 {
            color: #34495e;
            margin-top: 30px;
        }
        .info-box {
            background: #ecf0f1;
            padding: 15px;
            border-left: 4px solid #3498db;
            margin: 20px 0;
        }
        .scan-item {
            background: #fff;
            border: 1px solid #ddd;
            padding: 15px;
            margin: 10px 0;
            border-radius: 4px;
        }
        .scan-item h3 {
            margin-top: 0;
            color: #2980b9;
        }
        .file-list {
            list-style-type: none;
            padding-left: 0;
        }
        .file-list li {
            padding: 8px;
            background: #f8f9fa;
            margin: 5px 0;
            border-radius: 3px;
        }
        .footer {
            margin-top: 40px;
            padding-top: 20px;
            border-top: 1px solid #ddd;
            color: #7f8c8d;
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Resumen de Auditoria de Red</h1>
        
        <div class="info-box">
            <strong>Fecha de auditoria:</strong> FECHA_PLACEHOLDER<br>
            <strong>Objetivo:</strong> TARGET_PLACEHOLDER<br>
            <strong>Directorio:</strong> DIRECTORY_PLACEHOLDER
        </div>
        
        <h2>Escaneos Realizados</h2>
        <div id="scans-container">
            SCANS_PLACEHOLDER
        </div>
        
        <h2>Archivos Generados</h2>
        <ul class="file-list">
            FILES_PLACEHOLDER
        </ul>
        
        <div class="footer">
            <p>Generado por Nmap Manager v2.0</p>
            <p>Para mas informacion, consulte los archivos individuales de cada escaneo</p>
        </div>
    </div>
</body>
</html>
EOF

    # Reemplazar placeholders
    sed -i "s/FECHA_PLACEHOLDER/$fecha/g" "$html_file"
    sed -i "s/TARGET_PLACEHOLDER/$ip/g" "$html_file"
    sed -i "s/DIRECTORY_PLACEHOLDER/$AUDIT_DIR/g" "$html_file"
    
    # Generar lista de escaneos y archivos
    local scans_html=""
    local files_html=""
    
    for dir in "$AUDIT_DIR"/*/; do
        if [ -d "$dir" ]; then
            local scan_name=$(basename "$dir")
            scans_html+="<div class='scan-item'><h3>$scan_name</h3></div>"
            
            for file in "$dir"*; do
                if [ -f "$file" ]; then
                    files_html+="<li>$(basename "$file")</li>"
                fi
            done
        fi
    done
    
    sed -i "s|SCANS_PLACEHOLDER|$scans_html|g" "$html_file"
    sed -i "s|FILES_PLACEHOLDER|$files_html|g" "$html_file"
    
    echo -e "\033[32m[OK] Resumen HTML generado: $html_file\033[0m"
}

################################################################################
# Funcion: generar_indice
# Descripcion: Genera un archivo indice con todos los escaneos realizados
# Parametros: Ninguno
# Retorno: 0 si exitoso
################################################################################
generar_indice() {
    local indice_file="$AUDIT_DIR/INDICE.txt"
    
    cat > "$indice_file" << EOF
================================================================================
                    INDICE DE AUDITORIA DE RED
================================================================================

Fecha: $(date +"%Y-%m-%d %H:%M:%S")
Objetivo: $ip
Directorio: $AUDIT_DIR

================================================================================
ESTRUCTURA DE DIRECTORIOS:
================================================================================

EOF

    tree -L 2 "$AUDIT_DIR" >> "$indice_file" 2>/dev/null || find "$AUDIT_DIR" -type f >> "$indice_file"
    
    cat >> "$indice_file" << EOF

================================================================================
RESUMEN DE ESCANEOS:
================================================================================

EOF

    if [ -f "$AUDIT_DIR/$METADATA_FILE" ]; then
        cat "$AUDIT_DIR/$METADATA_FILE" >> "$indice_file"
    fi
    
    echo -e "\033[32m[OK] Indice generado: $indice_file\033[0m"
}

################################################################################
# Funcion: menu_escaneos
# Descripcion: Muestra el menu de tipos de escaneo disponibles
# Parametros: Ninguno
# Retorno: 0 al salir
################################################################################
menu_escaneos() {
    until [ "$optScan" = "13" ]
    do
        echo -e "\e[1;31m$(cat log/log1)\e[0m"
        echo ""
        echo -e "\033[33m[-] Seleccione el tipo de escaneo que desea realizar\033[0m"
        echo ""
        echo -e "\033[33m[-] Menu de opciones:\033[0m"
        echo ""
        echo "[0]  Descubrimiento de hosts"
        echo "[1]  Escaneo de puertos comunes"
        echo "[2]  Escaneo completo de puertos TCP (optimizado)"
        echo "[3]  Escaneo de servicios y versiones"
        echo "[4]  Deteccion de sistemas operativos"
        echo "[5]  Escaneo UDP (puertos comunes)"
        echo "[6]  Escaneo de vulnerabilidades con NSE"
        echo "[7]  Escaneo agresivo completo"
        echo "[8]  Deteccion de firewall/IDS"
        echo "[9]  Scripts especificos de servicios"
        echo "[10] Auditoria de SSL/TLS"
        echo "[11] Traceroute de red"
        echo "[12] Escaneo completo automatizado"
        echo "[13] Finalizar y generar resumen"
        echo ""
        read -p "[-] Seleccione una opcion: " optScan
        echo ""
        
        cd "$AUDIT_DIR" || exit 1
        
        case $optScan in
            "0")
                # Descubrimiento de hosts
                mkdir -p 00_HostDiscovery
                ejecutar_escaneo \
                    "nmap -sn $ip -oN 00_HostDiscovery/hosts.txt -oX 00_HostDiscovery/hosts.xml -oG 00_HostDiscovery/hosts.grep" \
                    "Descubrimiento de hosts" \
                    "00_HostDiscovery"
                cd ..
                ;;
                
            "1")
                # Escaneo de puertos comunes
                mkdir -p 01_CommonPorts
                ejecutar_escaneo \
                    "nmap -sS $SCAN_SPEED --top-ports 1000 $ip -oN 01_CommonPorts/ports.txt -oX 01_CommonPorts/ports.xml" \
                    "Escaneo de puertos comunes" \
                    "01_CommonPorts"
                cd ..
                ;;
                
            "2")
                # Escaneo completo TCP optimizado
                mkdir -p 02_FullTCP
                ejecutar_escaneo \
                    "nmap -sS -p- $SCAN_SPEED $MIN_RATE $ip -oN 02_FullTCP/full_tcp.txt -oX 02_FullTCP/full_tcp.xml" \
                    "Escaneo completo de puertos TCP" \
                    "02_FullTCP"
                cd ..
                ;;
                
            "3")
                # Escaneo de servicios y versiones
                mkdir -p 03_ServiceVersion
                ejecutar_escaneo \
                    "nmap -sV --version-intensity 5 $ip -oN 03_ServiceVersion/services.txt -oX 03_ServiceVersion/services.xml" \
                    "Escaneo de servicios y versiones" \
                    "03_ServiceVersion"
                cd ..
                ;;
                
            "4")
                # Deteccion de SO
                mkdir -p 04_OSDetection
                ejecutar_escaneo \
                    "nmap -O --osscan-guess $ip -oN 04_OSDetection/os.txt -oX 04_OSDetection/os.xml" \
                    "Deteccion de sistema operativo" \
                    "04_OSDetection"
                cd ..
                ;;
                
            "5")
                # Escaneo UDP
                mkdir -p 05_UDPScan
                ejecutar_escaneo \
                    "nmap -sU --top-ports 100 $SCAN_SPEED $ip -oN 05_UDPScan/udp.txt -oX 05_UDPScan/udp.xml" \
                    "Escaneo UDP" \
                    "05_UDPScan"
                cd ..
                ;;
                
            "6")
                # Escaneo de vulnerabilidades
                mkdir -p 06_VulnScan
                ejecutar_escaneo \
                    "nmap --script vuln,exploit $ip -oN 06_VulnScan/vuln.txt -oX 06_VulnScan/vuln.xml" \
                    "Escaneo de vulnerabilidades NSE" \
                    "06_VulnScan"
                cd ..
                ;;
                
            "7")
                # Escaneo agresivo
                mkdir -p 07_AggressiveScan
                ejecutar_escaneo \
                    "nmap -A -p- $SCAN_SPEED $ip -oN 07_AggressiveScan/aggressive.txt -oX 07_AggressiveScan/aggressive.xml" \
                    "Escaneo agresivo completo" \
                    "07_AggressiveScan"
                cd ..
                ;;
                
            "8")
                # Deteccion de Firewall/IDS
                mkdir -p 08_FirewallDetection
                ejecutar_escaneo \
                    "nmap -sA -p 80,443,22,21,25 $ip -oN 08_FirewallDetection/firewall.txt -oX 08_FirewallDetection/firewall.xml" \
                    "Deteccion de Firewall/IDS" \
                    "08_FirewallDetection"
                cd ..
                ;;
                
            "9")
                # Scripts especificos de servicios
                mkdir -p 09_ServiceScripts
                ejecutar_escaneo \
                    "nmap --script http-enum,ssh-auth-methods,smb-enum-shares,ftp-anon $ip -oN 09_ServiceScripts/service_scripts.txt -oX 09_ServiceScripts/service_scripts.xml" \
                    "Scripts especificos de servicios" \
                    "09_ServiceScripts"
                cd ..
                ;;
                
            "10")
                # Auditoria SSL/TLS
                mkdir -p 10_SSL_TLS
                ejecutar_escaneo \
                    "nmap --script ssl-enum-ciphers,ssl-cert,ssl-date,ssl-heartbleed -p 443,8443 $ip -oN 10_SSL_TLS/ssl_audit.txt -oX 10_SSL_TLS/ssl_audit.xml" \
                    "Auditoria SSL/TLS" \
                    "10_SSL_TLS"
                cd ..
                ;;
                
            "11")
                # Traceroute
                mkdir -p 11_Traceroute
                ejecutar_escaneo \
                    "nmap --traceroute $ip -oN 11_Traceroute/traceroute.txt -oX 11_Traceroute/traceroute.xml" \
                    "Traceroute de red" \
                    "11_Traceroute"
                cd ..
                ;;
                
            "12")
                # Escaneo automatizado completo
                echo -e "\033[33m[INFO] Ejecutando bateria completa de escaneos...\033[0m"
                echo -e "\033[33m[ADVERTENCIA] Esto puede tomar mucho tiempo\033[0m"
                echo ""
                read -p "[-] Desea continuar? (s/n): " confirmacion
                
                if [ "$confirmacion" = "s" ] || [ "$confirmacion" = "S" ]; then
                    mkdir -p 12_AutomatedScan
                    
                    # Ejecutar secuencia de escaneos
                    ejecutar_escaneo \
                        "nmap -sn $ip -oN 12_AutomatedScan/01_discovery.txt" \
                        "Fase 1: Descubrimiento" \
                        "12_AutomatedScan"
                    
                    ejecutar_escaneo \
                        "nmap -sS -p- $SCAN_SPEED $MIN_RATE $ip -oN 12_AutomatedScan/02_all_ports.txt" \
                        "Fase 2: Todos los puertos" \
                        "12_AutomatedScan"
                    
                    ejecutar_escaneo \
                        "nmap -sV -sC $ip -oN 12_AutomatedScan/03_services.txt" \
                        "Fase 3: Servicios y scripts" \
                        "12_AutomatedScan"
                    
                    ejecutar_escaneo \
                        "nmap -O $ip -oN 12_AutomatedScan/04_os.txt" \
                        "Fase 4: Sistema operativo" \
                        "12_AutomatedScan"
                    
                    ejecutar_escaneo \
                        "nmap --script vuln $ip -oN 12_AutomatedScan/05_vulnerabilities.txt" \
                        "Fase 5: Vulnerabilidades" \
                        "12_AutomatedScan"
                else
                    echo -e "\033[31m[-] Escaneo automatizado cancelado\033[0m"
                    echo ""
                fi
                cd ..
                ;;
                
            "13")
                clear
                echo -e "\033[32m[-] Finalizando auditoria...\033[0m"
                echo ""
                cd ..
                generar_indice
                generar_resumen_html
                echo ""
                echo -e "\033[32m[OK] Auditoria completada\033[0m"
                echo -e "\033[32m[-] Resultados en: $AUDIT_DIR\033[0m"
                echo -e "\033[32m[-] Resumen HTML: $AUDIT_DIR/$SUMMARY_FILE\033[0m"
                echo ""
                ;;
                
            *)
                clear
                cd ..
                echo -e "\033[31m[ERROR] Opcion no valida: $REPLY\033[0m"
                echo ""
                ;;
        esac
    done
}

################################################################################
# PUNTO DE ENTRADA PRINCIPAL
################################################################################

clear
echo -e "\e[1;31m$(cat log/log1)\e[0m"
echo ""

# Solicitar y validar IP
solicitar_ip

clear

# Crear estructura de auditoria
crear_estructura_auditoria
echo ""

# Ejecutar menu de escaneos
menu_escaneos

# Fin del script
exit 0
