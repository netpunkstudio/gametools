@tool
extends EditorPlugin

const _SAVE_MANAGER_PATH := "res://addons/netpunk.gametools/subsystems/save/save_manager.gd"
const _OPTIONS_MANAGER_PATH := "res://addons/netpunk.gametools/subsystems/options/options_manager.gd"
const _LOADING_MANAGER_PATH := "res://addons/netpunk.gametools/subsystems/loading/loading_manager.gd"
const _CONFIG_DOCK_SCRIPT := "res://addons/netpunk.gametools/editor/plugin_config_dock.gd"

var _config_dock: Control


func _enter_tree() -> void:
	# Registration order matters: SaveManager first, others depend on it.
	add_autoload_singleton("SaveManager", _SAVE_MANAGER_PATH)
	add_autoload_singleton("OptionsManager", _OPTIONS_MANAGER_PATH)
	add_autoload_singleton("LoadingManager", _LOADING_MANAGER_PATH)

	_config_dock = load(_CONFIG_DOCK_SCRIPT).new()
	_config_dock.name = "GameTools"
	add_control_to_dock(DOCK_SLOT_LEFT_BR, _config_dock)


func _exit_tree() -> void:
	if _config_dock:
		remove_control_from_docks(_config_dock)
		_config_dock.free()
		_config_dock = null

	remove_autoload_singleton("LoadingManager")
	remove_autoload_singleton("OptionsManager")
	remove_autoload_singleton("SaveManager")
