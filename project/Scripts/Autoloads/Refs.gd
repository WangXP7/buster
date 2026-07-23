extends Node

# The NON-VIEWPORT world
var default_world: World2D

var camera: MyCamera
var viewport: SubViewport
var physics_state: RID
var main_scn: MainScene
var root: Node2D
var curr_scn: Node2D
var popups: PopupManager
var tooltip: Tooltip
var scene_transition: SceneTransition

var world_env: WorldEnvironment
var crt: ColorRect
var glitch: ColorRect

# Shop scene
var upgrade_description: UpgradeDescription
var upgrade_processor: UpgradeProcessor
var upgrade_tree: UpgradeTree

# Battle scene
var health: PlayerHealthBar
var xp: XPBar
var enemy_spawner: EnemySpawner
var drop_creator: EnemyDropsCreator


# Layer masks
@onready var enemy_mask: int = Layers.bitmask(["Enemies"])
@onready var enemy_drops_mask: int = Layers.bitmask(["EnemyDrops"])
@onready var player_cursor_mask: int = Layers.bitmask(["PlayerRadius"])


const _options = preload("res://Scenes/Popups/Options/OptionsPopup.tscn")
const _confirmation = preload("res://Scenes/Popups/ConfirmationPopup.tscn")
