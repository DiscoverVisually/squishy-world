extends Node2D
class_name WildSquishy

var display_name: String = "Squishy"
var body_color: Color = Color("ffc1dc")
var home: Vector2 = Vector2.ZERO
var phase: float = 0.0
var seed_offset: float = 0.0

func configure(new_name: String, tint: Color, origin: Vector2, index: int) -> void:
    display_name = new_name
    body_color = tint
    home = origin
    seed_offset = float(index) * 1.71
    position = origin

func _process(delta: float) -> void:
    phase += delta
    position = home + Vector2(sin(phase * 0.85 + seed_offset) * 28.0, cos(phase * 0.65 + seed_offset) * 16.0)
    queue_redraw()

func _draw() -> void:
    var bounce := sin(phase * 3.3 + seed_offset) * 3.0
    draw_circle(Vector2(0, 21), 23.0, Color(0.22, 0.47, 0.32, 0.15))
    draw_set_transform(Vector2(0.0, bounce - 7.0), 0.0, Vector2(1.0 + sin(phase * 3.3) * 0.035, 1.0 - sin(phase * 3.3) * 0.035))
    draw_circle(Vector2(-14, -17), 7.0, body_color.darkened(0.12))
    draw_circle(Vector2(15, -17), 7.0, body_color.darkened(0.12))
    draw_circle(Vector2.ZERO, 27.0, body_color.darkened(0.12))
    draw_circle(Vector2(0, -4), 26.0, body_color)
    draw_circle(Vector2(-8, -12), 12.0, Color(1.0, 1.0, 1.0, 0.24))
    for x in [-10.0, 10.0]:
        draw_circle(Vector2(x, 2), 6.7, Color("fffefa"))
        draw_circle(Vector2(x + 1, 3), 4.2, Color("354052"))
        draw_circle(Vector2(x - 1, 0), 1.7, Color.WHITE)
    draw_arc(Vector2(0, 10), 6.2, 0.2, PI - 0.2, 12, Color("745565"), 2.0, true)
    draw_set_transform()
