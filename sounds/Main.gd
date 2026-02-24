extends Node2D



# --- EXPORT VARIABLES ---
@export var target_scene: PackedScene
@export var ally_scene1: PackedScene
@export var ally_scene2: PackedScene
@export var ally_scene3: PackedScene
@export var ally_scene4: PackedScene
@export var ally_scene5: PackedScene
@export var ally_scene6: PackedScene

# --- UI ---
@onready var clicks_label: Label = $CanvasLayer2/Clicks

# --- SONS ---
@onready var ambiance: AudioStreamPlayer2D = $ambiance
@onready var musique: AudioStreamPlayer2D = $musique
@onready var boutton: AudioStreamPlayer2D = $boutton


# --- VARIABLES ---
var score: int = 0
var spawner: Node
var game_won: bool = false  # ← FIX : État victoire

# --- READY ---
func _ready():
	spawn_target()
	update_score_display()
	
	var base_ennemie = find_child("BaseEnnemie", true)
	if base_ennemie and base_ennemie.has_signal("base_destroyed"):
		base_ennemie.base_destroyed.connect(_on_base_ennemie_destroyed)
		print("✅ Signal victoire connecté")
	
	spawner = find_child("Spawner", true, false)
	if spawner:
		print("✅ Spawner trouvé")
	ambiance.play()
	musique.play()
		

# --- TARGET (BLOQUÉ APRÈS VICTOIRE) ---
func spawn_target():
	if game_won: return
	
	var target = target_scene.instantiate()
	var screen_size = get_viewport_rect().size
	var margin = 150
	
	target.position = Vector2(
		randf_range(margin, screen_size.x - margin),
		randf_range(margin, screen_size.y - 600)
	)
	target.clicked.connect(_on_target_clicked)
	add_child(target)

func _on_target_clicked():
	if game_won: return
	score += 1
	update_score_display()
	spawn_target()

func update_score_display():
	if clicks_label:
		clicks_label.text = str(score)

# --- ALLIES (BLOQUÉS APRÈS VICTOIRE) ---
func _on_tambour_pressed() -> void:
	if game_won: return
	_spawn_ally(ally_scene1, 3)

func _on_flute_pressed() -> void:
	if game_won: return
	_spawn_ally(ally_scene2, 6)

func _on_guitard_pressed() -> void:
	if game_won: return
	_spawn_ally(ally_scene3, 9)
func _on_jordan_pressed() -> void:
	_spawn_ally(ally_scene4, 0)
func _on_mohammed_pressed() -> void:
	_spawn_ally(ally_scene5, 0)
func _on_erick_pressed() -> void:
	_spawn_ally(ally_scene6, 0)

func _spawn_ally(scene: PackedScene, cost: int):
	if score >= cost:
		score -= cost
		update_score_display()
		var ally = scene.instantiate()
		ally.global_position = Vector2(200, 500)
		add_child(ally)

# --- VICTOIRE TOTALE (FIX ULTIME) ---
func _on_base_ennemie_destroyed():
	if game_won: return
	game_won = true
	
	print("🏆 BASE ENNEMIE DÉTRUITE → VICTOIRE TOTALE !")
	victoire()
	
	# ❌ SUPPRIME LE SPAWNER COMPLÈTEMENT
	if spawner and is_instance_valid(spawner):
		spawner.queue_free()
		print("🗑️ SPAWNER DÉTRUIT DÉFINITIVEMENT")
	
	# ❌ NETTOIE TOUS LES ENNEMIS
	for node in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(node):
			node.queue_free()
	
	# ❌ PAUSE TOTALE
	get_tree().paused = true
	set_physics_process(false)
	set_process(false)
	print("⏸️ JEU STOPPÉ → Victoire parfaite !")

# --- GAME OVER ---
func game_over():
	var gos = find_child("GameOverScreen", true, false)
	if gos and gos.has_method("game_over"):
		gos.game_over()

# --- VICTOIRE ---
func victoire():
	var vs = find_child("Victoryscreen", true, false)
	if vs and vs.has_method("victoire"):
		vs.victoire()
		print("✅ Victoirescreen activé !")
	else:
		push_error("❌ Victoirescreen manquant !")
		


func _on_tambour_mouse_entered() -> void:
	boutton.play()



func _on_flute_mouse_entered() -> void:
	boutton.play()
	
	


func _on_guitard_mouse_entered() -> void:
	boutton.play()
