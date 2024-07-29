extends Area2D

var level = 1
var hit_points = 1
var speed = 100
var damage = 5
var knockback_force = 100
var attack_size = 1.0

var target_position = Vector2.ZERO
var direction_to_target = Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group("player")

signal destroyed(object)

func _ready():
	direction_to_target = global_position.direction_to(target_position)
	rotation = direction_to_target.angle() + 3 * PI / 4
	match level:
		1:
			hit_points = 2
			speed = 100
			damage = 5
			knockback_force = 100
			attack_size = 1.0
			
	var tween = create_tween()
	tween.tween_property(self,"scale", Vector2(1,1) * attack_size, 1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	
func _physics_process(delta):
	position += direction_to_target * speed * delta

func enemy_hit(charge = 1):
	hit_points -= charge
	if hit_points <= 0:
		destroyed.emit(self)
		queue_free()


func _on_timer_timeout():
	destroyed.emit(self)
	queue_free()
