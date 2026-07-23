extends Node

# BUG-13 fix (batch 1): allow running outside Steam for local testing/modding.
# Set to false to run the game in the Godot editor or from a standalone build
# without a valid Steam subscription (Steam achievements/callbacks are skipped).
const ENFORCE_STEAM_OWNERSHIP: bool = true

const APP_ID: int = 3107330

var steam_available: bool = false

func _ready() -> void:
	if not Engine.has_singleton("Steam"):
		print("Steam singleton not found - running in offline/non-Steam mode")
		return

	var response: Dictionary = Steam.steamInitEx(ENFORCE_STEAM_OWNERSHIP, APP_ID)
	print("Did Steam initialize?: %s" % response)
	steam_available = response.get("status_code", -1) == 1 or response.get("success", false)

	if steam_available and ENFORCE_STEAM_OWNERSHIP:
		var is_owned: bool = Steam.isSubscribed()
		var family_shared: bool = Steam.isSubscribedFromFamilySharing()
		if not is_owned and not family_shared:
			print("User does not own this game")
			get_tree().quit()

func _process(delta: float) -> void:
	if steam_available:
		Steam.run_callbacks()

func set_achievement(achievement_id: String, store_stats: bool = true) -> void:
	if not steam_available:
		return
	Steam.setAchievement(achievement_id)
	if store_stats: Steam.storeStats()
