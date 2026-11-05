# ==============================================================================
# exportar-brochure.ps1 — SOIX Solutions · Exportar Brochure a PDF
# Generación de alta calidad con Chrome headless (sin diálogos, sin rasterización)
# ==============================================================================
# USO:
#   1. Abre Live Server en VSCode (clic en "Go Live" en la barra inferior)
#      El servidor debe estar en http://localhost:5500
#   2. Doble clic en este archivo  —O—  ejecuta en PowerShell:
#      .\exportar-brochure.ps1
# ==============================================================================

$chrome     = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$url        = "http://localhost:5500/index.html"
$outputDir  = $PSScriptRoot   # Misma carpeta que este script
$fileName   = "SOIX-Brochure-Corporativo-2026.pdf"
$outputPath = Join-Path $outputDir $fileName

# --- Verificar que Chrome existe ---
if (-not (Test-Path $chrome)) {
    Write-Host "❌ No se encontró Chrome en: $chrome" -ForegroundColor Red
    Write-Host "   Ajusta la variable `$chrome en este script." -ForegroundColor Yellow
    pause; exit 1
}

# --- Verificar que el servidor local está activo ---
Write-Host ""
Write-Host "🔍 Verificando servidor local en $url ..." -ForegroundColor Cyan
try {
    $resp = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 4 -ErrorAction Stop
    Write-Host "   ✅ Servidor activo." -ForegroundColor Green
} catch {
    Write-Host ""
    Write-Host "❌ No se detectó un servidor en $url" -ForegroundColor Red
    Write-Host ""
    Write-Host "   👉 Abre VSCode → clic en 'Go Live' (barra inferior derecha)" -ForegroundColor Yellow
    Write-Host "      o ejecuta en terminal:  npx serve ." -ForegroundColor Yellow
    Write-Host ""
    pause; exit 1
}

# --- Eliminar PDF anterior si existe ---
if (Test-Path $outputPath) {
    Remove-Item $outputPath -Force
    Write-Host "🗑  PDF anterior eliminado." -ForegroundColor DarkGray
}

# --- Generar PDF con Chrome headless ---
Write-Host ""
Write-Host "🖨  Generando PDF con Chrome headless..." -ForegroundColor Cyan
Write-Host "    Origen : $url"
Write-Host "    Destino: $outputPath"
Write-Host ""

$args = @(
    "--headless=new",
    "--disable-gpu",
    "--no-sandbox",
    "--print-to-pdf=`"$outputPath`"",
    "--print-to-pdf-no-header",
    "--no-margins",
    "--run-all-compositor-stages-before-draw",
    "--virtual-time-budget=5000",   # espera 5 s para que carguen fuentes e imágenes
    $url
)

$proc = Start-Process -FilePath $chrome -ArgumentList $args -Wait -PassThru -NoNewWindow

# --- Resultado ---
if ((Test-Path $outputPath) -and ((Get-Item $outputPath).Length -gt 10KB)) {
    $size = [math]::Round((Get-Item $outputPath).Length / 1MB, 2)
    Write-Host "✅ PDF generado exitosamente:" -ForegroundColor Green
    Write-Host "   📄 $outputPath" -ForegroundColor White
    Write-Host "   📦 Tamaño: $size MB" -ForegroundColor DarkGray
    Write-Host ""

    # Abrir el PDF automáticamente
    $openPDF = Read-Host "¿Abrir el PDF ahora? (S/N)"
    if ($openPDF -match "^[Ss]") {
        Start-Process $outputPath
    }
} else {
    Write-Host "❌ El PDF no se generó correctamente. Verifica que el brochure carga bien en el navegador." -ForegroundColor Red
}

Write-Host ""
pause

