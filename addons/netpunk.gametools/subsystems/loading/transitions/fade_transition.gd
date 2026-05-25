class_name FadeTransition
extends LoadingTransition

@export var duration_in: float = 0.4
@export var duration_out: float = 0.4


func do_transition_in(screen: CanvasLayer) -> void:
	screen.modulate.a = 0.0
	var tween := screen.create_tween()
	tween.tween_property(screen, "modulate:a", 1.0, duration_in)
	await tween.finished


func do_transition_out(screen: CanvasLayer) -> void:
	screen.modulate.a = 1.0
	var tween := screen.create_tween()
	tween.tween_property(screen, "modulate:a", 0.0, duration_out)
	await tween.finished
