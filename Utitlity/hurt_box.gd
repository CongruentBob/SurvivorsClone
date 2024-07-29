extends Area2D

@export_enum("Cooldown", "HitOnce", "DisableHitBox") var HurtBoxType = 0

@onready var collision = $CollisionShape2D
@onready var disable_timer = $DisableTimer

signal hurt(damage, knockback_direction, knockback_magnitude)

var hit_once_array = []

func _on_area_entered(area):
	if area.is_in_group("attack"):
		if area.get("damage") != null:
			match HurtBoxType:
				0: #Cooldown
					collision.call_deferred("set", "disabled", true)
					disable_timer.start()
				1: #HitOnce
					if not hit_once_array.has(area):
						hit_once_array.append(area)
						if (area.has_signal("destroyed")):
							if not area.is_connected("destroyed", Callable(self, "remove_from_list")):
								area.connect("destroyed", Callable(self, "remove_from_list"))
					else:
						return
				2: #DisableHitBox
					if area.has_method("temp_disable"):
						area.temp_disable()
			var damage = area.damage
			var knockback_direction = Vector2.ZERO
			var knockback_magnitude = 1
			if not area.get("direction_to_target") == null:
				knockback_direction = area.direction_to_target
			if not area.get("knockback_force") == null:
				knockback_magnitude = area.knockback_force
			
			emit_signal("hurt", damage, knockback_direction, knockback_magnitude)
			if area.has_method("enemy_hit"):
				area.enemy_hit()

func remove_from_list(object):
	if hit_once_array.has(object):
		hit_once_array.erase(object)

func _on_disable_timer_timeout():
	collision.call_deferred("set", "disabled", false)
