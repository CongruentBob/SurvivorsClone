extends Node2D

@export var spawns: Array[Spawn_info] = []

@onready var player = get_tree().get_first_node_in_group("player")

var time = 0


func _on_timer_timeout():
	time += 1
	var enemy_spawns = spawns
	for i in enemy_spawns:
		if time >= i.time_start and time <= i.time_end:
			if i.spawn_delay_counter < i.enemy_spawn_delay:
				i.spawn_delay_counter += 1
			else:
				i.spawn_delay_counter = 0
				var new_enemy = i.enemy
				var counter = 0
				while (counter < i.enemy_number):
					var enemy_spawn = new_enemy.instantiate()
					enemy_spawn.global_position = get_random_position()
					add_child(enemy_spawn)
					counter += 1


func get_random_position():
	var spawn_rect = get_viewport_rect().size * randf_range(1.1, 1.4)
	
	var spawn_angle_radians = randf_range(0, 2 * PI)
	var spawn_x_position = 0
	var spawn_y_position = 0
	
	if spawn_angle_radians < PI / 4 or spawn_angle_radians >= 7 * PI / 4:
		# top side
		spawn_x_position = player.global_position.x + spawn_rect.x * sin(spawn_angle_radians) / 2
		spawn_y_position = player.global_position.y - spawn_rect.y / 2
	elif spawn_angle_radians >= PI / 4 and spawn_angle_radians < 3 * PI / 4:
		# right side
		spawn_x_position = player.global_position.x + spawn_rect.x / 2
		spawn_y_position = player.global_position.y - spawn_rect.x * cos(spawn_angle_radians) / 2
	elif spawn_angle_radians >= 3 * PI / 4 and spawn_angle_radians < 5 * PI / 4:
		# bottom side
		spawn_x_position = player.global_position.x + spawn_rect.x * sin(spawn_angle_radians) / 2
		spawn_y_position = player.global_position.y + spawn_rect.y / 2
	elif spawn_angle_radians >= 5 * PI / 4 and spawn_angle_radians < 7 * PI / 4:
		# left side
		spawn_x_position = player.global_position.x - spawn_rect.x / 2
		spawn_y_position = player.global_position.y - spawn_rect.x * cos(spawn_angle_radians) / 2
	
	return Vector2(spawn_x_position, spawn_y_position)
