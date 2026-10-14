extends Node3D

## Character-only QA lab: this is NOT a finished overworld or final visual artwork.
## Blender GLB must be imported before Godot loads this scene.
const HERO_PATH: String = "res://assets/premium/hero_squishy.glb"
const DEFORMER = preload("res://scripts/premium/squishy_morph_controller.gd")
var camera: Camera3D
var hero: Node3D
var driver: Node3D
var hint: Label
var info: Label
var orbit_yaw: float = 18.0
var orbit_pitch: float = 16.0
var zoom: float = 4.8
var orbiting: bool = false
var bouncing: bool = false
var jump_time: float = 0.0
var lab_clock: float = 0.0
var hero_base_y: float = 0.0

func _ready() -> void:
    _make_lighting()
    _make_stage()
    _make_camera()
    _load_hero()
    _make_hud()

func _make_stage() -> void:
    # A neutral review surface, not an overworld placeholder.
    var plinth := MeshInstance3D.new()
    plinth.name = "StudioPlinth"
    var cyl := CylinderMesh.new()
    cyl.top_radius = 1.9
    cyl.bottom_radius = 2.1
    cyl.height = 0.15
    cyl.radial_segments = 80
    plinth.mesh = cyl
    plinth.position.y = -0.075
    var material := StandardMaterial3D.new()
    material.albedo_color = Color("#b5ccc8")
    material.roughness = 0.82
    plinth.material_override = material
    add_child(plinth)
    var ground := StaticBody3D.new()
    ground.name = "StudioGround"
    var collision := CollisionShape3D.new()
    var shape := CylinderShape3D.new()
    shape.height = 0.15
    shape.radius = 2.1
    collision.shape = shape
    ground.add_child(collision)
    ground.position.y = -0.075
    add_child(ground)

func _make_lighting() -> void:
    var ambient := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color("#c1ddd6")
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color("#d4eee9")
    env.ambient_light_energy = 0.9
    env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    ambient.environment = env
    add_child(ambient)
    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-50.0, 23.0, -19.0)
    sun.light_color = Color("#ffe6bd")
    sun.light_energy = 1.45
    sun.shadow_enabled = true
    add_child(sun)
    var bounce := OmniLight3D.new()
    bounce.position = Vector3(-1.8, 3.5, -0.9)
    bounce.light_color = Color("#b8ecf5")
    bounce.light_energy = 1.1
    bounce.omni_range = 8.0
    add_child(bounce)

func _make_camera() -> void:
    camera = Camera3D.new()
    camera.projection = Camera3D.PROJECTION_ORTHOGONAL
    camera.size = zoom
    camera.current = true
    add_child(camera)
    _update_camera()

func _update_camera() -> void:
    if camera == null:
        return
    var yaw: float = deg_to_rad(orbit_yaw)
    var pitch: float = deg_to_rad(orbit_pitch)
    var target := Vector3(0.0, 0.88, 0.0)
    var offset := Vector3(sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch)) * 6.0
    camera.position = target + offset
    camera.look_at(target, Vector3.UP)
    camera.size = zoom

func _load_hero() -> void:
    var packed: Resource = load(HERO_PATH)
    if not (packed is PackedScene):
        push_error("Premium hero glb missing or invalid: " + HERO_PATH)
        return
    hero = (packed as PackedScene).instantiate()
    hero.name = "PremiumHeroCandidate"
    add_child(hero)
    var meshes: Array[Node] = hero.find_children("*", "MeshInstance3D", true, false)
    var body: MeshInstance3D = null
    for node in meshes:
        if node.name.begins_with("SquishyBody"):
            body = node as MeshInstance3D
            break
    if body == null:
        push_error("SquishyBody not found in imported GLB")
        return
    var hit_body := StaticBody3D.new()
    hit_body.name = "InteractableBody"
    var sphere := SphereShape3D.new()
    sphere.radius = 0.9
    var shape := CollisionShape3D.new()
    shape.shape = sphere
    shape.position = Vector3(0, 0.92, 0)
    hit_body.add_child(shape)
    add_child(hit_body)
    driver = DEFORMER.new()
    driver.name = "JellyMorphController"
    driver.body_mesh = body
    driver.input_camera = camera
    driver.character_collider = hit_body
    driver.face_root = hero
    add_child(driver)

