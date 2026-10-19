extends CanvasLayer
## Toast (J8) — thông báo nhỏ ở góc trên bên phải, xếp chồng, mờ dần rồi tự xóa.
## Autoload: không khai báo class_name.

const LAYER_INDEX: int = 90
const SCREEN_MARGIN: int = 16
const SPACING: int = 8
const MAX_TOASTS: int = 5
const FADE_IN_TIME: float = 0.15
const FADE_OUT_TIME: float = 0.4
const BG_COLOR: Color = Color(0.08, 0.09, 0.12, 0.88)
const BORDER_COLOR: Color = Color(1.0, 1.0, 1.0, 0.15)
const TEXT_COLOR: Color = Color(0.95, 0.95, 0.95, 1.0)

var _container: VBoxContainer
var _panel_style: StyleBoxFlat


func _ready() -> void:
	layer = LAYER_INDEX
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()


## Hiện một thông báo trong `duration` giây (chưa tính thời gian mờ dần).
func show_message(text: String, duration: float = 2.5) -> void:
	if not is_inside_tree():
		print("[Toast] ", text)
		return
	if _container == null:
		_build_ui()

	var panel: PanelContainer = PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.size_flags_horizontal = Control.SIZE_SHRINK_END  # canh phải
	panel.add_theme_stylebox_override(&"panel", _panel_style)
	panel.modulate.a = 0.0

	var label: Label = Label.new()
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_color_override(&"font_color", TEXT_COLOR)
	panel.add_child(label)

	_container.add_child(panel)
	_trim_overflow()

	# Tween gắn với panel: panel bị xóa sớm thì tween cũng tự dừng.
	var tween: Tween = panel.create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(panel, "modulate:a", 1.0, FADE_IN_TIME)
	tween.tween_interval(maxf(duration, 0.0))
	tween.tween_property(panel, "modulate:a", 0.0, FADE_OUT_TIME)
	tween.tween_callback(panel.queue_free)


# --- Nội bộ ---------------------------------------------------------------

func _build_ui() -> void:
	_panel_style = StyleBoxFlat.new()
	_panel_style.bg_color = BG_COLOR
	_panel_style.border_color = BORDER_COLOR
	_panel_style.set_border_width_all(1)
	_panel_style.set_corner_radius_all(6)
	_panel_style.content_margin_left = 12.0
	_panel_style.content_margin_right = 12.0
	_panel_style.content_margin_top = 8.0
	_panel_style.content_margin_bottom = 8.0

	_container = VBoxContainer.new()
	_container.name = "ToastStack"
	_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_container.add_theme_constant_override(&"separation", SPACING)
	# Neo góc trên phải; khi có thêm toast thì nở sang trái và xuống dưới.
	_container.set_anchors_and_offsets_preset(
		Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, SCREEN_MARGIN
	)
	_container.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_container.grow_vertical = Control.GROW_DIRECTION_END
	add_child(_container)


## Giữ tối đa MAX_TOASTS thông báo, bỏ cái cũ nhất trước.
func _trim_overflow() -> void:
	while _container.get_child_count() > MAX_TOASTS:
		var oldest: Node = _container.get_child(0)
		_container.remove_child(oldest)
		oldest.queue_free()
