extends SceneTree

const MathChallenges = preload("res://scripts/math_challenges.gd")

func _initialize() -> void:
    for grade in range(1, 5):
        for seed_value in range(250):
            var challenge: Dictionary = MathChallenges.make(grade, seed_value + 100)
            var options: Array = challenge.get("options", [])
            if options.size() != 3:
                push_error("Challenge does not have three options")
                quit(1)
                return
            var found: int = 0
            var unique_answers: Dictionary = {}
            for answer_option in options:
                if int(answer_option) == int(challenge.get("answer", -100)):
                    found += 1
                unique_answers[answer_option] = true
            if found != 1 or unique_answers.size() != 3:
                push_error("Challenge has duplicate or absent correct answers")
                quit(1)
                return
    print("PASS: 1000 unique math challenge sets")
    quit(0)
