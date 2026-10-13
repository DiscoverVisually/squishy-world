extends Node2D
class_name MergeArena

signal captured(squishy_name: String)
signal cancelled

const BLOB = preload("res://scripts/jelly_blob.gd")
const RULES = preload("res://scripts/merge_rules.gd")
const LEFT: float = 320.0
const RIGHT: float = 1020.0
const FLOOR: float = 608.0
const DROP_Y: float = 185.0
const MAX_DROPS: int = 24

var active: bool = false
var squishy_name: String = ""
var config: Dictionary = {}
var pieces: Array[JellyBlob] = []
var steps: int = 0
var cooldown: float = 0.0
var scan_timer: float = 0.0
var victory_timer: float = -1.0
var retry_timer: float = 0.0
var status: String = "Spoj rovnaké čísla!"
var flash: float = 0.0

func _ready() -> void:
    visible = false
    set_process(false)
    set_physics_process(false)
    _wall(Vector2(670, 628), Vector2(744, 42))
    _wall(Vector2(309, 422), Vector2(28, 440))
    _wall(Vector2(1031, 422), Vector2(28, 440))

func _wall(at: Vector2, size: Vector2) -> void:
    var body := StaticBody2D.new()
    body.position = at
    body.collision_layer = 8
    body.collision_mask = 0
    var collision := CollisionShape2D.new()
    var shape := RectangleShape2D.new()
    shape.size = size
    collision.shape = shape
    body.add_child(collision)
    add_child(body)

func start_encounter(name: String, tint: Color, grade: int) -> void:
    _clear_pieces()
    squishy_name = name
    config = RULES.grade_config(grade)
    _reset_state()
    active = true
    visible = true
    set_process(true)
    set_physics_process(true)

func _reset_state() -> void:
    _clear_pieces()
    steps = 0
    cooldown = 0.0
    scan_timer = 0.0
    victory_timer = -1.0
    retry_timer = 0.0
    flash = 0.0
    status = "Klikni nad nádobou a spájaj rovnaké čísla."

func _clear_pieces() -> void:
    for piece in pieces:
        if is_instance_valid(piece):
            piece.queue_free()
    pieces.clear()

func close_encounter() -> void:
    active = false
    visible = false
    set_process(false)
    set_physics_process(false)
    _clear_pieces()

func _process(delta: float) -> void:
    if not active:
        return
    cooldown = maxf(0.0, cooldown - delta)
    flash = maxf(0.0, flash - delta)
    if victory_timer >= 0.0:
        victory_timer -= delta
        if victory_timer <= 0.0:
            var won_name: String = squishy_name
            close_encounter()
            captured.emit(won_name)
    elif steps >= MAX_DROPS:
        retry_timer += delta
        if retry_timer > 3.0:
            _reset_state()
            status = "Nový pokus! Skús ukladať čísla bližšie."
    queue_redraw()

func _physics_process(delta: float) -> void:
    if not active or victory_timer >= 0.0:
        return
    scan_timer -= delta
    if scan_timer > 0.0:
        return
    scan_timer = 0.07
    for i in range(pieces.size()):
        var a: JellyBlob = pieces[i]
        if not is_instance_valid(a) or a.joining or a.lifetime < 0.16:
            continue
        for j in range(i + 1, pieces.size()):
            var b: JellyBlob = pieces[j]
            if not is_instance_valid(b) or b.joining or b.lifetime < 0.16:
                continue
            if a.number == b.number and a.position.distance_to(b.position) <= a.radius + b.radius + 4.0:
                a.joining = true
                b.joining = true
                call_deferred("_merge", a, b)
                return

func _merge(a: JellyBlob, b: JellyBlob) -> void:
    if not active or not is_instance_valid(a) or not is_instance_valid(b):
        return
    var total: int = a.number + b.number
    var at: Vector2 = (a.position + b.position) * 0.5
    pieces.erase(a)
    pieces.erase(b)
    a.queue_free()
    b.queue_free()
    flash = 0.5
    status = "%d + %d = %d — super!" % [int(total / 2), int(total / 2), total]
    if total >= int(config["goal"]):
        victory_timer = 1.7
        status = "Výborne! %s sa pridáva do zbierky!" % squishy_name
    else:
        _spawn(total, at, true)

func _spawn(value: int, at: Vector2, highlight: bool = false) -> void:
    var n: JellyBlob = BLOB.new()
    var level: int = roundi(log(float(value)) / log(2.0))
    var palette: Array[Color] = [
        Color("f9c9e2"), Color("ffe1a7"), Color("bde5f8"),
        Color("c2e7bf"), Color("d2c4f4"), Color("ffcab1"),
        Color("aadfce"), Color("fbd59c")
    ]
    var r: float = clampf(23.0 + float(level) * 5.2, 23.0, 62.0)
    n.configure(value, r, palette[posmod(level, palette.size())])
    n.position = at
    n.shine = 0.85 if highlight else 0.0
    add_child(n)
    pieces.append(n)

