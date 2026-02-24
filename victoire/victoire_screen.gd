extends CanvasLayer

@onready var restart_button = $VBoxContainer/RestartButton
@onready var quitter_button = $VBoxContainer/QuitterButton
@onready var victorysound: AudioStreamPlayer2D = $victorysound
@onready var boutton: AudioStreamPlayer2D = $boutton

func _ready():
	layer = 10  # ← Au lieu de 0
	visible = false

func victoire():
	layer = 10
	visible = true
	victorysound.play()



func _on_restart_button_pressed():
	print("🔄 Redémarrage...")
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quitter_button_pressed():
	print("👋 Quitter")
	get_tree().quit()


func _on_restart_button_mouse_entered() -> void:
	boutton.play()


func _on_quitter_button_mouse_entered() -> void:
	boutton.play()
