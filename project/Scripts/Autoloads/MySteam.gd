extends Node

func _ready() -> void:
	var response: Dictionary = Steam.steamInitEx(true, 3107330)
	print("Did Steam initialize?: %s" % response)
	var is_owned: bool = Steam.isSubscribed()
	var family_shared: bool = Steam.isSubscribedFromFamilySharing()
	if not is_owned and not family_shared:
		print("User does not own this game")
		get_tree().quit()

func _process(delta: float) -> void:
	Steam.run_callbacks()

func set_achievement(achievement_id: String, store_stats: bool = true) -> void:
	Steam.setAchievement(achievement_id)
	if store_stats: Steam.storeStats()

