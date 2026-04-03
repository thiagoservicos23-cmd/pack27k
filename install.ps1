# =================================================================
# SCRIPT OTIMIZADO: DOWNLOAD E EXTRAÇÃO RÁPIDA
# =================================================================

# 1. Configurações (Substitua pela sua URL da Vercel)
$baseUrl = "https://seu-projeto.vercel.app"
$pastaDestino = "$env:TEMP\MeuPrograma"
$nomeExe = "adicionar.exe"
$nomeZip = "config.zip"

# 2. Criar diretório se não existir (Silencioso)
if (-Not (Test-Path $pastaDestino)) {
    New-Item -ItemType Directory -Path $pastaDestino -Force | Out-Null
}

Write-Host "--- Iniciando Processo ---" -ForegroundColor Cyan

# 3. Download dos arquivos em paralelo (Inicia o download do ZIP e do EXE)
Write-Host "[1/3] Baixando arquivos da Vercel..." -ForegroundColor Yellow
$caminhoExe = Join-Path $pastaDestino $nomeExe
$caminhoZip = Join-Path $pastaDestino $nomeZip

try {
    Invoke-WebRequest -Uri "$baseUrl/$nomeExe" -OutFile $caminhoExe -ErrorAction Stop
    Invoke-WebRequest -Uri "$baseUrl/$nomeZip" -OutFile $caminhoZip -ErrorAction Stop
} catch {
    Write-Host "ERRO: Não foi possível baixar os arquivos. Verifique a URL." -ForegroundColor Red
    break
}

# 4. Extração Otimizada (Método Shell.Application)
# Este método é mais rápido que o Expand-Archive convencional
Write-Host "[2/3] Extraindo configurações (Modo Turbo)..." -ForegroundColor Yellow

try {
    $shell = New-Object -ComObject Shell.Application
    $zipItem = $shell.NameSpace($caminhoZip)
    $destinoItem = $shell.NameSpace($pastaDestino)
    
    # O parâmetro 16 ignora barras de progresso e confirmações, acelerando o processo
    $destinoItem.CopyHere($zipItem.Items(), 16)
    
    # Pequena pausa para garantir que o Windows liberou o arquivo
    Start-Sleep -Seconds 1 
    Remove-Item -Path $caminhoZip -Force
} catch {
    Write-Host "Aviso: Falha na extração rápida, tentando método comum..." -ForegroundColor Gray
    Expand-Archive -Path $caminhoZip -DestinationPath $pastaDestino -Force
}

# 5. Execução final
Write-Host "[3/3] Abrindo $nomeExe..." -ForegroundColor Green
if (Test-Path $caminhoExe) {
    Set-Location -Path $pastaDestino
    Start-Process -FilePath ".\$nomeExe"
} else {
    Write-Host "ERRO: Executável não encontrado." -ForegroundColor Red
}

Write-Host "--- Concluído ---" -ForegroundColor Cyan
