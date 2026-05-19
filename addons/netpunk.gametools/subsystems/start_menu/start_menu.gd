extends Control

## Metadata key to read from the last used save slot (e.g. "chapter").
@export var background_meta_key: String = "chapter"

## Maps metadata values to background textures.
## Keys are Strings; values are Texture2D resources.
@export var backgrounds: Dictionary = {}

## Shown when no save exists or no key matches.
@export var default_background: Texture2D

## Emitted when the player presses New Game.
signal new_game_requested

## Emitted when the player presses Continue, carrying the last-used slot index.
signal continue_requested(slot_index: int)

## Emitted when the player presses Load Game (show your slot-picker UI here).
signal load_game_requested

## Emitted when the player presses Quit.
## Connect to get_tree().quit() or intercept for a confirmation dialog.
signal quit_requested


func _ready() -> void:
	%Background.texture = _resolve_background()
	%ContinueButton.visible = SaveManager.get_last_used_slot() >= 0


func _on_new_game_pressed() -> void:
	new_game_requested.emit()


func _on_continue_pressed() -> void:
	continue_requested.emit(SaveManager.get_last_used_slot())


func _on_load_game_pressed() -> void:
	load_game_requested.emit()


func _on_quit_pressed() -> void:
	quit_requested.emit()


func _resolve_background() -> Texture2D:
	var meta := SaveManager.get_last_slot_meta()
	if not meta.is_empty() and meta.has(background_meta_key):
		var val: Variant = meta[background_meta_key]
		if backgrounds.has(val):
			return backgrounds[val]
	return default_background
