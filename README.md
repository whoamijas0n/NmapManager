# Nmap Manager

Sistema profesional de gestión para auditorías de red automatizadas utilizando Nmap. Nmap Manager facilita la ejecución de escaneos de seguridad de red, organizando los resultados de manera estructurada y generando reportes completos en formato HTML.

p align="center">


  <img src="img/image.png" alt="Imagen de el menu de Nmap Manager" width="850">


</p>

## Características Principales

- **13 Tipos de Escaneos Especializados**: Desde descubrimiento de hosts hasta auditorías SSL/TLS
- **Validación Inteligente**: Valida automáticamente IPs, rangos CIDR, rangos con guión y hostnames
- **Sistema de Logging Completo**: Registra metadata detallada de cada escaneo (timestamp, usuario, comando ejecutado, códigos de salida)
- **Reportes Profesionales**: Genera automáticamente reportes HTML con resumen ejecutivo de la auditoría
- **Organización Automática**: Crea estructura de directorios organizada por tipo de escaneo
- **Múltiples Formatos de Salida**: Guarda resultados en formato texto, XML y grepable
- **Escaneos Optimizados**: Utiliza parámetros de velocidad (-T4) y rate limiting (--min-rate=1000)
- **Manejo Robusto de Errores**: Captura y registra códigos de salida con mensajes descriptivos
- **Instalación Automática de Dependencias**: Detecta el sistema operativo e instala lo necesario

## Menu de Opciones de Escaneo

El script ofrece un menú interactivo con las siguientes opciones de auditoría:

```
[0]  Descubrimiento de hosts activos
[1]  Escaneo de puertos comunes (Top 1000)
[2]  Escaneo completo de puertos TCP (0-65535)
[3]  Escaneo de servicios y versiones
[4]  Detección de sistemas operativos
[5]  Escaneo UDP (puertos comunes)
[6]  Escaneo de vulnerabilidades con NSE
[7]  Escaneo agresivo completo
[8]  Detección de firewall/IDS
[9]  Scripts específicos de servicios (HTTP, SSH, SMB, FTP)
[10] Auditoría de SSL/TLS
[11] Traceroute de red
[12] Escaneo completo automatizado (secuencia completa)
[13] Finalizar y generar resumen
```

## Instalación

### Clonar el Repositorio

```bash
git clone https://github.com/whoamijas0n/nmap_manager
cd nmap_manager
```

### Ejecutar el Script

```bash
sudo bash nmapmanager.sh
```

**Importante**: Este script **requiere permisos de root** para funcionar correctamente, ya que muchos escaneos de Nmap necesitan privilegios elevados.

### Uso Posterior

Para volver a utilizar el script simplemente ejecuta:

```bash
cd nmap_manager
sudo bash nmapmanager.sh
```

## Dependencias

El script requiere las siguientes herramientas:

- **nmap**: Herramienta principal de escaneo de red
- **figlet**: Para mostrar banners ASCII
- **tree**: Para visualización de estructura de directorios

### Instalación Automática

Puedes instalar todas las dependencias directamente desde el menú principal del script:

1. Ejecuta el script principal: `sudo bash nmapmanager.sh`
2. Selecciona la opción `[0] Instalar dependencias`
3. Elige tu sistema operativo:
   - `[1]` Para Debian / Ubuntu / Kali Linux
   - `[2]` Para BlackArch / Arch Linux

### Instalación Manual

**Sistemas Debian/Ubuntu/Kali:**
```bash
sudo bash scripts/requeriments-deb.sh
```

**Sistemas Arch/BlackArch:**
```bash
sudo bash scripts/requeriments-arch.sh
```

## Ejemplos de Uso

### Escaneo Básico de una IP

1. Ejecuta el script: `sudo bash nmapmanager.sh`
2. Selecciona `[1] Auditorías de red con Nmap`
3. Ingresa la IP objetivo: `192.168.1.100`
4. Selecciona el tipo de escaneo deseado

### Escaneo de un Rango de Red

1. Ejecuta el script
2. Selecciona auditorías de red
3. Ingresa el rango en formato CIDR: `192.168.1.0/24`
4. Elige los escaneos que necesites

### Auditoría Completa Automatizada

1. Ejecuta el script
2. Ingresa el objetivo
3. Selecciona la opción `[12] Escaneo completo automatizado`
4. El script ejecutará secuencialmente:
   - Descubrimiento de hosts
   - Escaneo completo de puertos
   - Detección de servicios
   - Identificación de sistema operativo
   - Búsqueda de vulnerabilidades

## Formatos de Entrada Soportados

El script acepta los siguientes formatos de objetivos:

- **IP Simple**: `192.168.1.1`
- **Rango CIDR**: `192.168.1.0/24`
- **Rango con Guión**: `192.168.1.1-254`
- **Hostname**: `example.com` o `scanme.nmap.org`

## Sistema de Logging

Cada auditoría genera logs detallados que incluyen:

- Timestamp de inicio y fin de cada escaneo
- Usuario que ejecutó la auditoría
- Versión de Nmap utilizada
- Comandos exactos ejecutados
- Códigos de salida de cada operación
- Historial completo de la sesión

Los logs se almacenan en:
- `logs/audit_metadata.log` - Metadata general de sesiones
- `[Directorio_Auditoria]/scan_metadata.txt` - Metadata específica de cada auditoría

## Reportes HTML

Al finalizar una auditoría con la opción `[13]`, el script genera automáticamente un reporte HTML profesional que incluye:

- Resumen ejecutivo de la auditoría
- Información del objetivo escaneado
- Lista de todos los escaneos realizados
- Enlaces a todos los archivos de resultados
- Timestamp y metadata completa
- Estadísticas de la auditoría

El reporte se guarda como `audit_summary.html` dentro del directorio de la auditoría.


## Optimizaciones de Velocidad

El script incluye optimizaciones para reducir el tiempo de escaneo:

- **Timing Template T4**: Balance entre velocidad y precisión
- **Min Rate 1000**: Mínimo de 1000 paquetes por segundo
- **Paralelización**: Nmap gestiona múltiples hosts simultáneamente

**Nota**: Los escaneos completos (opción 2 y 12) pueden tardar considerablemente dependiendo del tamaño de la red.

## Avisos Legales

 **IMPORTANTE**: Esta herramienta está diseñada para auditorías de seguridad autorizadas únicamente.

- **Solo** utiliza este script en redes y sistemas para los que tengas **autorización explícita**
- El escaneo no autorizado de redes es **ilegal** en muchas jurisdicciones
- El autor no se responsabiliza por el uso indebido de esta herramienta
- Utilízalo de manera ética y responsable

## Solución de Problemas

### El script no inicia
- Verifica que tienes permisos de root: `sudo bash nmapmanager.sh`
- Asegúrate de que todos los archivos tengan permisos de ejecución: `chmod +x *.sh scripts/*.sh`

### Errores durante los escaneos
- Verifica que Nmap esté instalado: `nmap --version`
- Comprueba que la IP/rango ingresado sea válido
- Revisa los logs en `logs/audit_metadata.log` para detalles

### Dependencias no se instalan
- Verifica tu conexión a internet
- Comprueba que los repositorios estén actualizados
- Ejecuta manualmente el instalador correspondiente a tu sistema


---

## Licencia y Autor

Este proyecto ha sido creado por **Jason Caballero (whoamijas0n)**.



