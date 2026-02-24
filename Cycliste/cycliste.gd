extends CharacterBody2D

@export var speed : float = 70.0
@export var attack_range : float = 40.0
@export var attack_damage : int = 10
@export var attack_cooldown : float = 0.7
@onready var cyclistesound: AudioStreamPlayer2D = $cyclistesound

@onready var sprite = $AnimatedSprite2D if has_node("AnimatedSprite2D") else null
@onready var health = $Health if has_node("Health") else null

var can_attack : bool = true

func _ready():
	if health:
		health.max_health = 35
		health.current_health = 35
		health.died.connect(_on_died)

func _physics_process(_delta):
	var target = _trouver_cible()
	
	if target:
		var distance = global_position.distance_to(target.global_position)
		
		var is_base = target is StaticBody2D
		var at_base_position = global_position.x <= 140
		
		if is_base:
			if at_base_position:
				velocity = Vector2.ZERO
				if can_attack:
					_attaquer(target)
			else:
				velocity.x = -speed
				velocity.y = 0
				if sprite:
					sprite.play("walking")
		else:
			if distance > attack_range:
				var direction = (target.global_position - global_position).normalized()
				velocity = direction * speed
				if sprite:
					sprite.play("walking")
			else:
				velocity = Vector2.ZERO
				if can_attack:
					_attaquer(target)
	else:
		velocity.x = -speed
		velocity.y = 0
		if sprite:
			sprite.play("walking")
	
	move_and_slide()

func _trouver_cible():
	var cibles = get_tree().get_nodes_in_group("Allié")
	var proche = null
	var dist_min = INF
	
	for c in cibles:
		if c and is_instance_valid(c) and c.has_node("Health"):
			var d = global_position.distance_to(c.global_position)
			if d < dist_min:
				dist_min = d
				proche = c
	return proche

func _attaquer(target):
	if not target or not can_attack:
		return
	
	can_attack = false
	
	if sprite:
		sprite.play("attacking")
	
	if target.has_node("Health"):
		target.get_node("Health").take_damage(attack_damage)
		print("🚴 Cycliste attaque ", target.name, " (", attack_damage, " dégâts)")
		cyclistesound.play()
	
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func _on_died():
	queue_free()
