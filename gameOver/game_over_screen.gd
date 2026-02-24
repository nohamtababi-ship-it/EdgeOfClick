# game_over_screen.gd
extends CanvasLayer

@onready var restart_button = $VBoxContainer/RestartButton
@onready var quitter_button = $VBoxContainer/QuitterButton
@onready var gameoversound: AudioStreamPlayer2D = $gameoversound
@onready var boutton: AudioStreamPlayer2D = $boutton
@onready var guitaristesound: AudioStreamPlayer2D = $guitaristesound

func _ready():
	visible = false

func game_over():
	visible = true
	get_tree().paused = true
	gameoversound.play()

func _on_restart_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quitter_button_pressed():
	get_tree().quit()


func _on_restart_button_mouse_entered() -> void:
	boutton.play()


func _on_quitter_button_mouse_entered() -> void:
	boutton.play()