func _make_hud() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)
    var root := Control.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.mouse_filter = Control.MOUSE_FILTER_IGNORE
    layer.add_child(root)
    var panel := PanelContainer.new()
    panel.position = Vector2(22, 20)
    panel.custom_minimum_size = Vector2(565, 155)
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.075, 0.16, 0.20, 0.90)
    style.set_corner_radius_all(18)
    style.content_margin_left = 19
    style.content_margin_top = 14
    style.content_margin_right = 19
    style.content_margin_bottom = 14
    panel.add_theme_stylebox_override("panel", style)
    root.add_child(panel)
    var stack := VBoxContainer.new()
    panel.add_child(stack)
    var title := Label.new()
    title.text = "SQUISHY LAB  |  PRACOVNÁ 3D VERZIA"
    title.add_theme_font_size_override("font_size", 25)
    title.add_theme_color_override("font_color", Color("#e8faf5"))
    stack.add_child(title)
    hint = Label.new()
    hint.text = "Ľavé tlačidlo: chyť a natiahni · klik: šťuchni"
    hint.add_theme_font_size_override("font_size", 17)
    hint.add_theme_color_override("font_color", Color("#bfdcd5"))
    stack.add_child(hint)
    var text2 := Label.new()
    text2.text = "Pravé tlačidlo: otáčaj · koliesko: zoom · SPACE: odraz"
    text2.add_theme_font_size_override("font_size", 16)
    text2.add_theme_color_override("font_color", Color("#bfdcd5"))
    stack.add_child(text2)
    info = Label.new()
    info.text = "Blender glTF morph targets + spring physics"
    info.add_theme_font_size_override("font_size", 15)
    info.add_theme_color_override("font_color", Color("#9dd4c6"))
    stack.add_child(info)
    var footer := Label.new()
    footer.anchor_left = 1.0
    footer.anchor_right = 1.0
    footer.anchor_top = 1.0
    footer.anchor_bottom = 1.0
    footer.offset_left = -485
    footer.offset_right = -25
    footer.offset_top = -47
    footer.offset_bottom = -17
    footer.text = "VIZUÁLNA KVALITA ZATIAĽ NESCHVÁLENÁ"
    footer.add_theme_color_override("font_color", Color("#204f54"))
    footer.add_theme_font_size_override("font_size", 17)
    root.add_child(footer)

func _process(delta: float) -> void:
    lab_clock += delta
    if hero == null:
        return
    if bouncing:
        jump_time += delta
        var t: float = clampf(jump_time / 0.82, 0.0, 1.0)
        var arc: float = 2.2 * sin(t * PI)
        hero.position.y = hero_base_y + maxf(0.0, arc)
        if t >= 1.0:
            bouncing = false
            hero.position.y = hero_base_y
            if driver != null:
                driver.impact(7.0)
    if info != null and driver != null:
        info.text = "Stlač SPACE · " + ("Naťahuješ Squishyho" if driver.is_dragging else "Pružné želé aktívne")

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE and not bouncing:
        bouncing = true
        jump_time = 0.0
        get_viewport().set_input_as_handled()
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_RIGHT:
            orbiting = event.pressed
        elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
            zoom = maxf(3.1, zoom - 0.25)
            _update_camera()
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
            zoom = minf(6.7, zoom + 0.25)
            _update_camera()
    elif event is InputEventMouseMotion and orbiting:
        orbit_yaw = clampf(orbit_yaw - event.relative.x * 0.28, -175.0, 175.0)
        orbit_pitch = clampf(orbit_pitch + event.relative.y * 0.19, -10.0, 74.0)
        _update_camera()
