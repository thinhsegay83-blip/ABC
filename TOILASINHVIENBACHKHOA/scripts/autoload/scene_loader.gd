extends CanvasLayer
## SceneLoader (J4) — chuyển scene có hiệu ứng mờ dần qua màn đen.
## Autoload: không khai báo class_name.

signal scene_changed(path: String)

const MAIN_MENU_SCENE: String = "res://scenes/main_menu.tscn"
const GAME_SCENE: String = "res://scenes/game.tscn"
const LAYER_INDEX: int = 100

var is_transitioning: bool = false

var _fade_rect: ColorRect


func _ready() -> void:
	layer = LAYER_INDEX
	process_mode = Node.PROCESS_MODE_ALWAYS
	_fade_rect = ColorRect.new()
	_fade_rect.name = "FadeRect"
	_fade_rect.color = Color(0.0, 0.0, 0.0, 0.0)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_fade_rect)


## Mờ ra đen → đổi scene → hiện dần. Bỏ qua nếu đang chuyển dở.
func change_scene(path: String, fade_time: float = 0.3) -> void:
	if is_transitioning:
		return
	if not ResourceLoader.exists(path):
		push_error("SceneLoader: không tìm thấy scene %s" % path)
		return
	is_transitioning = true
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP  # chặn chuột trong lúc chuyển

	await _fade_to(1.0, fade_time)
	get_tree().paused = false
	var err: Error = get_tree().change_scene_to_file(path)
	if err != OK:
		push_error("SceneLoader: đổi scene %s lỗi (%s)" % [path, error_string(err)])
	# Scene mới được thêm vào cuối frame hiện tại → chờ 1 frame để _ready của nó chạy xong.
	await get_tree().process_frame
	await _fade_to(0.0, fade_time)

	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	is_transitioning = false
	if err == OK:
		scene_changed.emit(path)


## Nuốt mọi input (cả bàn phím) trong lúc chuyển scene, tránh mở menu giữa chừng.
func _input(_event: InputEvent) -> void:
	if is_transitioning:
		get_viewport().set_input_as_handled()


func _fade_to(target_alpha: float, duration: float) -> void:
	if duration <= 0.0:
		_fade_rect.color.a = target_alpha
		return
	var tween: Tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_fade_rect, "color:a", target_alpha, duration)
	await tween.finished
