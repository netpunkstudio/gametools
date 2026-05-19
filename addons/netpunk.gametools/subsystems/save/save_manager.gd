extends Node

## Maximum number of save slots available to the player.
var max_slots: int = 3

## When true, all save files are encrypted using encryption_key.
## Set both before calling any save/load methods.
var use_encryption: bool = false

## Passphrase used for encryption. Keep this secret in production builds.
var encryption_key: String = ""

## Path to the version.json produced by CI. Must contain a "version" field
## with a semver string (prefix like "pre-alpha: v0.2.4" is fine).
## A difference in major version between a save and the current build
## causes that save to be flagged as possibly_incompatible.
var version_file_path: String = "res://version.json"

const _BASE_DIR := "user://gametools/"
const _SETTINGS_FILE := "user://gametools/settings.json"
const _SLOTS_DIR := "user://gametools/slots/"

var _version_config: Dictionary = {}
var _version_config_loaded: bool = false


func _ready() -> void:
	_ensure_dirs()
	# Seed all configurable values from the plugin config dock (ProjectSettings).
	# Game code running after _ready() can still override any of these.
	max_slots = ProjectSettings.get_setting("gametools/save/max_slots", max_slots)
	use_encryption = ProjectSettings.get_setting("gametools/save/use_encryption", use_encryption)
	encryption_key = ProjectSettings.get_setting("gametools/save/encryption_key", encryption_key)
	version_file_path = ProjectSettings.get_setting("gametools/save/version_file_path", version_file_path)


# --- Settings ---

## Persist game settings to disk. Merges on top of any existing settings file.
func save_settings(data: Dictionary) -> bool:
	return _write_json(_SETTINGS_FILE, data)


## Returns the saved settings dictionary, or an empty dict if none exist.
func load_settings() -> Dictionary:
	return _read_json(_SETTINGS_FILE)


# --- Save Slots ---

## Save game data into a slot.
## meta may contain developer-defined fields such as playtime_seconds,
## character_level, map_completion, etc.
## The keys "slot" and "last_played" are added automatically.
func save_slot(slot_index: int, game_data: Dictionary, meta: Dictionary = {}) -> bool:
	if not _valid_slot(slot_index):
		push_error("SaveManager: slot_index %d out of range (max_slots = %d)" % [slot_index, max_slots])
		return false

	var slot_dir := _slot_dir(slot_index)
	DirAccess.make_dir_recursive_absolute(slot_dir)

	var full_meta := meta.duplicate()
	full_meta["slot"] = slot_index
	full_meta["last_played"] = Time.get_datetime_string_from_system()
	_stamp_version(full_meta)

	return _write_json(slot_dir + "meta.json", full_meta) \
		and _write_json(slot_dir + "data.json", game_data)


## Returns {meta: Dictionary, data: Dictionary} for the given slot,
## or an empty dictionary if the slot does not exist.
## meta will contain "possibly_incompatible: true" if the save was created
## with a version older than min_compatible_version in version.json.
func load_slot(slot_index: int) -> Dictionary:
	if not slot_exists(slot_index):
		return {}
	var slot_dir := _slot_dir(slot_index)
	return {
		"meta": _check_compatibility(_read_json(slot_dir + "meta.json")),
		"data": _read_json(slot_dir + "data.json"),
	}


## Returns only the meta dictionary for a slot (cheaper than a full load).
## Includes "possibly_incompatible: true" when applicable.
func get_slot_meta(slot_index: int) -> Dictionary:
	if not slot_exists(slot_index):
		return {}
	return _check_compatibility(_read_json(_slot_dir(slot_index) + "meta.json"))


## Returns an Array of Dictionaries, one entry per slot (0..max_slots-1).
## Each entry: {slot: int, exists: bool, meta: Dictionary}
## meta includes "possibly_incompatible: true" when applicable.
func list_slots() -> Array:
	var result: Array = []
	for i in range(max_slots):
		var exists := slot_exists(i)
		result.append({
			"slot": i,
			"exists": exists,
			"meta": _check_compatibility(_read_json(_slot_dir(i) + "meta.json")) if exists else {},
		})
	return result


