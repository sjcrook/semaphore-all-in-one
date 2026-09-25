@echo off
REM Check if OpenSSL is installed (requirement)
openssl version >nul 2>&1
if %errorlevel% neq 0 (
    echo Violation: OpenSSL is required for this script to run. Please install it first.
    exit /b 1
)

set MYPWD=%cd%
set WHOAMI=%USERNAME%
set OUTDIR=C:\temp\semaphore-%WHOAMI%
set TMPDIR=C:\temp

REM Check if output directory exists, if so, exit
if exist %OUTDIR% (
    echo Violation: Directory %OUTDIR% already exists. It seems you  already have created keys/certificates.
    echo Script execution stopped.
    echo Recommendation: Please manually remove the directory %OUTDIR% before running this script.
    exit /b 1
)

mkdir %OUTDIR%
set /p FULLNAME=Enter your fullname: 
echo User: %FULLNAME% > %OUTDIR%\userinfo.txt

openssl genrsa -out %OUTDIR%\semaphore-yum.key 2048
icacls %OUTDIR%\semaphore-yum.key /inheritance:r /grant:r %USERNAME%:R
openssl req -new -x509 -nodes -sha256 -days 3650 -key %OUTDIR%\semaphore-yum.key -out %OUTDIR%\semaphore-yum.cert
icacls %OUTDIR%\semaphore-yum.cert /inheritance:r /grant:r %USERNAME%:R

for /f "tokens=2-6 delims== " %%a in ('openssl x509 -enddate -noout -in %OUTDIR%\semaphore-yum.cert') do set EXPIRY=%%a %%b %%c %%d %%e
echo Expiry: %EXPIRY% >> %OUTDIR%\userinfo.txt

cd %TMPDIR%
powershell -command "Compress-Archive -Path semaphore-%WHOAMI%\* -DestinationPath %OUTDIR%\semaphore-%WHOAMI%.zip"
cd %MYPWD%

echo.
echo Files created:
echo --------------
echo %OUTDIR%\semaphore-yum.key
echo %OUTDIR%\semaphore-yum.cert
echo %OUTDIR%\userinfo.txt
echo %OUTDIR%\semaphore-%WHOAMI%.zip