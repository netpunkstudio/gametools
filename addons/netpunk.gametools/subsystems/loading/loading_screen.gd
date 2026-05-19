extends CanvasLayer

## Metadata key to read from the last used save slot (e.g. "chapter").
@export var background_meta_key: String = "chapter"

## Maps metadata values to background textures.
## Keys are Strings; values are Texture2D resources.
@export var backgrounds: Dictionary = {}

## Shown when no save exists or no key matches.
@export var default_background: Texture2D


func _ready() -> void:
	%Background.texture = _resolve_background()


## Called by LoadingManager each frame with a value in [0.0, 1.0].
func set_progress(value: float) -> void:
	%ProgressBar.value = value


func _resolve_background() -> Texture2D:
	var meta := SaveManager.get_last_slot_meta()
	if not meta.is_empty() and meta.has(background_meta_key):
		var val: Variant = meta[background_meta_key]
		if backgrounds.has(val):
			return backgrounds[val]
	return default_background
