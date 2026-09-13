@echo off
setlocal
cd /d "%~dp0.."
call "%~dp0run_v209_final_acceptance.bat"
exit /b %ERRORLEVEL%
