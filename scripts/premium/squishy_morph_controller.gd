extends Node3D
## Jelly Physics 2.0: coupled local springs + GPU surface field + Blender morphs.
## Stable physics collider does not deform; face follows the same lattice field.
const Spring = preload("res://scripts/premium/jelly_spring.gd")
const Lattice = preload("res://scripts/premium/jelly_lattice.gd")
const JELLY_SHADER: Shader = preload("res://shaders/premium/jelly_skin.gdshader")

@export var body_mesh: MeshInstance3D
@export var input_camera: Camera3D
@export var character_collider: CollisionObject3D
@export var face_root: Node3D

var lattice = Lattice.new()
var channels: Dictionary = {}
var morph_indices: Dictionary = {}
var skin_material: ShaderMaterial = null
var attached_parts: Array[Node3D] = []
var attached_rest_positions: Array[Vector3] = []

var is_dragging: bool = false
var grab_location: Vector3 = Vector3.ZERO
var drag_origin: Vector2 = Vector2.ZERO
var latest_mouse: Vector2 = Vector2.ZERO
var last_drag_time_msec: int = 0
var mouse_speed_px: Vector2 = Vector2.ZERO
var grab_seconds: float = 0.0
var walk_time: float = 0.0
var idle_time: float = 0.0

func _ready() -> void:
    for name in ["Squash", "StretchUp", "LeanLeft", "LeanRight", "Impact", "PokeFront", "HappyWiggle"]:
        var spring = Spring.new()
        spring.configure(42.0, 8.0)
        channels[name] = spring
    channels["Impact"].configure(58.0, 8.0)
    channels["PokeFront"].configure(68.0, 9.0)
    if body_mesh == null or body_mesh.mesh == null:
        push_error("Premium body mesh is required for Jelly Physics 2.0")
        return
    for i in range(body_mesh.mesh.get_blend_shape_count()):
        morph_indices[String(body_mesh.mesh.get_blend_shape_name(i))] = i
    skin_material = ShaderMaterial.new()
    skin_material.shader = JELLY_SHADER
    skin_material.set_shader_parameter("node_rest", lattice.anchors)
    skin_material.set_shader_parameter("node_shift", lattice.offsets)
    body_mesh.set_surface_override_material(0, skin_material)
    if face_root != null:
        var meshes: Array[Node] = face_root.find_children("*", "MeshInstance3D", true, false)
        for node in meshes:
            var part := node as MeshInstance3D
            if part == body_mesh:
                continue
            attached_parts.append(part)
            attached_rest_positions.append(part.position)
    print("Jelly Physics 2.0 READY: %d spring points, %d facial/appendage parts" % [
        lattice.anchors.size(), attached_parts.size()])

func _physics_process(delta: float) -> void:
    idle_time += delta
    if is_dragging:
        grab_seconds += delta
        lattice.drag(_screen_to_local(latest_mouse - drag_origin))
    lattice.step(delta)
    _update_global_morphs(delta)
    _update_attached_face()
    if skin_material != null:
        skin_material.set_shader_parameter("node_shift", lattice.offsets)

func _screen_to_local(screen_delta: Vector2) -> Vector3:
    if input_camera == null or body_mesh == null:
        return Vector3.ZERO
    var world_per_px: float = input_camera.size / maxf(1.0, float(get_viewport().get_visible_rect().size.y))
    var world_delta: Vector3 = (input_camera.global_transform.basis.x * screen_delta.x -
        input_camera.global_transform.basis.y * screen_delta.y) * world_per_px
    var local_delta: Vector3 = body_mesh.global_transform.basis.inverse() * world_delta
    return local_delta.limit_length(0.61)

func _update_global_morphs(delta: float) -> void:
    var upper: Vector3 = Vector3.ZERO
    for i in range(1, 5):
        upper += lattice.offsets[i] * 0.25
    var lower: Vector3 = Vector3.ZERO
    for i in range(9, 13):
        lower += lattice.offsets[i] * 0.25
    channels["StretchUp"].target = clampf((upper.y - lower.y) * 0.37, 0.0, 0.28)
    channels["Squash"].target = clampf((lower.y - upper.y) * 0.52, 0.0, 0.35)
    channels["LeanLeft"].target = clampf(-upper.x * 0.22, 0.0, 0.22)
    channels["LeanRight"].target = clampf(upper.x * 0.22, 0.0, 0.22)
    for name in channels:
        var spring = channels[name]
        var weight: float = spring.step(delta)
        if body_mesh != null and morph_indices.has(name):
            body_mesh.set_blend_shape_value(int(morph_indices[name]), clampf(weight, 0.0, 0.5))

