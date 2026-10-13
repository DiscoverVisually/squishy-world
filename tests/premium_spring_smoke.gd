extends SceneTree
const Spring = preload("res://scripts/premium/jelly_spring.gd")
func _initialize() -> void:
    var s = Spring.new()
    s.configure(90.0, 15.0)
    for cycle in range(100):
        s.target = 1.0
        for i in range(12):
            s.step(1.0 / 60.0)
        s.target = 0.0
        s.push(1.5)
        for j in range(48):
            var weight: float = s.step(1.0 / 60.0)
            if not is_finite(weight) or weight < 0.0 or weight > 1.0:
                push_error("Unstable morph spring in cycle %d" % cycle)
                quit(1)
                return
    if absf(s.value) > 0.08:
        push_error("Spring did not settle: %f" % s.value)
        quit(1)
        return
    print("PASS: 100 spring-stretch release cycles, bounded stable deformation")
    quit(0)
