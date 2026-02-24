# HealthBar.gd SIMPLIFIÉ (lit directement health du parent)
extends ProgressBar

@onready var target_health = get_parent().get_node("Health")  # Lit $Health du parent

func _ready():
	if target_health:
		max_value = target_health.max_health
		value = target_health.current_health
		update_style()
	else:
		print("❌ Health non trouvé dans parent")

func _process(_delta):
	if target_health and is_instance_valid(target_health):
		# LIT DIRECTEMENT les variables (pas de signal !)
		max_value = target_health.max_health
		value = target_health.current_health
		update_style()
		
		# Position sous le parent
		var parent_sprite = get_parent().get_node_or_null("Sprite2D")
		if parent_sprite and parent_sprite.texture:
			var size = parent_sprite.texture.get_size() * get_parent().scale
			global_position = get_parent().global_position + Vector2(0, size.y / 2 + 8)
			size.x = size.x * 0.8
	else:
		visible = false

func update_style():
	# Même code couleurs (vert/orange/rouge)
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	add_theme_stylebox_override("background", bg_style)
	
	var fill_style = StyleBoxFlat.new()
	var ratio = value / max_value
	fill_style.bg_color = Color.GREEN if ratio > 0.6 else (Color.ORANGE if ratio > 0.3 else Color.RED)
	add_theme_stylebox_override("fill", fill_style)
