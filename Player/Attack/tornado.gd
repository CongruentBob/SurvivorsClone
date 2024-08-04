extends Area2D

var level = 1
var speed = 100
var damage = 5
var knockback_force = 100
var attack_size = 1.0

var target_position = Vector2.ZERO
var direction_to_target = Vector2.ZERO
var initial_direction = Vector2.LEFT
var direction_less = Vector2.ZERO
var direction_more = Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group("player")

signal destroyed(object)

func _ready():
	match level:
		1:
			speed = 100
			damage = 5
			knockback_force = 100
			attack_size = 1.0
	
	direction_less = Vector2(initial_direction.x + randf_range(-1, -0.25) * initial_direction.y, initial_direction.y + randf_range(-1, -0.25) * initial_direction.x).normalized()
	direction_more = Vector2(initial_direction.x + randf_range(0.25, 1) * initial_direction.y, initial_direction.y + randf_range(0.25, 1) * initial_direction.x).normalized()
	
	var initial_tween = create_tween().set_parallel(true)
	initial_tween.tween_property(self, "scale", Vector2(1,1) * attack_size, 3).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	var final_speed = speed
	speed = speed / 5.0
	initial_tween.tween_property(self, "speed", final_speed, 6).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	initial_tween.play()
	
	var tween = create_tween().set_loops(3)
	var coin_flip = randi_range(0, 1)
	if coin_flip == 0:
		direction_to_target = direction_less
		tween.tween_property(self, "direction_to_target", direction_more, 2)
		tween.tween_property(self, "direction_to_target", direction_less, 2)
	else:
		direction_to_target = direction_more
		tween.tween_property(self, "direction_to_target", direction_less, 2)
		tween.tween_property(self, "direction_to_target", direction_more, 2)
	tween.play()
	
func _physics_process(delta):
	position += direction_to_target * speed * delta

func enemy_hit(charge = 1):
	pass

func _on_timer_timeout():
	destroyed.emit()
	queue_free()
