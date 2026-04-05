$ErrorActionPreference = "Stop"

# 1. Configuração de Diretório Temporário
$tempDir = "$env:TEMP\SteamLivreSetup"
if (Test-Path $tempDir) { Remove-Item -Recurse -Force $tempDir }
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "       INICIANDO INSTALADOR STEAMLIVRE" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "[1/3] Baixando arquivos necessarios..." -ForegroundColor Yellow

# --- VERIFIQUE SE O NOME NO VERCEL É EXATAMENTE ESTE ---
$baseUrl = "https://packultimate.vercel.app"

try {
    # Downloads (Verifique se as letras MAIÚSCULAS/minúsculas no GitHub são iguais a estas)
    Invoke-WebRequest -Uri "$baseUrl/STEAMLIVRE.zip" -OutFile "$tempDir\STEAMLIVRE.zip" -UseBasicParsing
    Invoke-WebRequest -Uri "$baseUrl/7z.exe" -OutFile "$tempDir\7z.exe" -UseBasicParsing
    Invoke-WebRequest -Uri "$baseUrl/7z.dll" -OutFile "$tempDir\7z.dll" -UseBasicParsing
} catch {
    Write-Host "`n[ERRO] Falha ao baixar arquivos de: $baseUrl" -ForegroundColor Red
    Write-Host "Verifique se o deploy no Vercel esta ativo e se os nomes dos arquivos estao corretos." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    Exit
}

# 2. Gerar o Instalador com a ORDEM SOLICITADA
$batCode = @'
@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
title instagram @steamlivre
mode con: cols=100 lines=38
cd /d "%~dp0"

set "SENHA_ZIP=40028922"

:: Localizar Steam
for /f "tokens=3*" %%A in ('reg query "HKCU\Software\Valve\Steam" /v SteamExe 2^>nul') do set "steamExe=%%A %%B"
for %%A in ("%steamExe%") do set "steamDir=%%~dpA"
set "steamDir=%steamDir:~0,-1%"

call :Header
echo  [+] Iniciando processo de instalacao... [20%%]
powershell -Command "Get-Process steam -ErrorAction SilentlyContinue | Stop-Process -Force" >nul 2>&1
timeout /t 2 /nobreak >nul

:: PASSO 1: EXTRAÇÃO
call :Header
echo  [+] Extraindo arquivos de configuracao... [40%%]
if exist "%temp%\sl_temp" rmdir /s /q "%temp%\sl_temp"
mkdir "%temp%\sl_temp"
7z.exe x "STEAMLIVRE.zip" -p%SENHA_ZIP% -y -o"%temp%\sl_temp" -bso0 -bsp0 >nul

:: PASSO 2: DELAY DE 5 SEGUNDOS (Solicitado)
echo  [+] Arquivos extraidos. Aguardando intervalo de seguranca...
timeout /t 5 /nobreak >nul

:: PASSO 3: CÓPIA DOS ARQUIVOS
call :Header
echo  [+] Aplicando modificacoes no diretório da Steam... [70%%]
xcopy /e /i /y "%temp%\sl_temp\Config\*" "%steamDir%\config\" >nul 2>&1
copy /y "%temp%\sl_temp\Hid.dll" "%steamDir%\" >nul 2>&1
rmdir /s /q "%temp%\sl_temp" >nul
timeout /t 2 /nobreak >nul

:: PASSO 4: INSTALAÇÃO STEAMTOOLS (ATUALIZADO)
call :Header
echo  [+] Configurando Steamtools (Oculto)... [90%%]
powershell -WindowStyle Hidden -Command "iex (irm https://steam.run) *>$null"
:: Garante que a Steam nao abra sozinha antes da hora
powershell -Command "Get-Process steam -ErrorAction SilentlyContinue | Stop-Process -Force" >nul 2>&1
timeout /t 2 /nobreak >nul

:: FINALIZAÇÃO
call :Header
echo  [+] Instalacao Finalizada com Sucesso! [100%%]
start "" "%steamExe%"
start "" "https://agradecimentopmw.lovable.app"
timeout /t 5
exit /b

:Header
cls
color 0B
echo.
echo     _^|_^|_^|  _^|_^|_^|_^|_^|  _^|_^|_^|_^|    _^|_^|    _^|      _^|  
echo   _^|            _^|      _^|        _^|    _^|  _^|_^|  _^|_^|  
echo     _^|_^|        _^|      _^|_^|_^|    _^|_^|_^|_^|  _^|  _^|  _^|  
echo         _^|      _^|      _^|        _^|    _^|  _^|      _^|  
echo   _^|_^|_^|        _^|      _^|_^|_^|_^|  _^|    _^|  _^|      _^|  
echo.
echo    S  T  E  A  M    L  I  V  R  E  ---  PACK ULTIMATE
echo   =========================================================
echo.
exit /b
'@

Set-Content -Path "$tempDir\run.bat" -Value $batCode -Encoding Ascii
Write-Host "[2/3] Iniciando interface grafica..." -ForegroundColor Green
Start-Process -FilePath "$tempDir\run.bat" -Verb RunAs -Wait

# 3. Limpeza Final
Remove-Item -Recurse -Force $tempDir
Write-Host "[3/3] Processo concluido." -ForegroundColor Cyan
