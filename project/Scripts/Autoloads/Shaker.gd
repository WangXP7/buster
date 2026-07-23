extends Node2D

class ShakeInstance extends RefCounted:
	var target
	var magnitude: float
	var duration: float
	var frequency: float
	
	var elapsed: float
	
	var alive: bool
	
	var samples = []
	
	func _init(_target, _magnitude: float, _duration: float, _frequency: float) -> void:
		target = _target
		magnitude = _magnitude
		duration = _duration
		frequency = _frequency
		
		elapsed = 0
		alive = true
		
		samples.resize(duration * frequency)
		for i in range(samples.size()):
			samples[i] = 2 * randf() - 1
	
	func update(delta: float) -> void:
		elapsed += delta
		if elapsed >= duration:
			alive = false
	
	func get_noise(index: int) -> float:
		if index >= samples.size(): return 0.0
		else: return samples[index]
	
	func get_decay(time: float) -> float:
		if time >= duration: return 0.0
		else: return (duration - time) / duration
	
	func get_amplitude() -> float:
		if not alive: return 0.0
		
		var s: float = elapsed * frequency
		var s0: int = int(floor(s))
		var s1: int = s0 + 1
		var k: float = get_decay(elapsed)
		
		return magnitude * (get_noise(s0) + (s-s0) * (get_noise(s1) - get_noise(s0))) * k

# var shakes: Dictionary = {"x": [], "y": []}	# Type: Dictionary<string, Array<ShakeInstance>>

var shakes: Dictionary = {}	# Type: Dictionary<Node2D, Array<Array<ShakeInstance>>>
# Note: Array value has 2 values: 0 is x-axis, 1 is y-axis

# Type: Dictionary<Object, Dictionary<String, Array<ShakeInstance>>>
# Key is the target object. Inner dictionary key is the property string.
var property_shakes: Dictionary = {}


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta):
	var keys = shakes.keys()
	
	# Shaking positions
	for target in keys:
		var curr_shake: Array = [0, 0]
		var base_pos: Vector2 = shakes[target][2]
		for axis_index in range(2):
			var axis_shake_list: Array = shakes[target][axis_index]
			for i in range(axis_shake_list.size() - 1, -1, -1):
				axis_shake_list[i].update(delta)
				curr_shake[axis_index] += axis_shake_list[i].get_amplitude()
				if not axis_shake_list[i].alive:
					axis_shake_list.remove_at(i)
		if (shakes[target][0].size() == 0 and shakes[target][1].size() == 0):
			shakes.erase(target)
		if is_instance_valid(target):
			target.position = base_pos + Vector2(curr_shake[0], curr_shake[1])
	
	# Shaking properties
	var prop_keys = property_shakes.keys()
	for target in prop_keys:
		var curr_shake = 0.0
		var properties_dict: Dictionary = property_shakes[target]
		var prop_dict_keys: Array = properties_dict.keys()
		for property in prop_dict_keys:
			var shake_list: Array = properties_dict[property]
			for i in range(shake_list.size() - 1, -1, -1):
				shake_list[i].update(delta)
				curr_shake += shake_list[i].get_amplitude()
				if not shake_list[i].alive:
					shake_list.remove_at(i)
			if shake_list.size() == 0:
				properties_dict.erase(property)
			if is_instance_valid(target):
				target.set_indexed(property, curr_shake)
		if properties_dict.size() == 0:
			prop_keys.erase(target)


func shake(target: Node2D, magnitude: float, duration: float, 
target_pos: Vector2 = Vector2.ZERO, frequency: float = 60) -> void:
	if not shakes.has(target):
		shakes[target] = [[], [], target_pos]
	else:
		shakes[target][2] = target_pos
	
	shakes[target][0].append(ShakeInstance.new(target, magnitude, duration, frequency))
	shakes[target][1].append(ShakeInstance.new(target, magnitude, duration, frequency))

func shake_property(target: Object, property: NodePath, magnitude: float, duration: float,
frequency: float = 60) -> void:
	if not property_shakes.has(target):
		property_shakes[target] = {property: \
			[ShakeInstance.new(target, magnitude, duration, frequency)]}
	else:
		if not property_shakes[target].has(property):
			property_shakes[target][property] = \
				[ShakeInstance.new(target, magnitude, duration, frequency)]
		else:
			property_shakes[target][property].append(\
				ShakeInstance.new(target, magnitude, duration, frequency))
