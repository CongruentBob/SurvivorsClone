extends Area2D

@export var damage = 1
@onready var collision = $CollisionShape2D
@onready var disable_hit_box_timer = $DisableHitBoxTimer

func temp_disable():
	collision.call_deferred("set", "disabled", true)
	disable_hit_box_timer.start()


func _on_disable_hit_box_timer_timeout():
	collision.call_deferred("set", "disabled", false)
