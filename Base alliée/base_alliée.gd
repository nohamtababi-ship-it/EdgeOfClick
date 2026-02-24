extends StaticBody2D

@onready var health = $Health if has_node("Health") else null

func _ready():
	add_to_group("Allié")
	
	if health:
		health.max_health = 250
		health.current_health = health.max_health
		health.died.connect(_on_died)
		print("✅ Base alliée: ", health.max_health, " PV")
		
func _on_died():
	print("💥 BASE ALLIÉE DÉTRUITE ! GAME OVER !")
	
	var game_over_screen = get_tree().root.find_child("GameOverScreen", true, false)
	if game_over_screen and game_over_screen.has_method("game_over"):
		game_over_screen.game_over()
	
	queue_free()
