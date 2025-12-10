# battle_scene.gd
extends Node2D

# Load Pokemon data
const PokemonData = preload("res://pokemon_data.gd")

# UI References
@onready var player_name_label = $PlayerPanel/NameLabel
@onready var player_hp_label = $PlayerPanel/HPLabel
@onready var player_hp_bar = $PlayerPanel/HPBar
@onready var opponent_name_label = $OpponentPanel/NameLabel
@onready var opponent_hp_label = $OpponentPanel/HPLabel
@onready var opponent_hp_bar = $OpponentPanel/HPBar
@onready var battle_log = $BattleLog
@onready var attack_button = $AttackButton

# Pokemon instance class
class Pokemon:
	var name: String
	var level: int
	var type: String
	var attack: int
	var defense: int
	var sp_attack: int
	var sp_defense: int
	var speed: int
	var hp: int
	var max_hp: int
	var move: Dictionary
	
	func _init(pokemon_type: String, lvl: int = 50):
		type = pokemon_type
		level = lvl
		
		# Get data from PokemonData
		var data = PokemonData.get_pokemon_data(pokemon_type)
		
		if data.is_empty():
			push_error("Pokemon type '%s' not found!" % pokemon_type)
			return
		
		# Set name and stats
		name = data.name
		var base = data.base_stats
		
		attack = PokemonData.calculate_stat(base.attack, lvl)
		defense = PokemonData.calculate_stat(base.defense, lvl)
		sp_attack = PokemonData.calculate_stat(base.sp_attack, lvl)
		sp_defense = PokemonData.calculate_stat(base.sp_defense, lvl)
		speed = PokemonData.calculate_stat(base.speed, lvl)
		max_hp = PokemonData.calculate_hp(base.hp, lvl)
		hp = max_hp
		
		# Store move
		move = data.move

var player_pokemon: Pokemon
var opponent_pokemon: Pokemon
var battle_active: bool = true

func _ready():
	pass  # Wait for init_battle

# Initialize battle
func init_battle(player_type: String, available_types: Array):
	player_pokemon = Pokemon.new(player_type, 50)
	
	# Pick random opponent
	var opponent_type = available_types[randi() % available_types.size()]
	opponent_pokemon = Pokemon.new(opponent_type, 50)
	
	# Setup UI
	attack_button.text = player_pokemon.move.name
	attack_button.pressed.connect(_on_attack_pressed)
	
	update_battle_ui()
	add_battle_log("A wild %s appeared!" % opponent_pokemon.name)
	add_battle_log("Go, %s!" % player_pokemon.name)

# Modern Pokemon Damage Formula (Gen 5+)
func calculate_damage(attacker: Pokemon, defender: Pokemon, move: Dictionary) -> Dictionary:
	var result = {"damage": 0, "critical": false, "effectiveness": 1.0, "miss": false}
	
	# Check accuracy
	if randf() * 100 > move.accuracy:
		result.miss = true
		return result
	
	# Get stats based on move category
	var attack_stat = attacker.sp_attack if move.category == "Special" else attacker.attack
	var defense_stat = defender.sp_defense if move.category == "Special" else defender.defense
	
	# Base damage
	var base = ((2.0 * attacker.level / 5.0) + 2.0) * move.power * (attack_stat / float(defense_stat))
	base = (base / 50.0) + 2.0
	
	# STAB
	var stab = 1.5 if move.type == attacker.type else 1.0
	
	# Type effectiveness
	var effectiveness = PokemonData.get_type_effectiveness(move.type, defender.type)
	result.effectiveness = effectiveness
	
	# Random (85-100%)
	var random_factor = randf_range(0.85, 1.0)
	
	# Critical (6.25% chance)
	var critical = 1.5 if randf() < 0.0625 else 1.0
	result.critical = critical > 1.0
	
	# Final damage
	var damage = base * stab * effectiveness * random_factor * critical
	result.damage = max(1, int(damage))
	
	return result

func use_move(attacker: Pokemon, defender: Pokemon):
	var move = attacker.move
	var result = calculate_damage(attacker, defender, move)
	
	if result.miss:
		add_battle_log("%s's %s missed!" % [attacker.name, move.name])
		return
	
	defender.hp = max(0, defender.hp - result.damage)
	
	add_battle_log("%s used %s!" % [attacker.name, move.name])
	
	if result.critical:
		add_battle_log("Critical hit!")
	
	if result.effectiveness > 1.0:
		add_battle_log("It's super effective!")
	elif result.effectiveness < 1.0 and result.effectiveness > 0:
		add_battle_log("It's not very effective...")
	
	add_battle_log("%s took %d damage!" % [defender.name, result.damage])
	
	update_battle_ui()
	
	if defender.hp <= 0:
		end_battle(attacker == player_pokemon)

func _on_attack_pressed():
	if not battle_active:
		return
	
	attack_button.disabled = true
	
	# Player attacks
	use_move(player_pokemon, opponent_pokemon)
	
	# Opponent attacks back (if still alive)
	if opponent_pokemon.hp > 0:
		await get_tree().create_timer(1.5).timeout
		use_move(opponent_pokemon, player_pokemon)
	
	attack_button.disabled = false

func update_battle_ui():
	# Player
	player_name_label.text = "%s Lv.%d" % [player_pokemon.name, player_pokemon.level]
	player_hp_label.text = "%d/%d HP" % [player_pokemon.hp, player_pokemon.max_hp]
	player_hp_bar.value = (float(player_pokemon.hp) / player_pokemon.max_hp) * 100
	
	# Opponent
	opponent_name_label.text = "%s Lv.%d" % [opponent_pokemon.name, opponent_pokemon.level]
	opponent_hp_label.text = "%d/%d HP" % [opponent_pokemon.hp, opponent_pokemon.max_hp]
	opponent_hp_bar.value = (float(opponent_pokemon.hp) / opponent_pokemon.max_hp) * 100

func add_battle_log(message: String):
	battle_log.text += message + "\n"

func end_battle(player_won: bool):
	battle_active = false
	attack_button.disabled = true
	
	if player_won:
		add_battle_log("\n%s fainted!" % opponent_pokemon.name)
		add_battle_log("You won the battle!")
	else:
		add_battle_log("\n%s fainted!" % player_pokemon.name)
		add_battle_log("You lost the battle!")
	
	# Return to board
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://scenes/bingo_board.tscn")
