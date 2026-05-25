class_name LoadingTransition
extends Resource

## Base class for loading screen transitions.
## Subclass this and override do_transition_in / do_transition_out.
## Both methods are coroutines — use await inside them to animate,
## and the LoadingManager will wait until they complete.


## Called when the loading screen appears. The base implementation is instant.
func do_transition_in(_screen: CanvasLayer) -> void:
	pass


## Called when the load completes, before the scene changes. Instant by default.
func do_transition_out(_screen: CanvasLayer) -> void:
	pass
