@echo off
echo === NUCLEAR RESET TEST ===
echo Starting basic compilation test...

cd /d "C:\Users\fello\Desktop\game\culinary-kaiju-chef"

echo Testing project compilation...
"C:\Users\fello\Desktop\game\Godot_v4.5-stable_win64.exe\Godot_v4.5-stable_win64.exe" --headless --quit-after 5

echo.
echo === TEST COMPLETE ===
echo If you see no critical errors above, the project structure is fixed!
pause