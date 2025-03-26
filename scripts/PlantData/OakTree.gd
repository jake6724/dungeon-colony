class_name OakTree
extends Plant

@onready var top_sprite = $TopSprite
@onready var bottom_sprite = $BottomSprite

func _ready():
	top_sprite.z_index = Constants.z_index_mapping["tree_top"]
	bottom_sprite.z_index = Constants.z_index_mapping["tree_bottom"]
	pass

func set_data() -> void:
	cname = "oak_tree"
	inspector_name = "Oak Tree"
	is_tree = true
