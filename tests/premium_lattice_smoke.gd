extends SceneTree

const LATTICE = preload("res://scripts/premium/jelly_lattice.gd")

func _initialize() -> void:
    var sim = LATTICE.new()
    if sim.anchors.size() != 13:
        push_error("Expected exactly 13 linked springs")
        quit(1)
        return
    sim.grab(Vector3(0.72, 1.1, 0))
    sim.drag(Vector3(0.48, 0.30, 0.0))
    for i in range(30):
        sim.step(1.0 / 60.0)
    var grabbed: int = sim.held_index
    if grabbed < 1 or sim.offsets[grabbed].length() < 0.08:
        push_error("Failed to stretch local lattice")
        quit(1)
        return
    sim.release(Vector3(0.0, -0.8, 0.0))
    var start: Vector3 = sim.offsets[grabbed]
    var reversed: bool = false
    var neighbor_moved: bool = false
    var maxseen: float = 0.0
    for i in range(240):
        sim.step(1.0 / 60.0)
        if sim.offsets[grabbed].dot(start) < -0.006:
            reversed = true
        for j in range(1, 13):
            if j != grabbed and sim.offsets[j].length() > 0.008:
                neighbor_moved = true
        maxseen = maxf(maxseen, sim.max_displacement())
        for p in sim.offsets:
            if not is_finite(p.x) or not is_finite(p.y) or not is_finite(p.z):
                push_error("Non-finite displacement")
                quit(1)
                return
            if p.length() > 0.641:
                push_error("Displacement escaped bound")
                quit(1)
                return
    if not reversed or not neighbor_moved:
        push_error("No reverse oscillation or ripple propagation")
        quit(1)
        return
    if sim.max_displacement() > 0.04:
        push_error("Lattice did not settle within 4 seconds")
        quit(1)
        return
    for cycle in range(100):
        sim.disturb(Vector3(0.0, 1.10, 0.35), Vector3(0, 0, -4.0), 0.45)
        if cycle % 2 == 0:
            sim.impact(5.0)
        for j in range(25):
            sim.step(1.0 / 60.0)
        if sim.max_displacement() > 0.641:
            push_error("Instability in cycle %d" % cycle)
            quit(1)
            return
    for j in range(300):
        sim.step(1.0 / 60.0)
    if sim.max_displacement() > 0.04:
        push_error("Jelly did not recover its resting shape")
        quit(1)
        return
    print("PASS: drag, signed overshoot, neighbor ripple, 100 impacts, settle; max %.3f" % maxseen)
    quit(0)
