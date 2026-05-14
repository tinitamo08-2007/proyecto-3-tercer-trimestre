# =====================================================================
#  Descarga automatica de las librerias necesarias para Granja Digital.
#
#  Uso:
#    1. Doble clic NO funciona en PowerShell por seguridad. En su lugar:
#    2. Boton derecho sobre este archivo -> "Ejecutar con PowerShell"
#       (si Windows lo bloquea, abre PowerShell como admin y ejecuta:
#         Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
#        y luego ejecuta este script).
#
#  Tambien puedes ejecutarlo desde una terminal:
#    powershell -ExecutionPolicy Bypass -File .\descargar_librerias.ps1
# =====================================================================

$ErrorActionPreference = "Stop"
$libDir = Join-Path $PSScriptRoot "lib"

if (-not (Test-Path $libDir)) {
    New-Item -ItemType Directory -Path $libDir | Out-Null
}

# Pares: URL -> nombre del archivo destino
$archivos = @(
    @("https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/9.0.0/mysql-connector-j-9.0.0.jar",                       "mysql-connector-j-9.0.0.jar"),
    @("https://repo1.maven.org/maven2/org/apache/poi/poi/5.2.5/poi-5.2.5.jar",                                              "poi-5.2.5.jar"),
    @("https://repo1.maven.org/maven2/org/apache/poi/poi-ooxml/5.2.5/poi-ooxml-5.2.5.jar",                                  "poi-ooxml-5.2.5.jar"),
    @("https://repo1.maven.org/maven2/org/apache/poi/poi-ooxml-lite/5.2.5/poi-ooxml-lite-5.2.5.jar",                        "poi-ooxml-lite-5.2.5.jar"),
    @("https://repo1.maven.org/maven2/org/apache/commons/commons-collections4/4.4/commons-collections4-4.4.jar",            "commons-collections4-4.4.jar"),
    @("https://repo1.maven.org/maven2/commons-io/commons-io/2.15.1/commons-io-2.15.1.jar",                                  "commons-io-2.15.1.jar"),
    @("https://repo1.maven.org/maven2/org/apache/commons/commons-compress/1.26.0/commons-compress-1.26.0.jar",              "commons-compress-1.26.0.jar"),
    @("https://repo1.maven.org/maven2/commons-codec/commons-codec/1.16.1/commons-codec-1.16.1.jar",                         "commons-codec-1.16.1.jar"),
    @("https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-api/2.22.1/log4j-api-2.22.1.jar",                      "log4j-api-2.22.1.jar"),
    @("https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-core/2.22.1/log4j-core-2.22.1.jar",                    "log4j-core-2.22.1.jar"),
    @("https://repo1.maven.org/maven2/com/zaxxer/SparseBitSet/1.3/SparseBitSet-1.3.jar",                                    "SparseBitSet-1.3.jar"),
    @("https://repo1.maven.org/maven2/org/apache/xmlbeans/xmlbeans/5.2.0/xmlbeans-5.2.0.jar",                               "xmlbeans-5.2.0.jar"),
    @("https://repo1.maven.org/maven2/com/itextpdf/itextpdf/5.5.13.3/itextpdf-5.5.13.3.jar",                                "itextpdf-5.5.13.3.jar"),
    @("https://repo1.maven.org/maven2/org/apache/commons/commons-math3/3.6.1/commons-math3-3.6.1.jar",                      "commons-math3-3.6.1.jar"),
    @("https://repo1.maven.org/maven2/org/apache/poi/poi-scratchpad/5.2.5/poi-scratchpad-5.2.5.jar",                        "poi-scratchpad-5.2.5.jar"),
    @("https://repo1.maven.org/maven2/org/apache/commons/commons-lang3/3.13.0/commons-lang3-3.13.0.jar",                    "commons-lang3-3.13.0.jar")
)

Write-Host ""
Write-Host "Descargando $($archivos.Count) librerias a $libDir..." -ForegroundColor Cyan
Write-Host ""

$ok = 0
$fallos = @()

foreach ($par in $archivos) {
    $url = $par[0]
    $nombre = $par[1]
    $destino = Join-Path $libDir $nombre

    if (Test-Path $destino) {
        Write-Host "  [skip] $nombre (ya existe)" -ForegroundColor DarkGray
        $ok++
        continue
    }

    Write-Host ("  [..  ] " + $nombre) -NoNewline
    try {
        # Usamos TLS 1.2 explicito por compatibilidad con sistemas viejos.
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $url -OutFile $destino -UseBasicParsing
        Write-Host "`r  [OK  ] $nombre" -ForegroundColor Green
        $ok++
    } catch {
        Write-Host "`r  [FAIL] $nombre" -ForegroundColor Red
        Write-Host "         $($_.Exception.Message)" -ForegroundColor DarkRed
        $fallos += $nombre
    }
}

Write-Host ""
Write-Host "Resumen: $ok / $($archivos.Count) librerias listas." -ForegroundColor Cyan
if ($fallos.Count -gt 0) {
    Write-Host ""
    Write-Host "Fallaron $($fallos.Count) librerias. Descargalas a mano desde:" -ForegroundColor Yellow
    foreach ($f in $fallos) {
        Write-Host "  - $f" -ForegroundColor Yellow
    }
}
Write-Host ""
Write-Host "Cuando termine, en Eclipse: boton derecho en el proyecto -> Refresh (F5)." -ForegroundColor Cyan
Write-Host "Pulsa una tecla para cerrar..."
[void][System.Console]::ReadKey($true)
