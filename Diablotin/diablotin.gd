extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var explosion_effect: GPUParticles2D = $ExplosionEffect if has_node("ExplosionEffect") else null
@onready var health_component = $Health if has_node("Health") else null
@onready var diabltinsound: AudioStreamPlayer2D = $diabltinsound

var speed = 70.0
var screen_size: Vector2
var is_dead = false
var explosion_damage = 20

func _ready():
	screen_size = get_viewport_rect().size

	if health_component:
		health_component.max_health = 1
		health_component.current_health = 1
		health_component.died.connect(_on_died)
		if health_component.has_signal("health_changed"):
			health_component.health_changed.connect(_on_health_changed)
	
	if explosion_effect:
		explosion_effect.emitting = false
		explosion_effect.one_shot = true

func _physics_process(_delta):
	if is_dead: return
	
	# ✅ ARRÊT IMMÉDIAT si collision détectée
	if detect_collision():
		return
	
	velocity.x = -speed
	move_and_slide()
	
	global_position.x = clamp(global_position.x, 100, screen_size.x - 140)
	global_position.y = clamp(global_position.y, 446, 605)
	
	if sprite:
		sprite.rotation_degrees -= 8

func detect_collision():
	# ✅ DÉTECTION AVANT move_and_slide()
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision and collision.get_collider():
			var collider = collision.get_collider()
			if collider.has_method("is_in_group"):
				if collider.is_in_group("Allié") or collider.is_in_group("Chapiteau"):
					print("💥 Diablotin détecte ", collider.name)
					explode_on_target(collider)
					return true
	
	# Base atteinte
	if global_position.x <= 140:
		var base = _trouver_base()
		if base:
			explode_on_target(base)
			return true
	
	return false

func _trouver_base():
	var chapiteaux = get_tree().get_nodes_in_group("Chapiteau")
	if chapiteaux.size() > 0:
		return chapiteaux[0]
	return null

func explode_on_target(target):
	if is_dead or target == null: return
	
	if target.has_node("Health"):
		var target_health = target.get_node("Health")
		if target_health and target_health.has_method("take_damage"):
			target_health.take_damage(explosion_damage)
			print("💥 Diablotin explose sur ", target.name, " ! Dégâts: ", explosion_damage)
			diabltinsound.play()
	
	die()

func die():
	if is_dead: return
	is_dead = true
	
	if sprite:
		sprite.visible = false
	set_physics_process(false)
	
	if explosion_effect:
		remove_child(explosion_effect)
		var parent = get_parent()
		if parent:
			parent.add_child(explosion_effect)
			explosion_effect.global_position = global_position
			explosion_effect.restart()
	
	queue_free()

func _on_died():
	die()

func _on_health_changed(new_health):
	print("Santé du diablotin: ", new_health)
