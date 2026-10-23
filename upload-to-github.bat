@echo off
setlocal
cd /d "%~dp0"

echo ==========================================
echo   Little Paws  -  upload to GitHub
echo ==========================================
echo.

set "REPO=%~1"
if not "%REPO%"=="" goto haveurl
set /p "REPO=Repo URL (e.g. https://github.com/username/little-paws.git): "
:haveurl
if "%REPO%"=="" goto nourl

echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0upload-to-github.ps1" -RepoUrl "%REPO%"
if errorlevel 1 goto failed

echo.
echo Done.
pause
exit /b 0

:nourl
echo No URL given, abort.
pause
exit /b 1

:failed
echo.
echo Finished with errors, see messages above.
pause
exit /b 1
