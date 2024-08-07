extends CanvasLayer

@onready var experience_bar = %ExperienceBar
@onready var label = %LabelLevel

func set_experience(value = 1, max_value = 100):
	experience_bar.value = value
	experience_bar.max_value = max_value

func set_level(level):
	label.text = str("level ", level)
