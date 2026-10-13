extends Node2D

const WORLD_SIZE: Vector2 = Vector2(2048, 1536)
const TREES: Array[Vector2] = [
    Vector2(175, 220), Vector2(350, 640), Vector2(760, 240),
    Vector2(1350, 260), Vector2(1730, 305), Vector2(1780, 700),
    Vector2(1490, 1120), Vector2(1180, 1280), Vector2(480, 1200),
    Vector2(205, 970), Vector2(1940, 1250), Vector2(1610, 1430)
]
const FLOWER_COLORS: Array[Color] = [Color("fff3b0"), Color("ffc8e0"), Color("f6ffdf"), Color("d2bafc")]

@onready var player: CharacterBody2D = $Player
@onready var hud: SquishyHUD = $HUD
@onready var arena: LauncherArena = $Encounter/Arena
@onready var merge_arena: MergeArena = $Encounter/Merge
@onready var choice: EncounterChoice = $Encounter/Choice
var encounter_creature: WildSquishy = null
var training_mode: bool = false
var selected_grade: int = 2
var caught_names: Array[String] = []
var nearby_squishy: WildSquishy = null
var wild_squishies: Array[WildSquishy] = []
var status_clock: float = 0.0

func _ready() -> void:
    _load_progress()
    arena.captured.connect(_on_squishy_captured)
    arena.cancelled.connect(_on_encounter_cancelled)
    merge_arena.captured.connect(_on_squishy_captured)
    merge_arena.cancelled.connect(_on_encounter_cancelled)
    choice.selected.connect(_on_choice_selected)
    choice.cancelled.connect(_on_encounter_cancelled)
    hud.set_progress(selected_grade, caught_names.size())
    for tree in TREES:
        _add_round_obstacle(tree + Vector2(0, 24), 27.0)
    _add_round_obstacle(Vector2(1160, 520), 48.0)
    _add_round_obstacle(Vector2(1585, 880), 38.0)
    var npc_data := [
        ["Pip", Color("ffc4df"), Vector2(775, 635)],
        ["Bubi", Color("d3bdf9"), Vector2(1430, 530)],
        ["Momo", Color("ffe49c"), Vector2(1320, 980)],
        ["Kiki", Color("a7e4f6"), Vector2(625, 1060)],
        ["Lulu", Color("fdbaa8"), Vector2(1790, 1180)]
    ]
    for data in npc_data:
        if caught_names.has(String(data[0])):
            continue
        var creature: WildSquishy = WildSquishy.new()
        creature.configure(data[0], data[1], data[2], wild_squishies.size())
        add_child(creature)
        wild_squishies.append(creature)

func _process(delta: float) -> void:
    if arena.active or merge_arena.active or choice.active:
        return
    status_clock -= delta
    if status_clock <= 0.0:
        status_clock = 0.12
        nearby_squishy = null
        var nearest_distance: float = 116.0
        for creature in wild_squishies:
            var distance: float = player.global_position.distance_to(creature.global_position)
            if distance < nearest_distance:
                nearby_squishy = creature
                nearest_distance = distance
    if nearby_squishy != null and is_instance_valid(nearby_squishy):
        hud.set_nearby("Stlač E pri %s a spusti výzvu!" % nearby_squishy.display_name)
    else:
        hud.set_nearby("Nájdi Squishyho! Zbierka: %d/5" % caught_names.size())

func _unhandled_input(event: InputEvent) -> void:
    if arena.active or merge_arena.active or choice.active or not (event is InputEventKey):
        return
    if not event.pressed or event.echo:
        return
    if event.keycode >= KEY_1 and event.keycode <= KEY_4:
        selected_grade = int(event.keycode) - int(KEY_1) + 1
        hud.set_progress(selected_grade, caught_names.size())
        _save_progress()
        get_viewport().set_input_as_handled()
    elif event.keycode == KEY_P:
        player.set_physics_process(false)
        hud.visible = false
        training_mode = true
        encounter_creature = null
        choice.show_choice("Tréning", Color("b8e2cf"))
        get_viewport().set_input_as_handled()
    elif event.keycode == KEY_E and nearby_squishy != null and is_instance_valid(nearby_squishy):
        player.set_physics_process(false)
        hud.visible = false
        encounter_creature = nearby_squishy
        choice.show_choice(nearby_squishy.display_name, nearby_squishy.body_color)
        get_viewport().set_input_as_handled()

func _on_choice_selected(mode: String) -> void:
    if training_mode:
        if mode == "merge":
            merge_arena.start_encounter("Tréning", Color("b8e2cf"), selected_grade)
        else:
            arena.start_encounter("Tréning", Color("b8e2cf"), selected_grade)
        return
    if encounter_creature == null or not is_instance_valid(encounter_creature):
        _on_encounter_cancelled()
        return
    if mode == "merge":
        merge_arena.start_encounter(encounter_creature.display_name, encounter_creature.body_color, selected_grade)
    else:
        arena.start_encounter(encounter_creature.display_name, encounter_creature.body_color, selected_grade)

func _on_squishy_captured(squishy_name: String) -> void:
    if training_mode:
        _on_encounter_cancelled()
        hud.set_nearby("Tréning dokončený! P = nová výzva.")
        return
    if not caught_names.has(squishy_name):
        caught_names.append(squishy_name)
    for creature in wild_squishies.duplicate():
        if creature.display_name == squishy_name:
            wild_squishies.erase(creature)
            creature.queue_free()
    nearby_squishy = null
    hud.set_progress(selected_grade, caught_names.size())
    _save_progress()
    _on_encounter_cancelled()
    hud.set_nearby("Získal si %s! Zbierka: %d/5" % [squishy_name, caught_names.size()])

