extends Node2D
class_name EncounterChoice

signal selected(mode: String)
signal cancelled

var active: bool = false
var creature_name: String = ""
var creature_color: Color = Color("f5c6d9")

func _ready() -> void:
    visible = false

func show_choice(name: String, tint: Color) -> void:
    creature_name = name
    creature_color = tint
    active = true
    visible = true
    queue_redraw()

func close_choice() -> void:
    active = false
    visible = false

func _choose(mode: String) -> void:
    close_choice()
    selected.emit(mode)

func _unhandled_input(event: InputEvent) -> void:
    if not active:
        return
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_1:
            _choose("launcher")
        elif event.keycode == KEY_2:
            _choose("merge")
        elif event.keycode == KEY_ESCAPE:
            close_choice()
            cancelled.emit()
        else:
            return
        get_viewport().set_input_as_handled()
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        var pos: Vector2 = get_global_mouse_position()
        if Rect2(210, 315, 400, 220).has_point(pos):
            _choose("launcher")
        elif Rect2(662, 315, 400, 220).has_point(pos):
            _choose("merge")
        elif Rect2(1090, 85, 135, 56).has_point(pos):
            close_choice()
            cancelled.emit()
        get_viewport().set_input_as_handled()

func _draw() -> void:
    if not active:
        return
    var f: Font = ThemeDB.fallback_font
    draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), Color(0.22, 0.34, 0.34, 0.90))
    draw_rect(Rect2(177, 142, 926, 450), Color("fff9e9"))
    draw_rect(Rect2(187, 152, 906, 430), Color("edf5e7"))
    draw_string(f, Vector2(247, 222), "STRETOL SI %s!" % creature_name.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 39, Color("53786a"))
    draw_string(f, Vector2(245, 276), "Vyber výzvu a získaj nového Squishyho.", HORIZONTAL_ALIGNMENT_LEFT, -1, 25, Color("6c6277"))
    draw_rect(Rect2(210, 315, 400, 220), Color("f8d5e7"))
    draw_rect(Rect2(662, 315, 400, 220), Color("d3e8f5"))
    draw_circle(Vector2(410, 374), 30, creature_color)
    draw_circle(Vector2(395, 368), 6, Color.WHITE)
    draw_circle(Vector2(426, 368), 6, Color.WHITE)
    draw_string(f, Vector2(255, 447), "1  SQUISHY LAUNCHER", HORIZONTAL_ALIGNMENT_LEFT, -1, 25, Color("765065"))
    draw_string(f, Vector2(250, 494), "Mier a traf správny výsledok", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("77566a"))
    draw_circle(Vector2(862, 372), 31, Color("ffd9aa"))
    draw_circle(Vector2(825, 387), 21, Color("b5e4f7"))
    draw_circle(Vector2(902, 387), 20, Color("e7c8f3"))
    draw_string(f, Vector2(743, 447), "2  JELLY MERGE", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color("596681"))
    draw_string(f, Vector2(720, 494), "Púšťaj a spájaj želé čísla", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("5b7187"))
    draw_string(f, Vector2(384, 564), "Stlač 1 alebo 2, alebo klikni na kartu.", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("668375"))
    draw_rect(Rect2(1090, 85, 135, 56), Color("f6d9e0"))
    draw_string(f, Vector2(1110, 122), "SPÄŤ", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("795465"))
