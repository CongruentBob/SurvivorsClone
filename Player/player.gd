extends CharacterBody2D


const MOVEMENT_SPEED = 40.0
var hit_points = 80

#Attacks
var ice_spear = preload("res://Player/Attack/ice_spear.tscn")

#AttackNodes
@onready var ice_spear_timer = %IceSpearTimer
@onready var ice_spear_attack_timer = %IceSpearAttackTimer

#IceSpear
var ice_spear_ammo = 0
var ice_spear_base_ammo = 1
var ice_spear_attack_speed = 1.5
var ice_spear_level = 1

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
