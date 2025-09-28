@echo off
echo === NUCLEAR RESET - LINUS STYLE ===
echo Preserving source templates and documentation...

REM Create clean backup
if exist "culinary-kaiju-chef-BROKEN" (
    rmdir /s /q "culinary-kaiju-chef-BROKEN"
)
mkdir "culinary-kaiju-chef-BROKEN"

REM Backup the broken state for reference
if exist "src" xcopy /s /e /y "src" "culinary-kaiju-chef-BROKEN\src\"
if exist "features" xcopy /s /e /y "features" "culinary-kaiju-chef-BROKEN\features\"
if exist "assets" xcopy /s /e /y "assets" "culinary-kaiju-chef-BROKEN\assets\"

echo Creating minimal working foundation...

REM Clear everything except source templates and docs
for /d %%i in (src features assets addons .godot) do (
    if exist "%%i" rmdir /s /q "%%i"
)

REM Remove all generated files but keep docs and source templates
del /f /q *.gd 2>nul
del /f /q *.tscn 2>nul
del /f /q *.tres 2>nul

echo Clean slate ready. Now we build it RIGHT.
echo Next: Run BUILD_FOUNDATION.bat

pause