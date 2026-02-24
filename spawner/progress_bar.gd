# ProgressBarWaves.gd (ATTACHEZ à ProgressBar enfant du Spawner)
extends ProgressBar

@onready var spawner: Node = get_parent()
@onready var wave_label: Label = get_node("../Wavee")  # ← Sûr !


func _ready():
	value = 0
	wave_label.text = "Vague 0"  # Supprimez if (toujours existe)

func _process(_delta):
	var current_wave = spawner.current_wave  # Direct
	value = float(current_wave)
	wave_label.text = "Vague %d" % [current_wave]
	modulate = Color(1 - value/100, value/100, 0)
	
	if current_wave >= 9:
		tween_pulse()


# Animation BOSS
func tween_pulse():
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.5)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.5)

# Alternative : Signaux (plus propre)
# Dans Spawner.gd ajoutez :
signal wave_started(wave_number)

# Dans start_wave() : wave_started.emit(current_wave)
# Dans ProgressBar : spawner.wave_started.connect(_on_wave_start)

func _on_wave_start(wave: int):
	value = float(wave)
	if wave_label:
		wave_label.text = "Vague %d" % [wave]
