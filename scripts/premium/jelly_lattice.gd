extends RefCounted
## Jelly Physics 2.0 — 13 signed, coupled 3D damped spring controls.
## Units are local character metres. Simulation runs on the Godot physics clock.
const NODE_COUNT: int = 13
const MAX_OFFSET: float = 0.64
const SPRING_K: float = 64.0
const COUPLING_K: float = 23.0
const DAMPING: float = 4.9
const MAX_VELOCITY: float = 13.0

var anchors: PackedVector3Array = PackedVector3Array()
var offsets: PackedVector3Array = PackedVector3Array()
var velocities: PackedVector3Array = PackedVector3Array()
var links: Array[PackedInt32Array] = []
var held_index: int = -1
var held_target: Vector3 = Vector3.ZERO
var held_strength: float = 28.0
var last_applied_step: float = 0.0

func _init() -> void:
    anchors.append(Vector3(0.0, 0.92, 0.0))
    for ring in range(3):
        var y: float = [1.43, 0.92, 0.43][ring]
        var radius: float = [0.42, 0.72, 0.53][ring]
        for quadrant in range(4):
            var angle: float = float(quadrant) * TAU / 4.0
            anchors.append(Vector3(cos(angle) * radius, y, sin(angle) * radius))
    for i in range(NODE_COUNT):
        offsets.append(Vector3.ZERO)
        velocities.append(Vector3.ZERO)
        var adjacency := PackedInt32Array()
        if i == 0:
            for n in range(1, 9):
                adjacency.append(n)
        else:
            var ring_index: int = int((i - 1) / 4)
            var cardinal: int = (i - 1) % 4
            adjacency.append(0)
            adjacency.append(1 + ring_index * 4 + (cardinal + 1) % 4)
            adjacency.append(1 + ring_index * 4 + (cardinal + 3) % 4)
            if ring_index > 0:
                adjacency.append(1 + (ring_index - 1) * 4 + cardinal)
            if ring_index < 2:
                adjacency.append(1 + (ring_index + 1) * 4 + cardinal)
        links.append(adjacency)

func closest_anchor(local_point: Vector3) -> int:
    var index: int = 1
    var nearest: float = INF
    for i in range(1, NODE_COUNT):
        var d: float = anchors[i].distance_squared_to(local_point)
        if d < nearest:
            index = i
            nearest = d
    return index

func grab(local_point: Vector3) -> void:
    held_index = closest_anchor(local_point)
    held_target = offsets[held_index]

func drag(displacement: Vector3) -> void:
    if held_index < 0:
        return
    held_target = displacement.limit_length(MAX_OFFSET * 0.96)

func release(fling: Vector3) -> void:
    if held_index < 0:
        return
    velocities[held_index] = (velocities[held_index] + fling.limit_length(7.0)).limit_length(MAX_VELOCITY)
    for neighbor in links[held_index]:
        velocities[neighbor] = (velocities[neighbor] + fling * 0.17).limit_length(MAX_VELOCITY)
    held_index = -1
    held_target = Vector3.ZERO

func disturb(local_point: Vector3, impulse: Vector3, radius: float = 0.80) -> void:
    var effective_radius: float = maxf(0.12, radius)
    for i in range(NODE_COUNT):
        var distance: float = anchors[i].distance_to(local_point)
        var weight: float = exp(-distance * distance / (2.0 * effective_radius * effective_radius))
        velocities[i] = (velocities[i] + impulse * weight).limit_length(MAX_VELOCITY)

func impact(strength: float) -> void:
    # Compress the upper/lower rings, widen side controls, then rebound.
    var force: float = clampf(strength, 0.0, 12.0)
    for i in range(1, NODE_COUNT):
        var dir: Vector3 = anchors[i] - Vector3(0, 0.88, 0)
        var spread := Vector3(dir.x, 0, dir.z).normalized()
        var impulse := Vector3.ZERO
        if i <= 4:
            impulse.y = -force * 0.46
        elif i >= 9:
            impulse.y = force * 0.22
        impulse += spread * force * 0.18
        velocities[i] = (velocities[i] + impulse).limit_length(MAX_VELOCITY)

func movement(velocity_delta: Vector3, speed: float, turning: float) -> void:
    var inertia: Vector3 = (-velocity_delta * 0.34).limit_length(1.5)
    disturb(Vector3(0, 1.05, 0), inertia, 1.08)
    if absf(turning) > 0.035:
        for i in range(1, 9):
            var sideways := Vector3(-anchors[i].z, 0, anchors[i].x).normalized()
            velocities[i] = (velocities[i] + sideways * turning * 0.18).limit_length(MAX_VELOCITY)
    if speed > 0.10:
        var sway: float = sin(Time.get_ticks_msec() * 0.015) * minf(speed, 2.5) * 0.022
        velocities[1] += Vector3(sway, 0, 0)
        velocities[3] += Vector3(-sway, 0, 0)

func step(delta: float) -> void:
    # Fixed/semi-implicit stepping makes short frame delays safe in browsers.
    var capped: float = minf(maxf(delta, 0.0), 0.12)
    var iterations: int = maxi(1, ceili(capped * 120.0))
    var h: float = capped / float(iterations)
    for substep in range(iterations):
        var next_velocity := PackedVector3Array()
        var next_offset := PackedVector3Array()
        for i in range(NODE_COUNT):
            var x: Vector3 = offsets[i]
            var v: Vector3 = velocities[i]
            var force: Vector3 = -SPRING_K * x - DAMPING * v
            for neighbor in links[i]:
                force += COUPLING_K * (offsets[neighbor] - x) / float(links[i].size())
            if i == held_index:
                force += held_strength * (held_target - x)
            v = (v + force * h).limit_length(MAX_VELOCITY)
            x = (x + v * h).limit_length(MAX_OFFSET)
            if x.length() >= MAX_OFFSET - 0.001 and v.dot(x) > 0.0:
                v -= x.normalized() * v.dot(x) * 0.55
            next_velocity.append(v)
            next_offset.append(x)
        offsets = next_offset
        velocities = next_velocity
    last_applied_step = capped

func max_displacement() -> float:
    var largest: float = 0.0
    for o in offsets:
        largest = maxf(largest, o.length())
    return largest

func total_energy() -> float:
    var result: float = 0.0
    for i in range(NODE_COUNT):
        result += 0.5 * SPRING_K * offsets[i].length_squared() + 0.5 * velocities[i].length_squared()
    return result

func reset() -> void:
    held_index = -1
    for i in range(NODE_COUNT):
        offsets[i] = Vector3.ZERO
        velocities[i] = Vector3.ZERO
