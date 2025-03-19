extends Camera2D

var zoom_speed: float = 0.05
var drag_sensitivity: float = 1.0
var camera_move_speed: float = 40

# # Decent values for real gameplay
# # Bigger numbers, closer to ground
# ## Smaller numbers, further out from ground
# var zoom_min: float = 0.3
# var zoom_max: float = 1.5

# # Dev values
var zoom_min: float = 0.01
var zoom_max: float = 2

var is_panning: bool

# Consider moving to process
# May get laggy
func _physics_process(delta):
	var input_vector = Input.get_vector("move_camera_left", "move_camera_right", "move_camera_up", "move_camera_down")
	if input_vector != Vector2(0,0):
		is_panning = true
		var new_camera_vector = (input_vector * camera_move_speed) / zoom
		print("input_vector: ", input_vector)
		print("new_camera_vector: ", new_camera_vector)
		position += (new_camera_vector * camera_move_speed) * delta
	else:
		is_panning = false

func _input(event):

	# TODO: Make the camera zoom in and out smoothly

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if zoom < Vector2(zoom_max, zoom_max):
				zoom += Vector2(zoom_speed, zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if zoom > Vector2(zoom_min, zoom_min):
				zoom -= Vector2(zoom_speed, zoom_speed)
	if not is_panning:
		if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
			position -= (event.relative * drag_sensitivity) / zoom
			return
