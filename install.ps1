# ==========================================
# Configurações do Script
# ==========================================

# Substitua pela URL base do seu projeto na Vercel
$baseUrl = "https://pack27k.vercel.app"

# Pasta oculta no computador do usuário onde tudo vai acontecer
$pastaDestino = "$env:TEMP\MeuPrograma"

# Nomes exatos dos seus arquivos
$nomeExe = "adicionar.exe"
$nomeZip = "config.zip"

# ==========================================
# Preparando o terreno
# ==========================================

Write-Host "Preparando ambiente..." -ForegroundColor Cyan

# Cria a pasta principal onde tudo será salvo, caso não exista
if (-Not (Test-Path $pastaDestino)) {
    New-Item -ItemType Directory -Path $pastaDestino | Out-Null
}

# ==========================================
# Baixando os arquivos
# ==========================================

Write-Host "Baixando o Executável (adicionar.exe)..." -ForegroundColor Cyan
$caminhoExe = "$pastaDestino\$nomeExe"
Invoke-WebRequest -Uri "$baseUrl/$nomeExe" -OutFile $caminhoExe

Write-Host "Baixando as configurações (config.zip)..." -ForegroundColor Cyan
$caminhoZip = "$pastaDestino\$nomeZip"
Invoke-WebRequest -Uri "$baseUrl/$nomeZip" -OutFile $caminhoZip

# ==========================================
# Extração e Limpeza
# ==========================================

Write-Host "Extraindo pasta de configurações..." -ForegroundColor Cyan
# Extrai o conteúdo do config.zip na mesma pasta onde está o adicionar.exe
Expand-Archive -Path $caminhoZip -DestinationPath $pastaDestino -Force

# Apaga o arquivo config.zip original para limpar o PC do usuário
Remove-Item -Path $caminhoZip -Force

# ==========================================
# Execução
# ==========================================

Write-Host "Iniciando o programa..." -ForegroundColor Green
Start-Process -FilePath $caminhoExe
