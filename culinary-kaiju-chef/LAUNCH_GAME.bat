@echo off
echo.
echo 🍳🐉 === LAUNCHING CULINARY KAIJU CHEF === 🐉🍳
echo.
echo Built with Linus Torvalds Philosophy:
echo "Good programmers worry about data structures and their relationships."
echo.
echo Controls:
echo   WASD: Move
echo   Enter: Spawn enemies (test)
echo   Space: Level up (test)
echo   1/2/3: Choose upgrades
echo   Escape: Restart
echo.
echo Starting game...
echo.

cd /d "%~dp0"
"..\Godot_v4.5-stable_win64.exe" --path . PERFECT_GAME.tscn

echo.
echo Game closed. Press any key to exit...
pause > nul