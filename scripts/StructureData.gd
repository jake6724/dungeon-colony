class_name StructureData
extends Resource

@export var cname: String
@export var coords: Vector2 = Vector2(0, 0)
@export var id: int = 0
@export var texture: Texture
@export var unbuilt_texture: Texture
@export var width: int = 1
@export var height: int = 1
@export var resources_required: Dictionary
@export var work_required: int
@export var is_resting_spot: bool
@export var recipes: Array[RecipeData]