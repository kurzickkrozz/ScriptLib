taskkill /f /im explorer.exe
cd %userprofile%\appdata\local
del /F /Q IconCache.db
start explorer.exe
exit