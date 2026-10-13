extends RefCounted
## Production-intent, timestep-stable damped spring for jelly morph channels.
## Independent of mesh assets; values are normalized shape key amplitudes.
var value: float = 0.0
var velocity: float = 0.0
var target: float = 0.0
var stiffness: float = 90.0
var damping: float = 15.0
var mass: float = 1.0

func configure(k: float, c: float, m: float = 1.0) -> void:
    stiffness = maxf(1.0, k)
    damping = maxf(0.1, c)
    mass = maxf(0.05, m)

func push(amount: float) -> void:
    velocity = clampf(velocity + amount, -20.0, 20.0)

func reset() -> void:
    value = 0.0
    velocity = 0.0
    target = 0.0

func step(delta: float) -> float:
    var slices: int = maxi(1, ceili(delta / (1.0 / 120.0)))
    var h: float = minf(delta, 0.125) / float(slices)
    for i in range(slices):
        var force: float = -stiffness * (value - target) - damping * velocity
        velocity = clampf(velocity + force / mass * h, -25.0, 25.0)
        value = clampf(value + velocity * h, -0.1, 1.1)
    return clampf(value, 0.0, 1.0)
