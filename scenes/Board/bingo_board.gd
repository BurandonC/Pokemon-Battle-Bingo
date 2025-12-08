extends Node2D

# Preload chip scene
const CHIP_SCENE = preload("res://scenes/Chip/Chip.tscn")

# Board settings
const GRID_SIZE = 4
const CHIP_SPACING = 120

# Board state
var chips: Array = []  # 2D array of chip nodes [row][col]
var flipped_chips: Array = []  # Tracks which chips are flipped [row][col]
var first_flip: bool = true  # First chip can be anywhere

func _ready():
	# Center board in viewport
	var viewport_size = get_viewport_rect().size
	position = viewport_size / 2
	
	create_board()

# Creates the 4x4 grid of chips
func create_board():
	# Calculate centering offset
	var board_width = (GRID_SIZE - 1) * CHIP_SPACING
	var board_height = (GRID_SIZE - 1) * CHIP_SPACING
	var offset = Vector2(-board_width / 2, -board_height / 2)
	
	# Initialize arrays
	chips.resize(GRID_SIZE)
	flipped_chips.resize(GRID_SIZE)
	
	# Create each chip
	for row in range(GRID_SIZE):
		chips[row] = []
		flipped_chips[row] = []
		
		for col in range(GRID_SIZE):
			var chip = CHIP_SCENE.instantiate()
			chip.scale = Vector2(0.25, 0.25)  # Scale down from 393x393
			chip.position = Vector2(col * CHIP_SPACING, row * CHIP_SPACING) + offset
			chip.set_grid_position(row, col)
			chip.chip_clicked.connect(_on_chip_clicked)
			
			add_child(chip)
			chips[row].append(chip)
			flipped_chips[row].append(false)

# Checks if a chip can be flipped based on adjacency rules
# First chip: anywhere. Other chips: must be adjacent to a flipped chip
func can_flip_chip(row: int, col: int) -> bool:
	if flipped_chips[row][col]:
		return false  # Already flipped
	
	if first_flip:
		return true  # First chip can be anywhere
	
	# Check adjacent positions (up, down, left, right)
	var adjacent = [
		Vector2i(row - 1, col),  # Up
		Vector2i(row + 1, col),  # Down
		Vector2i(row, col - 1),  # Left
		Vector2i(row, col + 1)   # Right
	]
	
	for pos in adjacent:
		if pos.x >= 0 and pos.x < GRID_SIZE and pos.y >= 0 and pos.y < GRID_SIZE:
			if flipped_chips[pos.x][pos.y]:
				return true
	
	return false

# Handles chip click events
func _on_chip_clicked(chip: Node2D):
	var row = chip.grid_position.y
	var col = chip.grid_position.x
	
	print("Board received click at [", row, ", ", col, "]")
	
	if can_flip_chip(row, col):
		chip.flip()
		flipped_chips[row][col] = true
		first_flip = false
		print("Chip flipped successfully!")
	else:
		print("Cannot flip - not adjacent to a flipped chip!")