func _on_encounter_cancelled() -> void:
    encounter_creature = null
    training_mode = false
    player.set_physics_process(true)
    hud.visible = true
    status_clock = 0.0

func _load_progress() -> void:
    if not FileAccess.file_exists("user://squishy_save_v02.json"):
        return
    var file := FileAccess.open("user://squishy_save_v02.json", FileAccess.READ)
    if file == null:
        return
    var payload: Variant = JSON.parse_string(file.get_as_text())
    if payload is Dictionary:
        selected_grade = clampi(int(payload.get("grade", 2)), 1, 4)
        var collection: Variant = payload.get("caught", [])
        if collection is Array:
            for entry in collection:
                var squishy_name: String = String(entry)
                if squishy_name in ["Pip", "Bubi", "Momo", "Kiki", "Lulu"] and not caught_names.has(squishy_name):
                    caught_names.append(squishy_name)

func _save_progress() -> void:
    var file := FileAccess.open("user://squishy_save_v02.json", FileAccess.WRITE)
    if file != null:
        file.store_string(JSON.stringify({"grade": selected_grade, "caught": caught_names}))

func _add_round_obstacle(origin: Vector2, radius: float) -> void:
    var obstacle := StaticBody2D.new()
    obstacle.position = origin
    obstacle.collision_layer = 2
    obstacle.collision_mask = 0
    var shape_node := CollisionShape2D.new()
    var shape := CircleShape2D.new()
    shape.radius = radius
    shape_node.shape = shape
    obstacle.add_child(shape_node)
    add_child(obstacle)

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, WORLD_SIZE), Color("d9f0bb"))
    for patch in [
        [Vector2(420, 200), 300.0, Color("e6f6c9")],
        [Vector2(1580, 190), 355.0, Color("c5e7b8")],
        [Vector2(190, 1250), 425.0, Color("bfdfac")],
        [Vector2(1500, 1360), 350.0, Color("e5f5c6")],
        [Vector2(1090, 790), 430.0, Color("e9f5cb")]
    ]:
        draw_circle(patch[0], patch[1], patch[2])
    var path_a := PackedVector2Array([
        Vector2(0, 810), Vector2(365, 780), Vector2(720, 800),
        Vector2(1000, 760), Vector2(1300, 695), Vector2(1590, 760),
        Vector2(2048, 835)
    ])
    var path_b := PackedVector2Array([
        Vector2(990, 0), Vector2(1000, 290), Vector2(1050, 565),
        Vector2(1030, 810), Vector2(970, 1130), Vector2(1110, 1536)
    ])
    for path in [path_a, path_b]:
        draw_polyline(path, Color("d4d8aa"), 112.0, true)
        draw_polyline(path, Color("fff2d2"), 100.0, true)
    draw_set_transform(Vector2(420, 380), -0.06, Vector2(1.24, 0.78))
    draw_circle(Vector2.ZERO, 176.0, Color("add9bb"))
    draw_circle(Vector2.ZERO, 162.0, Color("98deda"))
    draw_circle(Vector2(-9, -8), 145.0, Color("b9f3ec"))
    draw_arc(Vector2(-22, -15), 100, 3.6, 5.45, 30, Color(1.0, 1.0, 1.0, 0.55), 5.0, true)
    draw_set_transform(Vector2.ZERO)
    var rng := RandomNumberGenerator.new()
    rng.seed = 126344
    for i in range(1250):
        var pos := Vector2(rng.randf_range(18, 2030), rng.randf_range(12, 1520))
        if pos.distance_to(Vector2(420, 380)) < 235:
            continue
        var pigment := Color("a4ce98") if i % 3 == 0 else Color("c0e0a6")
        draw_line(pos, pos + Vector2(rng.randf_range(-3, 3), -rng.randf_range(3, 10)), pigment, 2.0, true)
    for i in range(290):
        var flower := Vector2(rng.randf_range(20, 2025), rng.randf_range(35, 1510))
        if flower.distance_to(Vector2(420, 380)) < 240:
            continue
        draw_circle(flower, 3.7, FLOWER_COLORS[i % FLOWER_COLORS.size()])
        draw_circle(flower, 1.6, Color("f2bb60"))
    for tree in TREES:
        _draw_tree(tree)
    _draw_rock(Vector2(1160, 520), 59.0)
    _draw_rock(Vector2(1585, 880), 48.0)
    draw_line(Vector2(980, 625), Vector2(980, 690), Color("966f60"), 13.0, true)
    draw_rect(Rect2(919, 619, 124, 36), Color("fff6d9"), true)
    draw_rect(Rect2(919, 619, 124, 36), Color("bc9f76"), false, 3.0)
    draw_string(ThemeDB.fallback_font, Vector2(933, 646), "ŽELÉ LÚKA", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("557d66"))

func _draw_tree(at: Vector2) -> void:
    draw_circle(at + Vector2(0, 29), 51.0, Color(0.24, 0.47, 0.32, 0.13))
    draw_line(at + Vector2(0, 34), at + Vector2(0, -20), Color("b18a6c"), 18.0, true)
    draw_circle(at + Vector2(-24, -22), 48.0, Color("79bda0"))
    draw_circle(at + Vector2(22, -25), 47.0, Color("77bf91"))
    draw_circle(at + Vector2(0, -52), 52.0, Color("97d6ac"))
    draw_circle(at + Vector2(-16, -73), 26.0, Color(1, 1, 1, 0.10))
    draw_circle(at + Vector2(20, -67), 7.0, Color("fcd2a0"))

func _draw_rock(at: Vector2, radius: float) -> void:
    draw_circle(at + Vector2(0, 17), radius + 7, Color(0.18, 0.42, 0.25, 0.14))
    draw_circle(at, radius, Color("a4b6ab"))
    draw_circle(at + Vector2(-11, -15), radius * 0.68, Color("d3ded0"))