## Permanently deletes a save slot. Returns false if the slot did not exist.
func delete_slot(slot_index: int) -> bool:
	if not slot_exists(slot_index):
		return false
	var slot_dir := _slot_dir(slot_index)
	var dir := DirAccess.open(slot_dir)
	if dir:
		dir.remove("meta.json")
		dir.remove("data.json")
	DirAccess.remove_absolute(slot_dir)
	return true


## Returns the index of the most recently used slot by comparing last_played
## timestamps, or -1 if no slots exist.
func get_last_used_slot() -> int:
	var latest_time := ""
	var latest_slot := -1
	for i in range(max_slots):
		if slot_exists(i):
			var t: String = get_slot_meta(i).get("last_played", "")
			if t > latest_time:
				latest_time = t
				latest_slot = i
	return latest_slot


## Returns the meta dictionary of the most recently used slot, or {} if none.
func get_last_slot_meta() -> Dictionary:
	var slot := get_last_used_slot()
	if slot < 0:
		return {}
	return get_slot_meta(slot)


## Returns true if save data exists for the given slot index.
func slot_exists(slot_index: int) -> bool:
	if not _valid_slot(slot_index):
		return false
	return DirAccess.dir_exists_absolute(_slot_dir(slot_index))


# --- Internal ---

func _ensure_dirs() -> void:
	DirAccess.make_dir_recursive_absolute(_SLOTS_DIR)


func _valid_slot(slot_index: int) -> bool:
	return slot_index >= 0 and slot_index < max_slots


func _slot_dir(slot_index: int) -> String:
	return _SLOTS_DIR + "slot_%d/" % slot_index


func _write_json(path: String, data: Dictionary) -> bool:
	var json_string := JSON.stringify(data, "\t")
	var file: FileAccess
	if use_encryption and not encryption_key.is_empty():
		file = FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, encryption_key)
	else:
		file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: could not open '%s' for writing (error %d)" % [path, FileAccess.get_open_error()])
		return false
	file.store_string(json_string)
	file.close()
	return true


func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file: FileAccess
	if use_encryption and not encryption_key.is_empty():
		file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, encryption_key)
	else:
		file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("SaveManager: could not open '%s' for reading (error %d)" % [path, FileAccess.get_open_error()])
		return {}
	var content := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(content)
	if not parsed is Dictionary:
		push_error("SaveManager: invalid JSON in '%s'" % path)
		return {}
	return parsed


# --- Version / compatibility ---

func _get_version_config() -> Dictionary:
	if not _version_config_loaded:
		_version_config_loaded = true
		if FileAccess.file_exists(version_file_path):
			var content := FileAccess.get_file_as_string(version_file_path)
			var parsed = JSON.parse_string(content)
			if parsed is Dictionary:
				_version_config = parsed
			else:
				push_warning("SaveManager: invalid JSON in version file '%s'" % version_file_path)
		else:
			push_warning("SaveManager: version file not found at '%s'" % version_file_path)
	return _version_config


func _stamp_version(meta: Dictionary) -> void:
	var version: String = _get_version_config().get("version", "")
	if not version.is_empty():
		meta["game_version"] = version


func _check_compatibility(meta: Dictionary) -> Dictionary:
	var config := _get_version_config()
	var current_version: String = config.get("version", "")
	var saved_version: String = meta.get("game_version", "")
	if current_version.is_empty() or saved_version.is_empty():
		return meta
	var current_semver := _extract_semver(current_version)
	var saved_semver := _extract_semver(saved_version)
	if current_semver.is_empty() or saved_semver.is_empty():
		return meta
	var current_major := int(current_semver.split(".")[0])
	var saved_major := int(saved_semver.split(".")[0])
	if current_major != saved_major:
		meta["possibly_incompatible"] = true
	return meta


func _extract_semver(version_string: String) -> String:
	var regex := RegEx.new()
	regex.compile("(\\d+\\.\\d+\\.\\d+)")
	var result := regex.search(version_string)
	if result:
		return result.get_string()
	return ""
