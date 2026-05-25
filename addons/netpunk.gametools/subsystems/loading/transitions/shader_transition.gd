class_name ShaderTransition
extends LoadingTransition

## Shader to use for the transition effect.
## Must be shader_type canvas_item and declare:
##   uniform float progress : hint_range(0.0, 1.0)
##   uniform bool  invert                           (optional — see fade_black.gdshader)
## progress runs 0→1 for both in and out.
## invert=false during transition_in, invert=true during transition_out.
@export var shader: Shader
@export var duration_in: float = 0.4
@export var duration_out: float = 0.4


func do_transition_in(screen: CanvasLayer) -> void:
	if shader == null:
		_fallback_fade_in(screen)
		return
	var overlay := _make_overlay(screen, false)
	var mat := overlay.material as ShaderMaterial
	var tween := screen.create_tween()
	tween.tween_method(func(v: float) -> void: mat.set_shader_parameter("progress", v),
			0.0, 1.0, duration_in)
	await tween.finished
	overlay.queue_free()


func do_transition_out(screen: CanvasLayer) -> void:
	if shader == null:
		_fallback_fade_out(screen)
		return
	var overlay := _make_overlay(screen, true)
	var mat := overlay.material as ShaderMaterial
	var tween := screen.create_tween()
	tween.tween_method(func(v: float) -> void: mat.set_shader_parameter("progress", v),
			0.0, 1.0, duration_out)
	await tween.finished


func _make_overlay(screen: CanvasLayer, invert: bool) -> ColorRect:
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("progress", 0.0)
	mat.set_shader_parameter("invert", invert)
	var rect := ColorRect.new()
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.material = mat
	screen.add_child(rect)
	return rect


func _fallback_fade_in(screen: CanvasLayer) -> void:
	screen.modulate.a = 0.0
	var tween := screen.create_tween()
	tween.tween_property(screen, "modulate:a", 1.0, duration_in)
	await tween.finished


func _fallback_fade_out(screen: CanvasLayer) -> void:
	screen.modulate.a = 1.0
	var tween := screen.create_tween()
	tween.tween_property(screen, "modulate:a", 0.0, duration_out)
	await tween.finished
