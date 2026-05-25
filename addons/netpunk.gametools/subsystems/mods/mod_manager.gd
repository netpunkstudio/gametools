extends Node

## Discovers and loads PCK-based mods from a configurable directory.
##
## Each mod is a .pck file paired with a sidecar .json manifest:
##
##   user://mods/
##     cool_mod.pck
##     cool_mod.json   <- manifest is read before the PCK is mounted
##
## Manifest keys (all optional except "id"):
##   id, name, version, author, description, dependencies, load_order
##
## For Steam Workshop, call scan_path() with the workshop item install path
## after obtaining it from GodotSteam. Mods found there are loaded immediately.
##
## WARNING: PCKs cannot be unloaded once mounted. Disabling a mod via
## disable_mod() takes effect only after the next game restart.

const _PS_MODS_PATH := "gametools/mods/mods_path"
const _SETTINGS_KEY := "mods"

signal mod_loaded(mod_id: String)
signal mod_load_failed(mod_id: String, error: String)
signal all_mods_loaded()

## All discovered mods keyed by mod id. Includes disabled and unloaded mods.
var mods: Dictionary = {}


func _ready() -> void:
	var dir_path: String = ProjectSettings.get_setting(_PS_MODS_PATH, "user://mods/")
	_scan_and_load(dir_path)
	all_mods_loaded.emit()


## Scan an additional directory and load any eligible mods found there.
## Useful for adding Steam Workshop content directories at runtime.
func scan_path(dir_path: String) -> void:
	_scan_and_load(dir_path)
	all_mods_loaded.emit()


## Enable a previously disabled mod. Change takes effect on the next restart.
func enable_mod(mod_id: String) -> void:
	if not mods.has(mod_id):
		return
	mods[mod_id].enabled = true
	_persist_enabled_states()


## Disable a mod. Change takes effect on the next restart.
func disable_mod(mod_id: String) -> void:
	if not mods.has(mod_id):
		return
	mods[mod_id].enabled = false
	_persist_enabled_states()


## Returns all mods that were successfully mounted this session.
func get_loaded_mods() -> Array:
	var result: Array = []
	for mod: ModInfo in mods.values():
		if mod.is_loaded:
			result.append(mod)
	return result


# ---- Internal ----

func _scan_and_load(dir_path: String) -> void:
	var dir := DirAccess.open(dir_path)
	if not dir:
		return

	var saved_states: Dictionary = _load_saved_states()

	var discovered: Array[ModInfo] = []
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".pck"):
			var pck_path := dir_path.path_join(file_name)
			var json_path := pck_path.get_basename() + ".json"
			var info := _parse_manifest(json_path, pck_path)
			if info and not mods.has(info.id):
				info.enabled = saved_states.get(info.id, true)
				discovered.append(info)
		file_name = dir.get_next()
	dir.list_dir_end()

	discovered.sort_custom(func(a: ModInfo, b: ModInfo) -> bool:
		return a.load_order < b.load_order)

	for info: ModInfo in discovered:
		mods[info.id] = info
		if info.enabled:
			_load_mod(info)


func _parse_manifest(json_path: String, pck_path: String) -> ModInfo:
	var info := ModInfo.new()
	info.source_path = pck_path
	info.id = pck_path.get_file().get_basename()
	info.name = info.id

	if FileAccess.file_exists(json_path):
		var file := FileAccess.open(json_path, FileAccess.READ)
		if file:
			var parsed: Variant = JSON.parse_string(file.get_as_text())
			if parsed is Dictionary:
				info.id = parsed.get("id", info.id)
				info.name = parsed.get("name", info.name)
				info.version = parsed.get("version", "1.0.0")
				info.author = parsed.get("author", "")
				info.description = parsed.get("description", "")
				info.load_order = int(parsed.get("load_order", 0))
				var deps: Variant = parsed.get("dependencies", [])
				if deps is Array:
					info.dependencies = deps

	return info


func _load_mod(info: ModInfo) -> void:
	if ProjectSettings.load_resource_pack(info.source_path):
		info.is_loaded = true
		mod_loaded.emit(info.id)
	else:
		mod_load_failed.emit(info.id, "Failed to mount: " + info.source_path)


func _load_saved_states() -> Dictionary:
	if not is_instance_valid(SaveManager):
		return {}
	var settings: Dictionary = SaveManager.load_settings()
	var raw: Variant = settings.get(_SETTINGS_KEY, {})
	return raw if raw is Dictionary else {}


func _persist_enabled_states() -> void:
	if not is_instance_valid(SaveManager):
		return
	var settings: Dictionary = SaveManager.load_settings()
	var states := {}
	for id: String in mods:
		states[id] = mods[id].enabled
	settings[_SETTINGS_KEY] = states
	SaveManager.save_settings(settings)