func _drop(x: float) -> void:
    if cooldown > 0.0 or victory_timer >= 0.0 or steps >= MAX_DROPS:
        return
    var value: int = RULES.next_value(int(config["base"]), steps)
    var radius: float = clampf(23.0 + float(roundi(log(float(value)) / log(2.0))) * 5.2, 23.0, 62.0)
    _spawn(value, Vector2(clampf(x, LEFT + radius + 12.0, RIGHT - radius - 12.0), DROP_Y))
    steps += 1
    cooldown = 0.4
    status = "Premysli si ďalší krok. Rovnaké čísla sa spoja!"
    if steps >= MAX_DROPS:
        status = "Posledné číslo! Ak sa nepodarí cieľ, začneš znova."

func _unhandled_input(event: InputEvent) -> void:
    if not active:
        return
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_ESCAPE and victory_timer < 0.0:
            close_encounter()
            cancelled.emit()
            get_viewport().set_input_as_handled()
        elif event.keycode == KEY_R and victory_timer < 0.0:
            _reset_state()
            get_viewport().set_input_as_handled()
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and victory_timer < 0.0:
        var pos: Vector2 = get_global_mouse_position()
        if pos.y < 120.0 and pos.x > 1110.0:
            close_encounter()
            cancelled.emit()
        elif pos.y < 120.0 and pos.x > 970.0:
            _reset_state()
        elif pos.x > LEFT and pos.x < RIGHT and pos.y > 130.0:
            _drop(pos.x)
        get_viewport().set_input_as_handled()

func _draw() -> void:
    if not active:
        return
    var f: Font = ThemeDB.fallback_font
    draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), Color("e3f2dd"))
    draw_circle(Vector2(125, 630), 265, Color("cee8c1"))
    draw_circle(Vector2(1120, 650), 280, Color("cfe9c0"))
    draw_rect(Rect2(18, 18, 1244, 114), Color("fff9ec"))
    draw_string(f, Vector2(40, 62), "JELLY MERGE  •  %s" % squishy_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color("4b7567"))
    draw_string(f, Vector2(40, 108), "CIEĽ: vytvor číslo %d" % int(config["goal"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 31, Color("7b5a70"))
    draw_rect(Rect2(978, 39, 124, 48), Color("dedff5"))
    draw_rect(Rect2(1114, 39, 132, 48), Color("f6d6e0"))
    draw_string(f, Vector2(984, 69), "REŠTART", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("605c81"))
    draw_string(f, Vector2(1137, 69), "SPÄŤ", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("7b5163"))
    draw_rect(Rect2(LEFT - 22, 227, RIGHT - LEFT + 44, 396), Color("fafdf0"))
    draw_rect(Rect2(LEFT - 20, 226, 18, 397), Color("bacdca"))
    draw_rect(Rect2(RIGHT + 1, 226, 18, 397), Color("bacdca"))
    draw_rect(Rect2(LEFT - 20, FLOOR - 7, RIGHT - LEFT + 39, 29), Color("9cb5ae"))
    var aim_x: float = clampf(get_global_mouse_position().x, LEFT + 60, RIGHT - 60)
    for i in range(6):
        draw_circle(Vector2(aim_x, DROP_Y + 31 + float(i) * 19.0), 2.6, Color(0.36, 0.48, 0.51, 0.35))
    draw_circle(Vector2(aim_x, DROP_Y), 29.0, Color("e6c7f4"))
    var value: int = RULES.next_value(int(config["base"]), steps)
    draw_string(f, Vector2(aim_x - 29, DROP_Y + 10), str(value), HORIZONTAL_ALIGNMENT_CENTER, 58.0, 28, Color("46516c"))
    draw_string(f, Vector2(31, 213), "KLIKNI NAD", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("567b6f"))
    draw_string(f, Vector2(31, 241), "NÁDOBOU", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("567b6f"))
    draw_string(f, Vector2(32, 341), "Rovnaké čísla", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("648574"))
    draw_string(f, Vector2(32, 371), "sa sčítajú.", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("648574"))
    draw_string(f, Vector2(1047, 251), "Pustené:", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("617a6e"))
    draw_string(f, Vector2(1047, 290), "%d / %d" % [steps, MAX_DROPS], HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color("78566a"))
    draw_string(f, Vector2(1047, 378), "R = reštart", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("617a6e"))
    draw_string(f, Vector2(1047, 409), "ESC = späť", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("617a6e"))
    draw_rect(Rect2(16, 659, 1250, 47), Color("fff9eb"))
    draw_string(f, Vector2(30, 691), status, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("4d776d"))
    if flash > 0.0:
        draw_arc(Vector2(680, 411), 91, 0, TAU, 36, Color(1, 0.95, 0.52, flash), 6.0, true)
    if victory_timer >= 0.0:
        draw_rect(Rect2(330, 255, 620, 216), Color("fff7c7"))
        draw_rect(Rect2(339, 264, 602, 197), Color("e8f7e0"))
        draw_string(f, Vector2(384, 337), "SQUISHY ZÍSKANÝ!", HORIZONTAL_ALIGNMENT_LEFT, -1, 39, Color("3c816a"))
        draw_string(f, Vector2(406, 405), "%s je tvoj kamarát!" % squishy_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 27, Color("6b5575"))