func _displacement_at(local_pos: Vector3) -> Vector3:
    var d: Vector3 = Vector3.ZERO
    var total: float = 0.0
    for i in range(lattice.anchors.size()):
        var distance_sq: float = local_pos.distance_squared_to(lattice.anchors[i])
        var w: float = exp(-distance_sq / (2.0 * 0.80 * 0.80))
        d += lattice.offsets[i] * w
        total += w
    return d / maxf(0.7, total * 0.78)

func _update_attached_face() -> void:
    var squash: float = float(channels["Squash"].value)
    var stretch: float = float(channels["StretchUp"].value)
    var impact_weight: float = float(channels["Impact"].value)
    var vertical: float = 1.0 + 0.26 * stretch - 0.22 * squash - 0.16 * impact_weight
    var radial: float = clampf(1.0 - stretch * 0.22 + squash * 0.18, 0.81, 1.22)
    for i in range(attached_parts.size()):
        var part: Node3D = attached_parts[i]
        if not is_instance_valid(part):
            continue
        var original: Vector3 = attached_rest_positions[i]
        var shifted: Vector3 = original
        shifted.y = 0.12 + (original.y - 0.12) * vertical
        shifted.x *= radial
        shifted.z *= radial
        shifted += _displacement_at(original)
        part.position = shifted

func _unhandled_input(event: InputEvent) -> void:
    if input_camera == null or character_collider == null or body_mesh == null:
        return
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        var pointer: Vector2 = event.position
        if event.pressed:
            var origin: Vector3 = input_camera.project_ray_origin(pointer)
            var normal: Vector3 = input_camera.project_ray_normal(pointer)
            var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, origin + normal * 100.0)
            var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
            if hit.get("collider") == character_collider:
                is_dragging = true
                grab_seconds = 0.0
                drag_origin = pointer
                latest_mouse = pointer
                mouse_speed_px = Vector2.ZERO
                last_drag_time_msec = Time.get_ticks_msec()
                grab_location = body_mesh.to_local(hit["position"])
                lattice.grab(grab_location)
                get_viewport().set_input_as_handled()
        elif is_dragging:
            var screen_displacement: Vector2 = latest_mouse - drag_origin
            is_dragging = false
            if screen_displacement.length() < 11.0 and grab_seconds < 0.28:
                lattice.release(Vector3.ZERO)
                lattice.disturb(grab_location, -_surface_normal(grab_location) * 5.5, 0.39)
                channels["PokeFront"].push(1.5)
            else:
                var delta_local: Vector3 = _screen_to_local(mouse_speed_px * 0.23)
                lattice.release(delta_local * 6.0)
                if screen_displacement.length() > 90.0:
                    channels["HappyWiggle"].push(0.8)
            get_viewport().set_input_as_handled()
    elif event is InputEventMouseMotion and is_dragging:
        var now: int = Time.get_ticks_msec()
        var ms: float = maxf(8.0, float(now - last_drag_time_msec))
        var inst_speed: Vector2 = event.relative * (16.667 / ms)
        mouse_speed_px = mouse_speed_px.lerp(inst_speed, 0.55)
        last_drag_time_msec = now
        latest_mouse = event.position
        get_viewport().set_input_as_handled()

func _surface_normal(local_pos: Vector3) -> Vector3:
    var normal: Vector3 = local_pos - Vector3(0.0, 0.87, 0.0)
    if normal.length_squared() < 0.001:
        return Vector3(0.0, 0.0, 1.0)
    return normal.normalized()

func impact(strength: float) -> void:
    lattice.impact(strength)
    channels["Impact"].push(clampf(strength * 0.22, 0.0, 2.5))
    channels["Squash"].push(clampf(strength * 0.13, 0.0, 1.3))

func movement(acceleration: Vector3, speed: float, turning: float) -> void:
    lattice.movement(acceleration, speed, turning)
    if speed > 0.1:
        walk_time += 0.06 * speed
        if sin(walk_time * 6.0) > 0.94:
            lattice.disturb(Vector3(0, 0.45, 0), Vector3(0, 1.0, 0), 0.85)

func celebrate() -> void:
    lattice.disturb(Vector3(0.0, 1.25, 0.0), Vector3(0, 2.8, 0), 1.0)
    channels["HappyWiggle"].push(1.0)

func wobble_amount() -> float:
    return lattice.max_displacement()
