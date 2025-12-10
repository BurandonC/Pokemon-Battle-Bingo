# pokemon_data.gd
# Store this as an Autoload singleton or just load it where needed
extends Node

# Pokemon species data
const POKEMON_SPECIES = {
	"fire": {
		"name": "Charmander",
		"base_stats": {
			"hp": 39,
			"attack": 52,
			"defense": 43,
			"sp_attack": 60,
			"sp_defense": 50,
			"speed": 65
		},
		"move": {
			"name": "Ember",
			"power": 40,
			"category": "Special",
			"type": "fire",
			"accuracy": 100
		}
	},
	"water": {
		"name": "Squirtle",
		"base_stats": {
			"hp": 44,
			"attack": 48,
			"defense": 65,
			"sp_attack": 50,
			"sp_defense": 64,
			"speed": 43
		},
		"move": {
			"name": "Water Gun",
			"power": 40,
			"category": "Special",
			"type": "water",
			"accuracy": 100
		}
	},
	"grass": {
		"name": "Bulbasaur",
		"base_stats": {
			"hp": 45,
			"attack": 49,
			"defense": 49,
			"sp_attack": 65,
			"sp_defense": 65,
			"speed": 45
		},
		"move": {
			"name": "Vine Whip",
			"power": 45,
			"category": "Physical",
			"type": "grass",
			"accuracy": 100
		}
	}
}

# Type effectiveness chart
const TYPE_CHART = {
	"fire": {"grass": 2.0, "water": 0.5, "fire": 0.5},
	"water": {"fire": 2.0, "grass": 0.5, "water": 0.5},
	"grass": {"water": 2.0, "fire": 0.5, "grass": 0.5}
}

# Get Pokemon data by type
static func get_pokemon_data(type: String) -> Dictionary:
	if type in POKEMON_SPECIES:
		return POKEMON_SPECIES[type]
	return {}

# Get type effectiveness
static func get_type_effectiveness(attack_type: String, defend_type: String) -> float:
	if attack_type in TYPE_CHART and defend_type in TYPE_CHART[attack_type]:
		return TYPE_CHART[attack_type][defend_type]
	return 1.0

# Calculate stat from base stat and level
static func calculate_stat(base: int, level: int) -> int:
	return int((2.0 * base + 31 + 5) * level / 100.0) + 5

# Calculate HP from base HP and level
static func calculate_hp(base: int, level: int) -> int:
	return int((2.0 * base + 31 + 5) * level / 100.0) + level + 10
