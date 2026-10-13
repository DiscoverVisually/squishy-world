extends RefCounted
class_name MergeRules

static func grade_config(grade: int) -> Dictionary:
    var base: int = 1 << (clampi(grade, 1, 4) - 1)
    var help: String = "Spájaj rovnaké čísla sčítaním."
    if grade >= 3:
        help = "Hľadaj násobky a zdvojuj."
    return {"base": base, "goal": base * 8, "help": help}

static func next_value(base: int, step: int) -> int:
    const pattern: Array[int] = [1, 1, 2, 1, 1, 2, 2, 1, 1, 2, 2, 1]
    return base * pattern[step % pattern.size()]
