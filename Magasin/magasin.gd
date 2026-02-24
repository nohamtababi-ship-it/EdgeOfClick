extends Panel

signal shop_closed

func _ready():
	modulate.a = 0.9  # Semi-transparent
	scale = Vector2(1.2, 0.8)
	
	# Connecte les 3 boutons
	var hbox = $HBoxContainer
	if hbox:
		var buttons = hbox.get_children()
		for i in buttons.size():
			var btn = buttons[i]
			if btn is Button:
				btn.pressed.connect(func(): _buy_unit(i + 1))

func _gui_input(event):
	# Ferme shop si clic dehors boutons
	if event is InputEventMouseButton and event.pressed:
		if event.position.x < 50 or event.position.x > 450:
			close_shop()

func _buy_unit(unit_id: int):
	print("✅ ACHAT UNITÉ ", unit_id)
	
	# Spawn unité selon bouton
	var main_scene = get_tree().current_scene
	match unit_id:
		1:  # Bouton gauche (pas chère)
			if main_scene.ally_scene1:
				var ally = main_scene.ally_scene1.instantiate()
				ally.global_position = Vector2(200, 500)
				main_scene.add_child(ally)
		2:  # Bouton milieu (moyen)
			if main_scene.ally_scene2:
				var ally = main_scene.ally_scene2.instantiate()
				ally.global_position = Vector2(200, 500)
				main_scene.add_child(ally)
		3:  # Bouton droite (chère)
			if main_scene.ally_scene3:
				var ally = main_scene.ally_scene3.instantiate()
				ally.global_position = Vector2(200, 500)
				main_scene.add_child(ally)
	
	close_shop()

func close_shop():
	get_tree().paused = false
	queue_free()  # Ferme shop
