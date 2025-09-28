@echo off
echo 🚑 EMERGENCY DIAGNOSTIC TEST
echo.
echo Testing minimal Godot project...
echo.

"..\Godot_v4.5-stable_win64.exe\Godot_v4.5-stable_win64_console.exe" --path . --headless --quit-after 5

echo.
echo Test completed. Check output above for errors.
echo.
pause