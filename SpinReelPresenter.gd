extends Node
class_name SpinReelPresenter

signal reel_stopped(index: int)
signal sequence_finished

var reels: Array = []
var symbol_textures: Array[Texture2D] = []
var payline: Control
var status_label: Label
var win_line_label: Label
var preview_frame: int = 0

func configure(p_reels: Array, p_symbols: Array[Texture2D], p_payline: Control, p_status: Label, p_win_line: Label) -> void:
	reels = p_reels
	symbol_textures = p_symbols
	payline = p_payline
	status_label = p_status
	win_line_label = p_win_line

func show_stops(stops: Array) -> void:
	if symbol_textures.is_empty():
		return
	for reel_index in range(reels.size()):
		var reel: Control = reels[reel_index]
		var center := int(stops[reel_index]) if reel_index < stops.size() else 0
		for row in range(3):
			var child := reel.get_node_or_null("Reel%dSymbol%d" % [reel_index + 1,row]) as TextureRect
			if child:
				var symbol_index := posmod(center + row - 1,symbol_textures.size())
				child.texture = symbol_textures[symbol_index]

func _frame_stops(visual_seed: int, frame_index: int) -> Array:
	if symbol_textures.is_empty():
		return [0,0,0]
	var count := symbol_textures.size()
	var output: Array = []
	for reel_index in range(3):
		var mixed := absi(visual_seed + (frame_index + 1) * 104729 + (reel_index + 1) * 15485863)
		output.append(mixed % count)
	return output

func randomize_symbols() -> void:
	# Legacy preview helper retained without runtime RNG. It is deterministic.
	preview_frame += 1
	show_stops(_frame_stops(1,preview_frame))

func play_to(stops: Array, reduced_motion: bool, visual_seed: int = 1) -> void:
	if reduced_motion:
		show_stops(stops)
		if status_label:
			status_label.text = "RESULTAT BEREIT"
		if win_line_label:
			win_line_label.text = "GEWINNLINIE · REWARD BESTÄTIGT"
		await get_tree().create_timer(0.12).timeout
		sequence_finished.emit()
		return

	for tick in range(8):
		show_stops(_frame_stops(visual_seed,tick))
		await get_tree().create_timer(0.055 + float(tick) * 0.006).timeout

	for i in range(reels.size()):
		var reel: Control = reels[i]
		var base_y: float = reel.position.y
		var tween := create_tween()
		tween.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.tween_property(reel,"position:y",base_y + 42.0,0.20)
		tween.tween_property(reel,"position:y",base_y,0.12)
		await tween.finished

		var partial := _frame_stops(visual_seed,8 + i)
		for locked in range(i + 1):
			partial[locked] = int(stops[locked])
		show_stops(partial)

		if status_label:
			status_label.text = "WALZE %d / 3 GESTOPPT" % (i + 1)
		if win_line_label and i == 2:
			win_line_label.text = "GEWINNLINIE · REWARD BESTÄTIGT"
		_pulse_payline(i == 2)
		reel_stopped.emit(i)
		await get_tree().create_timer(0.10).timeout

	show_stops(stops)
	sequence_finished.emit()

func _pulse_payline(strong: bool) -> void:
	if payline == null:
		return
	payline.modulate = Color.WHITE
	var tween := create_tween()
	var target := Color(1.0,0.88,0.45,1.0) if strong else Color(1.0,0.95,0.72,1.0)
	tween.tween_property(payline,"modulate",target,0.07)
	tween.tween_property(payline,"modulate",Color.WHITE,0.11)
