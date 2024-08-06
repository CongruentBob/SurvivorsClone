extends Area2D

var level = 1
var speed = 200.0
var damage = 10
var knockback_force = 100
var paths_count = 1
var attack_size = 1.0
var attack_speed = 4.0

var target_position = Vector2.ZERO
var targets = []

var target_direction = Vector2.ZERO
var reset_position = Vector2.ZERO

var regular_sprite = preload("res://Textures/Items/Weapons/javelin_3_new.png")
var attack_sprite = preload("res://Textures/Items/Weapons/javelin_3_new_attack.png")

@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var attack_timer = $AttackTimer
@onready var change_direction_timer = $ChangeDirectionTimer
@onready var reset_position_timer = $ResetPositionTimer
@onready var attack_sound = $AttackSound

signal destroyed(object)

func _ready():
	update_javelin()

func update_javelin():
	match level:
		1:
			speed = 200
			damage = 10
			knockback_force = 100
			paths_count = 1
			attack_size = 1.0
			attack_speed = 4.0
	
	scale = Vector2(1.0, 1.0) * attack_size
	attack_timer.wait_time = attack_speed
	
func _physics_process(delta):
	if targets.size() > 0:
		position += speed * target_direction * delta
	else:
		var player_direction = global_position.direction_to(reset_position)
		var distance_difference = global_position - player.global_position
		var return_speed = 20
		if abs(distance_difference.x) > 500 or abs(distance_difference.y) > 500:
			return_speed = 100
		position += player_direction * speed * delta
		rotation = global_position.direction_to(player.global_position).angle() + PI / 2

func add_paths():
	attack_sound.play()
	destroyed.emit()
	targets.clear()
	var counter = 0
	while counter < paths_count:
		var new_path = player.get_random_target()
		targets.append(new_path)
		counter += 1
		enable_attack(true)
	target_position = targets[0]
	process_path()
	
func process_path():
	target_direction = global_position.direction_to(target_position)
	change_direction_timer.start()

func enable_attack(enable = true):
	collision.call_deferred("set", "disabled", !enable)
	if enable == true:
		sprite.texture = attack_sprite
	else:
		sprite.texture = regular_sprite

func _on_attack_timer_timeout():
	add_paths()

func _on_change_direction_timer_timeout():
	if targets.size() > 0:
		targets.remove_at(0)
		if targets.size() > 0:
			target_position = targets[0]
			process_path()
			attack_sound.play()
			destroyed.emit()
		else:
			enable_attack(false)
	else:
		change_direction_timer.stop()
		attack_timer.start()
		enable_attack(false)

func _on_reset_position_timer_timeout():
	var angle = PI / 2 * (randi() % 4)
	var nsew = Vector2(cos(angle), sin(angle))
	reset_position = player.global_position + 50 * nsew
