@echo off
echo 🧹🎮🏆 LAUNCHING LINUS-APPROVED CLEAN GAME 🏆🎮🧹
echo.
echo Following prd3.txt requirements:
echo ✅ Single main scene: src/main/main.tscn
echo ✅ Data-driven architecture: All values from .tres resources
echo ✅ EventBus communication: No direct node references
echo ✅ Clean project structure: features/ eliminated
echo.
echo Starting Culinary Kaiju Chef - Data-Driven Edition...
echo.

cd /d "%~dp0"
"..\Godot_v4.5-stable_win64.exe" --path . "src/main/main.tscn"

pause