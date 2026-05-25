class_name SlideTransition
extends LoadingTransition

@export var duration_in: float = 0.4
@export var duration_out: float = 0.4
## "left", "right", "up", or "down" — direction the screen slides IN from.
@export var direction: String = "left"


func do_transition_in(screen: CanvasLayer) -> void:
	var vp_size := screen.get_viewport().get_visible_rect().size
	screen.offset = _offscreen(vp_size)
	var tween := screen.create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(screen, "offset", Vector2.ZERO, duration_in)
	await tween.finished


func do_transition_out(screen: CanvasLayer) -> void:
	var vp_size := screen.get_viewport().get_visible_rect().size
	var tween := screen.create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(screen, "offset", _offscreen(vp_size), duration_out)
	await tween.finished


func _offscreen(vp: Vector2) -> Vector2:
	match direction:
		"right": return Vector2(vp.x, 0.0)
		"up":    return Vector2(0.0, -vp.y)
		"down":  return Vector2(0.0, vp.y)
		_:       return Vector2(-vp.x, 0.0)  # default: left
