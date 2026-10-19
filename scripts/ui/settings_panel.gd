extends Control
## Bảng cài đặt (J1): âm lượng nhạc / hiệu ứng, độ phân giải, toàn màn hình.
## Đổi là áp dụng ngay (Settings.apply()); đóng bảng thì lưu vào user://settings.cfg.

signal closed

var _syncing: bool = false  # đang đổ giá trị từ Settings vào control → bỏ qua signal

@onready var _music_slider: HSlider = %MusicSlider
@onready var _music_value: Label = %MusicValue
@onready var _sfx_slider: HSlider = %SfxSlider
@onready var _sfx_value: Label = %SfxValue
@onready var _resolution_option: OptionButton = %ResolutionOption
@onready var _fullscreen_check: CheckBox = %FullscreenCheck
@onready var _close_button: Button = %CloseButton


func _ready() -> void:
	_populate_resolutions()
	_music_slider.value_changed.connect(_on_music_changed)
	_sfx_slider.value_changed.connect(_on_sfx_changed)
	_resolution_option.item_selected.connect(_on_resolution_selected)
	_fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	_close_button.pressed.connect(close)
	_sync_from_settings()


func open() -> void:
	_sync_from_settings()
	show()
	_music_slider.grab_focus()


## Lưu cài đặt rồi đóng bảng.
func close() -> void:
	if not visible:
		return
	Settings.save_settings()
	hide()
	closed.emit()


func _populate_resolutions() -> void:
	_resolution_option.clear()
	for i: int in range(Settings.RESOLUTIONS.size()):
		var resolution: Vector2i = Settings.RESOLUTIONS[i]
		_resolution_option.add_item("%d × %d" % [resolution.x, resolution.y], i)


## Đổ giá trị hiện tại của Settings vào các control (không kích hoạt apply()).
func _sync_from_settings() -> void:
	_syncing = true
	_music_slider.value = Settings.music_volume
	_sfx_slider.value = Settings.sfx_volume
	if _resolution_option.item_count > 0:
		_resolution_option.select(clampi(Settings.resolution_index, 0, _resolution_option.item_count - 1))
	_fullscreen_check.button_pressed = Settings.fullscreen
	_syncing = false
	_update_value_labels()
	_update_resolution_enabled()


func _update_value_labels() -> void:
	_music_value.text = _percent_text(_music_slider.value)
	_sfx_value.text = _percent_text(_sfx_slider.value)


## Toàn màn hình thì độ phân giải cửa sổ không có tác dụng → khóa lại cho rõ.
func _update_resolution_enabled() -> void:
	_resolution_option.disabled = _fullscreen_check.button_pressed
	if _resolution_option.disabled:
		_resolution_option.tooltip_text = "Tắt toàn màn hình để chọn độ phân giải cửa sổ"
	else:
		_resolution_option.tooltip_text = ""


static func _percent_text(value: float) -> String:
	return "%d%%" % roundi(value * 100.0)


func _on_music_changed(value: float) -> void:
	_update_value_labels()
	if _syncing:
		return
	Settings.music_volume = value
	Settings.apply()


func _on_sfx_changed(value: float) -> void:
	_update_value_labels()
	if _syncing:
		return
	Settings.sfx_volume = value
	Settings.apply()


func _on_resolution_selected(index: int) -> void:
	if _syncing:
		return
	Settings.resolution_index = index
	Settings.apply()


func _on_fullscreen_toggled(toggled_on: bool) -> void:
	_update_resolution_enabled()
	if _syncing:
		return
	Settings.fullscreen = toggled_on
	Settings.apply()
