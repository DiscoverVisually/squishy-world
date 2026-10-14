extends Node3D
## Reusable visual controller for original Blender .glb morph targets.
## Attach under CharacterBody3D; no collisions changed by visual stretching.
const Spring = preload("res://scripts/premium/jelly_spring.gd")
@export var body_mesh: MeshInstance3D
@export var input_camera: Camera3D
@export var character_collider: CollisionObject3D
@export var face_root: Node3D
var attached_parts: Array[Node3D] = []
var attached_rest_positions: Array[Vector3] = []
@export var drag_sensitivity: float = 0.0035

var channels: Dictionary = {}
var morph_indices: Dictionary = {}
var is_dragging: bool = false
var drag_origin: Vector2 = Vector2.ZERO
var latest_mouse: Vector2 = Vector2.ZERO
var drag_seconds: float = 0.0

func _ready() -> void:
    for name in ["Squash", "StretchUp", "LeanLeft", "LeanRight", "Impact", "PokeFront", "HappyWiggle"]:
        var spring = Spring.new()
        spring.configure(90.0, 15.0)
        channels[name] = spring
    if body_mesh == null or body_mesh.mesh == null:
        push_warning("Assign a Blender character Body mesh; no deformable mesh is loaded yet")
        return
    for i in range(body_mesh.mesh.get_blend_shape_count()):
        morph_indices[String(body_mesh.mesh.get_blend_shape_name(i))] = i
    for required in channels.keys():
        if not morph_indices.has(required):
            push_warning("Missing Blender morph channel: " + String(required))
    if face_root != null:
        var meshes: Array[Node] = face_root.find_children("*", "MeshInstance3D", true, false)
        for obj in meshes:
            var part := obj as MeshInstance3D
            if part == body_mesh:
                continue
            attached_parts.append(part)
            attached_rest_positions.append(part.position)

func _physics_process(delta: float) -> void:
    if is_dragging:
        drag_seconds += delta
        var pull: Vector2 = (latest_mouse - drag_origin) * drag_sensitivity
        channels["StretchUp"].target = clampf(-pull.y, 0.0, 1.0)
        channels["LeanLeft"].target = clampf(-pull.x, 0.0, 1.0)
        channels["LeanRight"].target = clampf(pull.x, 0.0, 1.0)
    else:
        channels["StretchUp"].target = 0.0
        channels["LeanLeft"].target = 0.0
        channels["LeanRight"].target = 0.0
    for name in channels:
        var spring = channels[name]
        var weight: float = spring.step(delta)
        if body_mesh != null and morph_indices.has(name):
            body_mesh.set_blend_shape_value(int(morph_indices[name]), weight)
    _update_attached_face()

func _update_attached_face() -> void:
    var stretch: float = float(channels["StretchUp"].value)
    var squash: float = float(channels["Squash"].value)
    var left: float = float(channels["LeanLeft"].value)
    var right: float = float(channels["LeanRight"].value)
    var impact_weight: float = float(channels["Impact"].value)
    var poke: float = float(channels["PokeFront"].value)
    var vertical_factor: float = 1.0 + 0.26 * stretch - 0.22 * squash - 0.18 * impact_weight
    var horizontal_factor: float = 1.0 - 0.14 * stretch + 0.16 * squash + 0.11 * impact_weight
    var lateral_offset: float = (right - left) * 0.17
    for i in range(attached_parts.size()):
        var part: Node3D = attached_parts[i]
        if not is_instance_valid(part):
            continue
        var orig: Vector3 = attached_rest_positions[i]
        var p: Vector3 = orig
        p.x = orig.x * horizontal_factor + lateral_offset * clampf(orig.y * 0.65, 0.0, 1.0)
        p.y = 0.12 + (orig.y - 0.12) * vertical_factor
        p.z = orig.z * (1.0 + 0.11 * squash - 0.12 * stretch)
        if part.name.begins_with("Eye") or part.name.begins_with("Iris") or part.name.begins_with("Pupil") or part.name.begins_with("Catchlight") or part.name == "Mouth" or part.name == "Tongue":
            p.z += 0.08 * poke
        part.position = p

func _unhandled_input(event: InputEvent) -> void:
    if input_camera == null or character_collider == null:
        return
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        var pointer: Vector2 = event.position
        if event.pressed:
            var from: Vector3 = input_camera.project_ray_origin(pointer)
            var direction: Vector3 = input_camera.project_ray_normal(pointer)
            var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, from + direction * 100.0)
            var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
            if hit.get("collider") == character_collider:
                is_dragging = true
                drag_seconds = 0.0
                drag_origin = pointer
                latest_mouse = pointer
                get_viewport().set_input_as_handled()
        elif is_dragging:
            is_dragging = false
            if drag_seconds < 0.22 and latest_mouse.distance_to(drag_origin) < 14.0:
                channels["PokeFront"].push(6.0)
                channels["Squash"].push(2.0)
            else:
                channels["StretchUp"].push(5.0)
                channels["LeanLeft"].push(3.0)
                channels["LeanRight"].push(3.0)
            get_viewport().set_input_as_handled()
    elif event is InputEventMouseMotion and is_dragging:
        latest_mouse = event.position
        get_viewport().set_input_as_handled()

func impact(strength: float) -> void:
    channels["Impact"].push(clampf(strength, 0.0, 10.0))
    channels["Squash"].push(clampf(strength * 0.5, 0.0, 5.0))

func celebrate() -> void:
    channels["HappyWiggle"].push(4.0)
