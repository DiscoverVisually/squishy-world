extends RefCounted
class_name MathChallenges

## Answer sets are generated locally, with unique distractors and no external AI.
static func make(grade: int, seed_value: int) -> Dictionary:
    var rng := RandomNumberGenerator.new()
    rng.seed = seed_value
    var answer: int = 0
    var question: String = ""
    match clampi(grade, 1, 4):
        1:
            var a: int = rng.randi_range(1, 10)
            var b: int = rng.randi_range(1, 10)
            answer = a + b
            question = "%d + %d = ?" % [a, b]
        2:
            var a: int = rng.randi_range(10, 48)
            var b: int = rng.randi_range(10, 100 - a)
            answer = a + b
            question = "%d + %d = ?" % [a, b]
        3:
            var a: int = rng.randi_range(2, 9)
            var b: int = rng.randi_range(2, 9)
            answer = a * b
            question = "%d × %d = ?" % [a, b]
        4:
            var a: int = rng.randi_range(4, 12)
            var b: int = rng.randi_range(4, 12)
            var subtraction: int = rng.randi_range(2, maxi(2, a * b / 3))
            answer = a * b - subtraction
            question = "(%d × %d) − %d = ?" % [a, b, subtraction]
    var answers: Array[int] = [answer]
    var attempts: int = 0
    while answers.size() < 3 and attempts < 150:
        attempts += 1
        var difference: int = rng.randi_range(1, 10 if grade < 3 else 19)
        if rng.randi_range(0, 1) == 0:
            difference *= -1
        var candidate: int = answer + difference
        if candidate >= 0 and not answers.has(candidate):
            answers.append(candidate)
    var fallback: int = 1
    while answers.size() < 3:
        var candidate: int = answer + fallback
        if not answers.has(candidate):
            answers.append(candidate)
        fallback += 1
    for i in range(answers.size() - 1, 0, -1):
        var swap: int = rng.randi_range(0, i)
        var hold: int = answers[i]
        answers[i] = answers[swap]
        answers[swap] = hold
    return {"question": question, "answer": answer, "options": answers}
