extends Node2D

# Preload card scene
const CARD_SCENE = preload("res://scenes/Card/card.tscn")

# Board settings
const GRID_SIZE = 4
const CARD_SPACING = 120

# Board state
var cards: Array = []  # 2D array of card nodes [row][col]
var flipped_cards: Array = []  # Tracks which cards are flipped [row][col]
var first_flip: bool = true

func _ready():
	randomize()
	# Center board in viewport
	var viewport_size = get_viewport_rect().size
	position = viewport_size / 2
	
	create_board()

# Creates the 4x4 grid of cards
func create_board():
	# Calculate centering offset
	var board_width = (GRID_SIZE - 1) * CARD_SPACING
	var board_height = (GRID_SIZE - 1) * CARD_SPACING
	var offset = Vector2(-board_width / 2, -board_height / 2)
	
	# Initialize arrays
	cards.resize(GRID_SIZE)
	flipped_cards.resize(GRID_SIZE)
	
	# Create each card
	for row in range(GRID_SIZE):
		cards[row] = []
		flipped_cards[row] = []
		
		for col in range(GRID_SIZE):
			var card = CARD_SCENE.instantiate()
			card.scale = Vector2(0.7, 0.7)
			card.position = Vector2(col * CARD_SPACING, row * CARD_SPACING) + offset
			card.set_grid_position(row, col)
			
			# ADD THE CARD TO THE SCENE FIRST - This triggers _ready() and initializes @onready vars
			add_child(card)
			
			# NOW set the type - card_back will be initialized
			var types = ["normal", "fire", "water", "grass", "electric", "ice", "fighting", "poison", "ground", "flying", "psychic", "bug", "rock", "ghost", "dragon", "dark", "steel", "fairy"]
			var random_index = randi() % types.size()
			var random_type = types[random_index]
			
			card.set_pokemon_type(random_type)
			
			# Connect signal
			card.card_clicked.connect(_on_card_clicked)
			
			# Track in arrays
			cards[row].append(card)
			flipped_cards[row].append(false)

# Checks if a card can be flipped based on adjacency rules
func can_flip_card(row: int, col: int) -> bool:  # Changed function name
	if flipped_cards[row][col]:
		return false  # Already flipped
	
	if first_flip:
		return true  # First card can be anywhere
	
	# Check adjacent positions (up, down, left, right)
	var adjacent = [
		Vector2i(row - 1, col),  # Up
		Vector2i(row + 1, col),  # Down
		Vector2i(row, col - 1),  # Left
		Vector2i(row, col + 1)   # Right
	]
	
	for pos in adjacent:
		if pos.x >= 0 and pos.x < GRID_SIZE and pos.y >= 0 and pos.y < GRID_SIZE:
			if flipped_cards[pos.x][pos.y]:
				return true
	
	return false

# Handles card click events
func _on_card_clicked(card: Node2D):  # Changed function and parameter name
	var row = card.grid_position.y
	var col = card.grid_position.x
	
	print("Board received click at [", row, ", ", col, "]")
	
	if can_flip_card(row, col):  # Changed function name
		card.flip()
		flipped_cards[row][col] = true
		first_flip = false
		print("Card flipped successfully!")
	else:
		print("Cannot flip - not adjacent to a flipped card!")
