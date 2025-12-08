extends Node2D

# Emitted when this chip is clicked
signal chip_clicked(chip)

# Chip state
var is_flipped: bool = false
var grid_position: Vector2i = Vector2i(0, 0)
var pokemon_id: int = 0  # For future database integration

# Node references
@onready var animation_player = $flip
@onready var chip_sprite = $ChipFront
@onready var front_sprite = $ChipFront/Sprite
@onready var chip_back = $ChipBack

func _ready():
	is_flipped = false

# Plays the flip animation if not already flipped
func flip():
	if is_flipped:
		print("Chip is already been flipped!")
		return
	
	print("Chipping is now Flipping")
	is_flipped = true
	animation_player.play("token_flip")

# Sets this chip's position in the grid (row, col)
func set_grid_position(row: int, col: int):
	grid_position = Vector2i(col, row)

# Handles mouse clicks on this chip
func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			print("Chip clicked at position: ", grid_position)
			chip_clicked.emit(self)
