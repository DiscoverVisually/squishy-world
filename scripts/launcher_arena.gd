extends Node2D
class_name LauncherArena

signal captured(squishy_name: String)
signal cancelled

const MathChallenges = preload("res://scripts/math_challenges.gd")
const START_POINT: Vector2 = Vector2(170, 544)
const SPEED: float = 845.0
const GRAVITY: float = 560.0
const FLOOR_Y: float = 627.0
const BUBBLE_RADIUS: float = 53.0
const TARGET_POSITIONS: Array[Vector2] = [
    Vector2(800, 375),
    Vector2(966, 307),
    Vector2(1108, 407)
]
const TARGET_COLORS: Array[Color] = [
    Color("ffd0e6"),
    Color("c9d9ff"),
    Color("ffe5a9")
]

var active: bool = false
var squishy_name: String = ""
var squishy_color: Color = Color("f5bdd0")
var problem: Dictionary = {}
var projectile_position: Vector2 = START_POINT
var projectile_velocity: Vector2 = Vector2.ZERO
var projectile_active: bool = false
var projectile_time: float = 0.0
var respawn_delay: float = 0.0
var victory_countdown: float = -1.0
var status_text: String = "Namier myšou a kliknutím vystreľ!"
var bounce_factor: float = 1.0
var animation_timer: float = 0.0

func start_encounter(name: String, tint: Color, grade: int) -> void:
    squishy_name = name
    squishy_color = tint
    var seed_value: int = absi(name.hash()) + grade * 1237 + Time.get_ticks_msec()
    problem = MathChallenges.make(grade, seed_value)
    projectile_position = START_POINT
    projectile_velocity = Vector2.ZERO
    projectile_active = false
    projectile_time = 0.0
    respawn_delay = 0.0
    victory_countdown = -1.0
    bounce_factor = 1.0
    status_text = "Namier myšou a kliknutím vystreľ!"
    active = true
    visible = true
    queue_redraw()

func close_encounter() -> void:
    active = false
    visible = false
    projectile_active = false
    queue_redraw()

func _process(delta: float) -> void:
    if not active:
        return
    animation_timer += delta
    if victory_countdown >= 0.0:
        victory_countdown -= delta
        if victory_countdown <= 0.0:
            var completed_name: String = squishy_name
            close_encounter()
            captured.emit(completed_name)
        queue_redraw()
        return
    if respawn_delay > 0.0:
        respawn_delay -= delta
    if projectile_active:
        var step: float = minf(delta, 0.034)
        # Small physics steps give the launcher predictable collisions in browser.
        var iterations: int = maxi(1, ceili(delta / step))
        for i in range(iterations):
            _update_projectile(delta / float(iterations))
            if not projectile_active or victory_countdown >= 0.0:
                break
    queue_redraw()

func _update_projectile(delta: float) -> void:
    projectile_time += delta
    projectile_velocity.y += GRAVITY * delta
    projectile_position += projectile_velocity * delta
    for i in range(TARGET_POSITIONS.size()):
        if projectile_position.distance_to(TARGET_POSITIONS[i]) < BUBBLE_RADIUS + 18.0:
            var options: Array = problem.get("options", [])
            var hit_value: int = int(options[i])
            projectile_active = false
            if hit_value == int(problem.get("answer", -100000)):
                status_text = "Výborne! %s sa pridáva do tvojej zbierky!" % squishy_name
                victory_countdown = 1.8
            else:
                status_text = "To nie je správny výsledok. Skús to znovu!"
                respawn_delay = 0.8
            return
    if projectile_position.y >= FLOOR_Y:
        projectile_position.y = FLOOR_Y
        if projectile_velocity.y > 0.0:
            projectile_velocity.y = -projectile_velocity.y * 0.52
            projectile_velocity.x *= 0.76
            bounce_factor = 0.78
    if projectile_position.x > 1350.0 or projectile_position.x < -50.0 or projectile_time > 4.2:
        projectile_active = false
        respawn_delay = 0.6
        status_text = "Tesne vedľa! Skús zmeniť uhol strely."

func _unhandled_input(event: InputEvent) -> void:
    if not active:
        return
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_ESCAPE and victory_countdown < 0.0:
            close_encounter()
            cancelled.emit()
            get_viewport().set_input_as_handled()
            return
    if event is InputEventMouseMotion:
        queue_redraw()
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        var cursor: Vector2 = get_global_mouse_position()
        if cursor.x >= 1115.0 and cursor.y <= 100.0 and victory_countdown < 0.0:
            close_encounter()
            cancelled.emit()
        elif victory_countdown < 0.0 and not projectile_active and respawn_delay <= 0.0:
            _fire(cursor)
        get_viewport().set_input_as_handled()

func _fire(aim_point: Vector2) -> void:
    var aim: Vector2 = aim_point - START_POINT
    if aim.length_squared() < 4.0:
        return
    var angle: float = clampf(aim.angle(), -1.46, -0.06)
    projectile_position = START_POINT
    projectile_velocity = Vector2(cos(angle), sin(angle)) * SPEED
    projectile_time = 0.0
    projectile_active = true
    bounce_factor = 1.0
    status_text = "Letí! Sleduj dráhu guľôčky."

