extends Control
@onready var first_level = preload("res://scene_principale.tscn")
@onready var musique_ecranp: AudioStreamPlayer2D = $musique_ecranp
@onready var boutton: AudioStreamPlayer2D = $boutton




func _ready():
	musique_ecranp.play()

func _on_start_btm_button_down() -> void:
	get_tree().change_scene_to_packed(first_level)

func _on_tutoriel_btm_button_down() -> void:
	pass # Replace with function body.

func _on_quitter_btm_button_down() -> void:
	get_tree().quit()


func _on_start_btm_mouse_entered() -> void:
	boutton.play()


func _on_tutoriel_btm_mouse_entered() -> void:
	boutton.play()


func _on_quitter_btm_mouse_entered() -> void:
	boutton.play()
