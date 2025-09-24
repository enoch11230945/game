@tool
extends EditorScript

func _run():
    var theme = Theme.new()

    # Define Colors
    var primary_color = Color.from_string("#dfe6e9", Color.WHITE)
    var accent_color = Color.from_string("#0984e3", Color.BLUE)
    var panel_color = Color.from_string("#2d3436", Color.BLACK)
    var panel_border_color = Color.from_string("#636e72", Color.GRAY)

    # Style PanelContainer (used by UpgradeCard)
    var panel_style = StyleBoxFlat.new()
    panel_style.bg_color = panel_color
    panel_style.border_width_top = 2
    panel_style.border_width_bottom = 2
    panel_style.border_width_left = 2
    panel_style.border_width_right = 2
    panel_style.border_color = panel_border_color
    panel_style.corner_radius_top_left = 5
    panel_style.corner_radius_top_right = 5
    panel_style.corner_radius_bottom_left = 5
    panel_style.corner_radius_bottom_right = 5
    theme.set_stylebox("panel", "PanelContainer", panel_style)

    # Style Button
    var button_normal_style = StyleBoxFlat.new()
    button_normal_style.bg_color = accent_color
    button_normal_style.corner_radius_top_left = 3
    button_normal_style.corner_radius_top_right = 3
    button_normal_style.corner_radius_bottom_left = 3
    button_normal_style.corner_radius_bottom_right = 3
    theme.set_stylebox("normal", "Button", button_normal_style)
    
    var button_hover_style = StyleBoxFlat.new()
    button_hover_style.bg_color = accent_color.lighten(0.2)
    button_hover_style.corner_radius_top_left = 3
    button_hover_style.corner_radius_top_right = 3
    button_hover_style.corner_radius_bottom_left = 3
    button_hover_style.corner_radius_bottom_right = 3
    theme.set_stylebox("hover", "Button", button_hover_style)

    var button_pressed_style = StyleBoxFlat.new()
    button_pressed_style.bg_color = accent_color.darken(0.2)
    button_pressed_style.corner_radius_top_left = 3
    button_pressed_style.corner_radius_top_right = 3
    button_pressed_style.corner_radius_bottom_left = 3
    button_pressed_style.corner_radius_bottom_right = 3
    theme.set_stylebox("pressed", "Button", button_pressed_style)
    
    theme.set_color("font_color", "Button", primary_color)
    theme.set_color("font_hover_color", "Button", primary_color)
    theme.set_color("font_pressed_color", "Button", primary_color)

    # Style Label
    theme.set_color("font_color", "Label", primary_color)
    theme.set_constant("line_spacing", "Label", 3)

    # Save the theme
    var path = "res://src/ui/theme/main_theme.tres"
    var error = ResourceSaver.save(theme, path)
    if error == OK:
        print("Successfully generated and saved theme to: ", path)
    else:
        print("Error saving theme: ", error)
