extends Area2D
@onready var pop: AudioStreamPlayer2D = $pop

signal clicked

func _ready():
	input_pickable = true

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		print("Cible cliquée !")
		visible = false  # Cache visuel instant
		pop.play()
		clicked.emit()
		await pop.finished  # ← Attends fin son
		queue_free()
