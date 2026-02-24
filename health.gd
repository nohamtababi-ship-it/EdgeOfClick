extends Node  # ou Control

signal health_changed(new_health)  # ← AJOUTE ÇA !
signal died

@export var max_health: float = 100.0
var current_health: float = 100.0 : set = _set_health

func _set_health(value: float):
	current_health = clampf(value, 0, max_health)
	health_changed.emit(current_health)  # ← ÉMET À CHAQUE CHANGEMENT !
	
	if current_health <= 0:
		died.emit()

func take_damage(damage: float):
	_set_health(current_health - damage)
