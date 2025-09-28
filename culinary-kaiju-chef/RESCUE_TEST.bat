@echo off
echo 🚑 RESCUE TEST - Testing basic functionality

echo Setting main scene to rescue test...
copy project.godot project.godot.backup
powershell -Command "(Get-Content project.godot) -replace 'run/main_scene=\"res://src/main/main.tscn\"', 'run/main_scene=\"res://RESCUE_TEST.tscn\"' | Set-Content project.godot"

echo Running rescue test...
"..\Godot_v4.5-stable_win64.exe" --headless --quit-after 10 .

echo Restoring original project settings...
move project.godot.backup project.godot

echo Test completed. Check output above for results.
pause