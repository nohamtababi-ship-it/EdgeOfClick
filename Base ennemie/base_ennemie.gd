extends StaticBody2D

signal base_destroyed  # ← POUR Main.gd

@onready var health: Node = $Health

func _ready():
	if health:
		health.max_health = 225
		health.current_health = health.max_health
		health.died.connect(_on_died)
		print("✅ Base ennemie: ", health.max_health, " PV")

func _on_died():
	print("💥 BASE ENNEMIE DÉTRUITE !")
	base_destroyed.emit()  # ← SIGNAL → Main.victoire()
	queue_free()  # ← SIMPLE

# SUPPRIMÉ try_show_victory() → Main gère tout !
