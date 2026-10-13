extends RigidBody2D
class_name JellyBlob

var number: int = 1
var radius: float = 25.0
var tint: Color = Color("f9cae0")
var joining: bool = false
var lifetime: float = 0.0
var shine: float = 0.0

func configure(value: int, size: float, color: Color) -> void:
    number = value
    radius = size
    tint = color
    collision_layer = 4
    collision_mask = 12
    mass = clampf(float(value) * 0.12, 0.8, 10.0)
    gravity_scale = 1.3
    linear_damp = 0.6
    angular_damp = 0.85
    continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE
    var material := PhysicsMaterial.new()
    material.bounce = 0.24
    material.friction = 0.57
    physics_material_override = material
    var collision := CollisionShape2D.new()
    var shape := CircleShape2D.new()
    shape.radius = radius
    collision.shape = shape
    add_child(collision)

func _process(delta: float) -> void:
    lifetime += delta
    shine = maxf(0.0, shine - delta)
    queue_redraw()

func _draw() -> void:
    draw_circle(Vector2(0, 5), radius + 2, Color(0.32, 0.43, 0.35, 0.17))
    draw_circle(Vector2.ZERO, radius, tint.darkened(0.14))
    draw_circle(Vector2(0, -3), radius - 2, tint)
    draw_circle(Vector2(-radius * 0.4, -radius * 0.45), radius * 0.28, Color(1, 1, 1, 0.33))
    var fontsize: int = clampi(roundi(radius * 0.90), 19, 42)
    draw_string(ThemeDB.fallback_font, Vector2(-radius * 0.85, fontsize * 0.34), str(number), HORIZONTAL_ALIGNMENT_CENTER, radius * 1.7, fontsize, Color("414d67"))
    if shine > 0.0:
        draw_arc(Vector2.ZERO, radius + 5.0, 0, TAU, 32, Color(1, 0.94, 0.44, shine), 4.0, true)
