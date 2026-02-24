extends Node2D

# ===== CONFIGURATION FACILE =====
@export_group("Spawn Settings")
@export var initial_enemy_count = 5
@export var enemies_per_wave_increase = 2    # ← RÉDUIT (était 3)
@export var max_enemies_per_wave = 12        # ← NOUVEAU : LIMITE MAX
@export var spawn_delay = 1.2               # ← LÉGÈREMENT PLUS LENT

# ===== SCENES DES 5 ENNEMIS =====
@export_group("Enemy Scenes")
@export var clown_scene: PackedScene
@export var diablotin_scene: PackedScene
@export var cycliste_scene: PackedScene
@export var cracheur_de_feu_scene: PackedScene
@export var big_boss_scene: PackedScene

# ===== ZONES DE SPAWN =====
@export_group("Spawn Zones")
@export var spawn_area_min = Vector2(800, 446)
@export var spawn_area_max = Vector2(900, 605)

# ===== VAGUES BOSS =====
@export_group("Boss Settings")

# ===== ENNEMIS DISPONIBLES PAR VAGUE =====
var wave_unlocks = {
	1: ["diablotin"],
	2: ["clown", "diablotin"],
	4: ["clown", "diablotin", "cycliste"],
	6: ["clown", "diablotin", "cycliste", "cracheur_de_feu"]
}

var current_wave = 0
var enemies_alive = 0
var max_alive_at_once = 8  # ← NOUVEAU : MAX SIMULTANÉS

func _ready():
	print("🎮 Spawner initialisé")
	start_wave()

func start_wave():
	if not is_inside_tree() or get_tree() == null:
		print("⚠️ SceneTree non disponible")
		return
		
	current_wave += 1
	
	# ===== VAGUE BOSS ? =====
	if current_wave % 10 == 0:
		print("=== ⚠️ VAGUE BOSS ", current_wave, " ⚠️ ===")
		spawn_boss_wave()
	else:
		# Vague normale LIMITÉE
		var enemy_count = min(
			initial_enemy_count + (current_wave - 1) * enemies_per_wave_increase,
			max_enemies_per_wave
		)
		print("=== VAGUE ", current_wave, " : ", enemy_count, " ennemis (max ", max_enemies_per_wave, ") ===")
		spawn_enemies(enemy_count)

func spawn_boss_wave():
	if not is_inside_tree() or get_tree() == null:
		return
		
	if big_boss_scene == null:
		push_error("❌ Scene du big boss manquante !")
		return
	
	var boss = big_boss_scene.instantiate()
	boss.global_position = Vector2(
		(spawn_area_min.x + spawn_area_max.x) / 2,
		(spawn_area_min.y + spawn_area_max.y) / 2
	)
	boss.tree_exited.connect(_on_enemy_died)
	get_parent().add_child(boss)
	enemies_alive = 1
	print("🔥 BIG BOSS SPAWNÉ ! Ennemis vivants: ", enemies_alive)

func spawn_enemies(count: int):
	if not is_inside_tree() or get_tree() == null:
		return
		
	# ← CHANGÉ : Spawn seulement si assez de place
	for i in range(count):
		if enemies_alive >= max_alive_at_once:
			print("⏸️ Pause spawn: ", enemies_alive, "/", max_alive_at_once, " ennemis max")
			await _wait_for_space()
		
		if not is_inside_tree() or get_tree() == null:
			return
			
		await get_tree().create_timer(spawn_delay).timeout
		spawn_random_enemy()

func _wait_for_space():
	# Attend qu'il y ait de la place
	while enemies_alive >= max_alive_at_once:
		if not is_inside_tree() or get_tree() == null:
			return
		await get_tree().create_timer(0.5).timeout

func spawn_random_enemy():
	if not is_inside_tree() or get_tree() == null:
		return
		
	if enemies_alive >= max_alive_at_once:
		return  # ← SÉCURITÉ
		
	var available_enemies = get_available_enemies_for_wave(current_wave)
	if available_enemies.is_empty():
		push_error("❌ Aucun ennemi disponible pour la vague ", current_wave)
		return
	
	var enemy_type = available_enemies[randi() % available_enemies.size()]
	var enemy_scene = get_enemy_scene(enemy_type)
	
	if enemy_scene == null:
		push_error("❌ Scene manquante pour : " + enemy_type)
		return
	
	var enemy = enemy_scene.instantiate()
	enemy.global_position = Vector2(
		randf_range(spawn_area_min.x, spawn_area_max.x),
		randf_range(spawn_area_min.y, spawn_area_max.y)
	)
	enemy.tree_exited.connect(_on_enemy_died)
	get_parent().add_child(enemy)
	enemies_alive += 1
	print("✅ Spawné: ", enemy_type, " | Vivants: ", enemies_alive, "/", max_alive_at_once)

func get_available_enemies_for_wave(wave: int) -> Array:
	var unlock_wave = 1
	for w in wave_unlocks.keys():
		if w <= wave:
			unlock_wave = w
	return wave_unlocks[unlock_wave]

func get_enemy_scene(enemy_type: String) -> PackedScene:
	match enemy_type:
		"clown": return clown_scene
		"diablotin": return diablotin_scene
		"cycliste": return cycliste_scene
		"cracheur_de_feu": return cracheur_de_feu_scene
		"big_boss": return big_boss_scene
	return null

func _on_enemy_died():
	if not is_inside_tree():
		return
		
	enemies_alive -= 1
	print("💀 Ennemi mort | Restants: ", enemies_alive, "/", max_alive_at_once)
	
	if enemies_alive <= 0:
		call_deferred("_start_next_wave")

# ← SANS SHOP : SIMPLE PAUSE 2s
func _start_next_wave():
	if not is_inside_tree() or get_tree() == null:
		print("⚠️ SceneTree non disponible")
		return
		
	await get_tree().create_timer(4.0).timeout
	start_wave()
