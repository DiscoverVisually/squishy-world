extends Node3D
## Reusable visual controller for original Blender .glb morph targets.
## Attach under CharacterBody3D; no collisions changed by visual stretching.
const Spring = preload("res://scripts/premium/jelly_spring.gd")
@export var body_mesh: MeshInstance3D
@export var input_camera: Camera3D
@export var character_collider: CollisionObject3D
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
