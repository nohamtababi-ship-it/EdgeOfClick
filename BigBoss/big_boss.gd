extends CharacterBody2D

@export var speed : float = 20.0              
@export var attack_damage : int = 80          
@export var attack_cooldown : float = 5.0     
@export var base_defeat_distance : float = 140.0

@onready var sprite = $AnimatedSprite2D
@onready var health = $Health
@onready var augh: AudioStreamPlayer2D = $augh

var attack_timer : float = 0.0
var screen_size : Vector2
var is_dead : bool = false

func _ready():
	screen_size = get_viewport_rect().size
	add_to_group("Ennemi")
	
	if health:
		health.max_health = 600
		health.current_health = 600
		health.died.connect(_on_died)

func _physics_process(_delta):
	if not is_inside_tree() or is_dead:
		velocity = Vector2.ZERO
		return
	
	attack_timer -= _delta
	
	velocity.x = -speed
	velocity.y = 0
	
	if attack_timer <= 0:
		_mega_attaque()
		attack_timer = attack_cooldown
	
	if global_position.x <= base_defeat_distance:
		_game_over()
	
	global_position.x = clamp(global_position.x, 0, screen_size.x)
	global_position.y = clamp(global_position.y, 100, screen_size.y - 100)
	
	if sprite:
		sprite.play("walking")
	
	move_and_slide()

func _mega_attaque():
	var allies = get_tree().get_nodes_in_group("Allié")
	print("💥💥 BIG BOSS MEGA BLAST 💥💥")
	
	for ally in allies:
		if is_instance_valid(ally) and ally.has_node("Health"):
			var distance = global_position.distance_to(ally.global_position)
			if distance <= 150:
				augh.play()
				ally.get_node("Health").take_damage(attack_damage)
				print("   → ", ally.name)

func _game_over():
	print("💀 BIG BOSS x=140 ! GAME OVER 💀")
	call_deferred("show_gameover")

func show_gameover():
	var game_over_screen = get_tree().root.find_child("GameOverScreen", true, false)
	if game_over_screen and game_over_screen.has_method("game_over"):
		game_over_screen.game_over()

func _on_died():
	is_dead = true
	call_deferred("show_victoire")  # ← TON CODE

func show_victoire():
	var victoire_screen = get_tree().root.find_child("Victoirescreen", true, false)
	if victoire_screen and victoire_screen.has_method("victoire"):
		victoire_screen.victoire()
	queue_free()
