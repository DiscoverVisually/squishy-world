extends CharacterBody2D

const MOVE_SPEED: float = 245.0
const MAP_RECT: Rect2 = Rect2(56.0, 62.0, 1936.0, 1412.0)
var animation_clock: float = 0.0
var moving_strength: float = 0.0
var facing: float = 1.0

func _physics_process(delta: float) -> void:
    var direction := Vector2.ZERO
    if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
        direction.x -= 1.0
    if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
        direction.x += 1.0
    if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
        direction.y -= 1.0
    if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
        direction.y += 1.0
    velocity = direction.normalized() * MOVE_SPEED
    move_and_slide()
    global_position = global_position.clamp(MAP_RECT.position, MAP_RECT.end)
    moving_strength = move_toward(moving_strength, minf(1.0, velocity.length() / MOVE_SPEED), delta * 6.0)
    if absf(direction.x) > 0.1:
        facing = signf(direction.x)
    animation_clock += delta * (5.0 + 9.0 * moving_strength)
    queue_redraw()

func _draw() -> void:
    var wobble := sin(animation_clock)
    var hop := maxf(0.0, wobble) * 8.0 * moving_strength
    var squash := 1.0 - 0.08 * moving_strength * absf(wobble)
    var stretch := 1.0 + 0.11 * moving_strength * absf(wobble)
    draw_set_transform(Vector2(0, 29), 0.0, Vector2(1.0 + hop * 0.01, 1.0))
    draw_circle(Vector2.ZERO, 27.0, Color(0.24, 0.52, 0.40, 0.17))
    draw_set_transform(Vector2(0, -5.0 - hop), 0.0, Vector2(stretch, squash))
    draw_circle(Vector2(-18, -22), 10.0, Color("4daaa0"))
    draw_circle(Vector2(19, -23), 10.0, Color("4daaa0"))
    draw_circle(Vector2(0, 2), 33.0, Color("4aada5"))
    draw_circle(Vector2(0, -3), 31.0, Color("79dac4"))
    draw_circle(Vector2(-4, -9), 27.0, Color("a4edcf"))
    draw_circle(Vector2(-12, -15), 14.0, Color(1.0, 1.0, 1.0, 0.20))
    for eye_x in [-12.0, 12.0]:
        draw_circle(Vector2(eye_x, 2), 8.6, Color("fffdf8"))
        draw_circle(Vector2(eye_x + facing * 1.5, 3), 5.8, Color("25384a"))
        draw_circle(Vector2(eye_x - 1, 0), 2.2, Color.WHITE)
    draw_circle(Vector2(-22, 14), 5.2, Color("f5a8ac"))
    draw_circle(Vector2(22, 14), 5.2, Color("f5a8ac"))
    draw_arc(Vector2(0, 10), 7.2, 0.2, PI - 0.2, 16, Color("67455d"), 2.7, true)
    draw_set_transform()
