extends CanvasLayer
class_name SquishyHUD

var proximity_label: Label
var progress_label: Label

func _ready() -> void:
    var overlay := Control.new()
    overlay.name = "Overlay"
    overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(overlay)
    overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var top_panel := PanelContainer.new()
    top_panel.position = Vector2(22, 22)
    top_panel.custom_minimum_size = Vector2(372, 179)
    _set_panel_style(top_panel)
    overlay.add_child(top_panel)
    var vbox := VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 5)
    top_panel.add_child(vbox)
    _add_label(vbox, "SQUISHY WORLD", 28, Color("3b756a"))
    _add_label(vbox, "ŽELÉ LÚKA · PROTOTYP 0.2", 15, Color("6c8d83"))
    _add_label(vbox, "WASD / šípky · E = stretnutie", 17, Color("3e625c"))
    _add_label(vbox, "Matematika: stlač 1, 2, 3 alebo 4", 15, Color("55786a"))
    progress_label = _add_label(vbox, "Ročník 2 · zbierka 0/5", 16, Color("476f66"))
    var bottom_panel := PanelContainer.new()
    bottom_panel.anchor_top = 1.0
    bottom_panel.anchor_bottom = 1.0
    bottom_panel.offset_left = 22.0
    bottom_panel.offset_top = -80.0
    bottom_panel.offset_right = 480.0
    bottom_panel.offset_bottom = -22.0
    _set_panel_style(bottom_panel)
    overlay.add_child(bottom_panel)
    proximity_label = Label.new()
    proximity_label.add_theme_font_size_override("font_size", 17)
    proximity_label.add_theme_color_override("font_color", Color("41675e"))
    proximity_label.text = "Preskúmaj lúku a nájdi Squishies!"
    bottom_panel.add_child(proximity_label)
    var tag := Label.new()
    tag.anchor_left = 1.0
    tag.anchor_right = 1.0
    tag.offset_left = -360.0
    tag.offset_right = -18.0
    tag.offset_top = 28.0
    tag.add_theme_color_override("font_color", Color("547e71"))
    tag.add_theme_font_size_override("font_size", 17)
    tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    tag.text = "Výzvy: Launcher a Jelly Merge"
    overlay.add_child(tag)

func set_progress(grade: int, caught: int) -> void:
    if progress_label != null:
        progress_label.text = "Ročník %d · zbierka %d/5" % [grade, caught]

func set_nearby(value: String) -> void:
    if proximity_label != null and proximity_label.text != value:
        proximity_label.text = value

func _set_panel_style(panel: PanelContainer) -> void:
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.98, 0.99, 0.94, 0.94)
    style.border_color = Color("cce8d7")
    style.set_border_width_all(2)
    style.set_corner_radius_all(20)
    style.content_margin_left = 18.0
    style.content_margin_top = 12.0
    style.content_margin_right = 18.0
    style.content_margin_bottom = 12.0
    panel.add_theme_stylebox_override("panel", style)

func _add_label(box: VBoxContainer, value: String, font_size: int, tint: Color) -> Label:
    var label := Label.new()
    label.text = value
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", tint)
    box.add_child(label)
    return label
