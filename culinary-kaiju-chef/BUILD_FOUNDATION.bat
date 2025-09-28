@echo off
echo === BUILDING PROPER FOUNDATION ===

REM Create directory structure based on Linus approved blueprint
mkdir src
mkdir src\core
mkdir src\core\data
mkdir src\autoload
mkdir src\ui
mkdir src\ui\screens
mkdir src\managers

mkdir features
mkdir features\player
mkdir features\enemies
mkdir features\weapons

mkdir assets
mkdir assets\textures
mkdir assets\audio
mkdir assets\fonts

echo Foundation directories created.
echo Next: We'll build ONE system at a time, properly.
echo Starting with the most basic EventBus...

pause