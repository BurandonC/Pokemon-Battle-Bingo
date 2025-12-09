extends Node2D

# Emitted when this card is clicked
signal card_clicked(card)

# Card state
var is_flipped: bool = false
var grid_position: Vector2i = Vector2i(0, 0)
var pokemon_id: int = 0  # For future database integration
var pokemon_type: String = "normal"  # e.g., "fire", "water", etc.

# Node references
@onready var animation_player = $flip
@onready var card_front = $CardFront
@onready var front_sprite = $CardFront/Sprite
@onready var card_back = $CardBack

const TYPE_TEXTURES = {
	"normal": preload("res://assets/BG/Cards/NormalCard.png"),
	"fire": preload("res://assets/BG/Cards/FireCard.png"),
	"water": preload("res://assets/BG/Cards/WaterCard.png"),
	"electric": preload("res://assets/BG/Cards/ElectricCard.png"),
	"grass": preload("res://assets/BG/Cards/GrassCard.png"),
	"ice": preload("res://assets/BG/Cards/IceCard.png"),
	"fighting": preload("res://assets/BG/Cards/FightingCard.png"),
	"poison": preload("res://assets/BG/Cards/PoisonCard.png"),
	"ground": preload("res://assets/BG/Cards/GroundCard.png"),
	"flying": preload("res://assets/BG/Cards/FlyingCard.png"),
	"psychic": preload("res://assets/BG/Cards/PsychicCard.png"),
	"bug": preload("res://assets/BG/Cards/BugCard.png"),
	"rock": preload("res://assets/BG/Cards/RockCard.png"),
	"ghost": preload("res://assets/BG/Cards/GhostCard.png"),
	"dragon": preload("res://assets/BG/Cards/DragonCard.png"),
	"dark": preload("res://assets/BG/Cards/DarkCard.png"),
	"steel": preload("res://assets/BG/Cards/SteelCard.png"),
	"fairy": preload("res://assets/BG/Cards/FairyCard.png")
}

func _ready():
	is_flipped = false

# Sets the Pokemon type and swaps the card backing texture
func set_pokemon_type(type: String):
	pokemon_type = type.to_lower()
	
	if TYPE_TEXTURES.has(pokemon_type):
		card_back.texture = TYPE_TEXTURES[pokemon_type]
	else:
		print("Warning: Unknown type '", type, "'")

# Plays the flip animation if not already flipped
func flip():
	if is_flipped:
		print("Card is already been flipped!")
		return
	
	print("Card is now Flipping")
	is_flipped = true
	animation_player.play("token_flip")

# Sets this card's position in the grid (row, col)
func set_grid_position(row: int, col: int):
	grid_position = Vector2i(col, row)

# Handles mouse clicks on this card
func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			print("Card clicked at position: ", grid_position)
			card_clicked.emit(self)
