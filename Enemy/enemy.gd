extends CharacterBody2D

@export var movement_speed = 20.0
@export var hit_points = 10
@export var knockback_recovery = 3.5
@export var experience = 1
var knockback_vector = Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group("player")
@onready var loot_base = get_tree().get_first_node_in_group("loot")
@onready var sprite = $Sprite2D
@onready var animation = $AnimationPlayer
@onready var sound_hit = $SoundHit

var death_scene = preload("res://Enemy/explosion.tscn")
var loot_gem = preload("res://Objects/experience_gem.tscn")

signal destroyed(object)

func _ready():
	animation.play("walk")

func _physics_process(delta):
	knockback_vector = knockback_vector.move_toward(Vector2.ZERO, knockback_recovery)
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * movement_speed + knockback_vector
	move_and_slide()
	
	if direction.x > 0.1:
		sprite.flip_h = true
	elif direction.x < -0.1:
		sprite.flip_h = false


func _on_hurt_box_hurt(damage, knockback_direction, knockback_magnitude):
	hit_points -= damage
	knockback_vector = knockback_magnitude * knockback_direction
	if hit_points <= 0:
		death()
	else:
		sound_hit.play()

func death():
	var death_exp_scene = death_scene.instantiate()
	death_exp_scene.scale = sprite.scale
	death_exp_scene.global_position = global_position
	get_parent().call_deferred("add_child", death_exp_scene)
	var exp_gem = loot_gem.instantiate()
	exp_gem.global_position = global_position
	exp_gem.experience = experience
	loot_base.call_deferred("add_child", exp_gem)
	destroyed.emit(self)
	queue_free()
