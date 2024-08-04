extends CharacterBody2D


const MOVEMENT_SPEED = 40.0
var hit_points = 80
var last_movement = Vector2.LEFT

#Attacks
var ice_spear = preload("res://Player/Attack/ice_spear.tscn")
var tornado = preload("res://Player/Attack/tornado.tscn")

#AttackNodes
@onready var ice_spear_timer = %IceSpearTimer
@onready var ice_spear_attack_timer = %IceSpearAttackTimer
@onready var tornado_timer = %TornadoTimer
@onready var tornado_attack_timer = %TornadoAttackTimer

#IceSpear
var ice_spear_ammo = 0
var ice_spear_base_ammo = 1
var ice_spear_attack_speed = 1.5
var ice_spear_level = 0

#Tornado
var tornado_ammo = 0
var tornado_base_ammo = 1
var tornado_attack_speed = 3
var tornado_level = 1

#Enemy
var close_enemies = []

@onready var sprite = $PlayerSprite
@onready var walkTimer = %WalkTimer

func _ready():
	attack()

func _physics_process(delta):
	movement()
	
func movement():
	var direction = Input.get_vector("left", "right", "up", "down")
	if direction.x > 0:
		sprite.flip_h = true
	elif direction.x < 0:
		sprite.flip_h = false
		
	if direction != Vector2.ZERO:
		last_movement = direction
		if walkTimer.is_stopped():
			if sprite.frame >= sprite.hframes - 1:
				sprite.frame = 0
			else:
				sprite.frame += 1
			walkTimer.start()
		
	velocity = direction.normalized() * MOVEMENT_SPEED
	move_and_slide()

func attack():
	if ice_spear_level > 0:
		ice_spear_timer.wait_time = ice_spear_attack_speed
		if ice_spear_timer.is_stopped():
			ice_spear_timer.start()
	if tornado_level > 0:
		tornado_timer.wait_time = tornado_attack_speed
		if tornado_timer.is_stopped():
			tornado_timer.start()

func _on_hurt_box_hurt(damage, knockback_direction, knockback_magnitude):
	hit_points -= damage
	print(hit_points)

func _on_ice_spear_timer_timeout():
	ice_spear_ammo += ice_spear_base_ammo
	ice_spear_attack_timer.start()

func _on_ice_spear_attack_timer_timeout():
	if ice_spear_ammo > 0:
		var ice_spear_attack = ice_spear.instantiate()
		ice_spear_attack.position = position
		ice_spear_attack.target_position = get_random_target()
		ice_spear_attack.level = ice_spear_level
		add_child(ice_spear_attack)
		ice_spear_ammo -= 1
		if ice_spear_ammo > 0:
			ice_spear_attack_timer.start()
		else:
			ice_spear_attack_timer.stop()

func _on_tornado_timer_timeout():
	tornado_ammo += tornado_base_ammo
	tornado_attack_timer.start()

func _on_tornado_attack_timer_timeout():
	if tornado_ammo > 0:
		var tornado_attack = tornado.instantiate()
		tornado_attack.position = position
		tornado_attack.initial_direction = last_movement
		tornado_attack.target_position = get_random_target()
		tornado_attack.level = tornado_level
		add_child(tornado_attack)
		tornado_ammo -= 1
		if tornado_ammo > 0:
			tornado_attack_timer.start()
		else:
			tornado_attack_timer.stop()

func get_random_target():
	if close_enemies.size() > 0:
		return close_enemies.pick_random().global_position
	else:
		return Vector2.UP

func _on_enemy_detection_area_body_entered(body):
	if not close_enemies.has(body):
		close_enemies.append(body)

func _on_enemy_detection_area_body_exited(body):
	if close_enemies.has(body):
		close_enemies.erase(body)
