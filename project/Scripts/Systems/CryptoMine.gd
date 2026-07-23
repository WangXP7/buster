class_name CryptoMine
extends RefCounted

const NETCOINS_PER_BIT: float = 0.00001

var mine_level: int = 0
var curr_bits: float = 0

var curr_speed: int = 0
var processing: bool = true #TODO: Set this to false in main menu or w/e

func _init() -> void:
	calculate_speed()

func process(delta: float) -> void:
	if not processing: return
	
	var bits_to_process: float = curr_speed * delta
	bits_to_process = min(bits_to_process, curr_bits)
	var netcoin_gain: float = NETCOINS_PER_BIT * bits_to_process
	curr_bits -= bits_to_process
	State.netcoin += netcoin_gain

func deposit(bits: int) -> void:
	curr_bits += bits

func get_netcoin_returns() -> float:
	return curr_bits * NETCOINS_PER_BIT

func level_up() -> void:
	mine_level += 1
	calculate_speed()

# Return the seconds to completion
func get_time_remaining() -> float:
	return curr_bits / curr_speed

func calculate_speed() -> void:
	match mine_level:
		0: curr_speed = 5
		1: curr_speed = 10
		2: curr_speed = 20
		3: curr_speed = 40
		4: curr_speed = 80
		5: curr_speed = 160
		6: curr_speed = 320
		7: curr_speed = 640
		8: curr_speed = 1280
		9: curr_speed = 1800
		10: curr_speed = 2600
		11: curr_speed = 3400
		12: curr_speed = 4200
		13: curr_speed = 5200
		14: curr_speed = 6400
		15: curr_speed = 7600
		16: curr_speed = 8800
		17: curr_speed = 10000
		18: curr_speed = 12000
		19: curr_speed = 14000
		20: curr_speed = 17000
		21: curr_speed = 21000
		22: curr_speed = 25000
		23: curr_speed = 32000
		24: curr_speed = 42000
		25: curr_speed = 52000
		26: curr_speed = 64000
		27: curr_speed = 80000
		28: curr_speed = 100000
		29: curr_speed = 124000
		30: curr_speed = 164000
		31: curr_speed = 228000
		32: curr_speed = 320000
		33: curr_speed = 480000
		34: curr_speed = 640000
		35: curr_speed = 820000
		36: curr_speed = 1280000
		_: curr_speed  = 1280000

func is_maxed() -> bool:
	return mine_level >= 36

func save() -> Dictionary:
	return {
		"mine_level": mine_level,
		"curr_bits": curr_bits,
	}

func load_save(save: Dictionary) -> CryptoMine:
	mine_level = save.mine_level
	curr_bits = save.curr_bits
	calculate_speed()
	return self