func _draw() -> void:
    if not active:
        return
    var f: Font = ThemeDB.fallback_font
    draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), Color("e4f3dd"))
    draw_rect(Rect2(0, 615, 1280, 105), Color("a8d5a4"))
    draw_circle(Vector2(1020, 650), 350.0, Color("cbe9bb"))
    draw_circle(Vector2(150, 710), 240.0, Color("c9e8b2"))
    draw_rect(Rect2(25, 20, 1225, 111), Color("fff9ed"))
    draw_string(f, Vector2(48, 62), "SQUISHY LAUNCHER  •  %s" % squishy_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color("42746b"))
    draw_string(f, Vector2(50, 111), "Vypočítaj: %s" % String(problem.get("question", "")), HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color("69556c"))
    draw_rect(Rect2(1118, 35, 112, 49), Color("f7dbe1"))
    draw_string(f, Vector2(1133, 69), "SPÄŤ", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("78515b"))
    for i in range(TARGET_POSITIONS.size()):
        _draw_target(i)
    draw_line(Vector2(129, 584), Vector2(154, 518), Color("97705a"), 18.0, true)
    draw_line(Vector2(218, 584), Vector2(183, 518), Color("97705a"), 18.0, true)
    draw_circle(Vector2(169, 555), 35, Color("c49a78"))
    if not projectile_active and victory_countdown < 0.0:
        _draw_trajectory()
        _draw_ball(START_POINT, squishy_color, 1.0)
    elif projectile_active:
        var speed_scale: float = clampf(projectile_velocity.length() / SPEED, 0.65, 1.4)
        _draw_ball(projectile_position, squishy_color, speed_scale * bounce_factor)
    draw_rect(Rect2(18, 660, 1244, 45), Color("fffaed"))
    draw_string(f, Vector2(36, 689), status_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 23, Color("456f62"))
    if victory_countdown >= 0.0:
        draw_rect(Rect2(330, 225, 620, 220), Color("fff5c4"))
        draw_rect(Rect2(337, 232, 606, 206), Color("e4f6d8"))
        draw_string(f, Vector2(380, 300), "SQUISHY ZÍSKANÝ!", HORIZONTAL_ALIGNMENT_LEFT, -1, 43, Color("3b8068"))
        draw_string(f, Vector2(405, 365), "%s je v tvojej zbierke!" % squishy_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color("654f73"))

func _draw_target(index: int) -> void:
    var center: Vector2 = TARGET_POSITIONS[index]
    var color: Color = TARGET_COLORS[index]
    var bob: float = sin(animation_timer * 2.1 + float(index)) * 5.0
    center.y += bob
    draw_circle(center + Vector2(0, 13), BUBBLE_RADIUS + 4.0, Color(0.31, 0.46, 0.40, 0.16))
    draw_circle(center, BUBBLE_RADIUS + 1.0, color.darkened(0.17))
    draw_circle(center + Vector2(0, -4), BUBBLE_RADIUS - 3.0, color)
    draw_circle(center + Vector2(-20, -24), 14.0, Color(1.0, 1.0, 1.0, 0.35))
    var options: Array = problem.get("options", [])
    var number_text: String = str(options[index])
    draw_string(ThemeDB.fallback_font, center + Vector2(-30, 13), number_text, HORIZONTAL_ALIGNMENT_CENTER, 60.0, 35, Color("4e546b"))

func _draw_ball(center: Vector2, tint: Color, stretch: float) -> void:
    draw_set_transform(center, 0.0, Vector2(clampf(stretch, 0.85, 1.25), clampf(1.0 / stretch, 0.82, 1.2)))
    draw_circle(Vector2.ZERO, 24.0, tint.darkened(0.11))
    draw_circle(Vector2(0, -3), 23.0, tint)
    draw_circle(Vector2(-9, -10), 8.5, Color(1.0, 1.0, 1.0, 0.28))
    for x in [-8.0, 8.0]:
        draw_circle(Vector2(x, 0), 4.2, Color("fffefa"))
        draw_circle(Vector2(x + 1, 1), 2.8, Color("3a4854"))
    draw_arc(Vector2(0, 7), 4.5, 0.15, PI - 0.15, 12, Color("6b4d68"), 1.6, true)
    draw_set_transform(Vector2.ZERO)

func _draw_trajectory() -> void:
    var aim: Vector2 = get_global_mouse_position() - START_POINT
    if aim.x < 30.0 or aim.length_squared() < 10.0:
        return
    var angle: float = clampf(aim.angle(), -1.46, -0.06)
    var velocity: Vector2 = Vector2(cos(angle), sin(angle)) * SPEED
    for i in range(1, 32):
        var t: float = float(i) * 0.064
        var p: Vector2 = START_POINT + velocity * t + Vector2(0, 0.5 * GRAVITY * t * t)
        if p.y >= FLOOR_Y or p.x > 1270:
            break
        draw_circle(p, 4.0 if i % 3 == 0 else 2.5, Color(0.44, 0.60, 0.59, 0.42))
