extends SceneTree

const RULES = preload("res://scripts/merge_rules.gd")

func _initialize() -> void:
    for grade in range(1, 5):
        var cfg: Dictionary = RULES.grade_config(grade)
        var base: int = int(cfg["base"])
        var goal: int = int(cfg["goal"])
        if goal != base * 8:
            push_error("Incorrect merge goal")
            quit(1)
            return
        for i in range(100):
            var v: int = RULES.next_value(base, i)
            if v != base and v != base * 2:
                push_error("Unexpected merge drop value")
                quit(1)
                return
    print("PASS: 400 merge drop rules across four grade presets")
    quit(0)
