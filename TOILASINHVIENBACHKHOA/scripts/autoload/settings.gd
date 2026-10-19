extends Node
## Settings (J1 — phần Cài đặt): âm lượng, độ phân giải, toàn màn hình.
## Lưu trong user://settings.cfg (ConfigFile). Autoload: không khai báo class_name.

signal settings_changed

const SETTINGS_PATH: String = "user://settings.cfg"
const RESOLUTIONS: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
]
const SECTION_AUDIO: String = "audio"
const SECTION_DISPLAY: String = "display"
const SECTION_DIALOGUE: String = "dialogue"
const SECTION_ACCESS: String = "accessibility"
## Tốc độ chữ (ký tự/giây): Chậm / Vừa / Nhanh / Tức thì (0).
const TEXT_SPEEDS: Array[int] = [20, 40, 80, 0]
const TEXT_SPEED_NAMES: Array[String] = ["Chậm", "Vừa", "Nhanh", "Tức thì"]

var music_volume: float = 0.8
var sfx_volume: float = 0.8
var fullscreen: bool = false
var resolution_index: int = 0
var text_speed: int = 40
var auto_delay: float = 1.2
var skip_unread: bool = false
## Bước 6: tắt lớp nhiễu mép màn hình (điện thoại vẫn báo).
var reduce_screen_noise: bool = false
## Bước 6: phụ đề cho âm thanh dị tượng.
var audio_subtitles: bool = true
## Bước 7: hiện bảng hướng dẫn chơi.
var show_tutorial: bool = true


func _ready() -> void:
	load_settings()
	apply()


## Đọc file cài đặt; thiếu file hoặc thiếu khóa thì giữ giá trị mặc định.
func load_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	var err: Error = config.load(SETTINGS_PATH)
	if err != OK:
		if err != ERR_FILE_NOT_FOUND:
			push_warning("Settings: không đọc được %s (%s)" % [SETTINGS_PATH, error_string(err)])
		return
	music_volume = clampf(_read_float(config, SECTION_AUDIO, "music_volume", music_volume), 0.0, 1.0)
	sfx_volume = clampf(_read_float(config, SECTION_AUDIO, "sfx_volume", sfx_volume), 0.0, 1.0)
	fullscreen = _read_bool(config, SECTION_DISPLAY, "fullscreen", fullscreen)
	resolution_index = clampi(
		_read_int(config, SECTION_DISPLAY, "resolution_index", resolution_index),
		0,
		RESOLUTIONS.size() - 1
	)
	text_speed = maxi(0, _read_int(config, SECTION_DIALOGUE, "text_speed", text_speed))
	auto_delay = clampf(_read_float(config, SECTION_DIALOGUE, "auto_delay", auto_delay), 0.5, 3.0)
	skip_unread = _read_bool(config, SECTION_DIALOGUE, "skip_unread", skip_unread)
	reduce_screen_noise = _read_bool(config, SECTION_ACCESS, "reduce_screen_noise", reduce_screen_noise)
	audio_subtitles = _read_bool(config, SECTION_ACCESS, "audio_subtitles", audio_subtitles)
	show_tutorial = _read_bool(config, SECTION_ACCESS, "show_tutorial", show_tutorial)


func save_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.set_value(SECTION_AUDIO, "music_volume", music_volume)
	config.set_value(SECTION_AUDIO, "sfx_volume", sfx_volume)
	config.set_value(SECTION_DISPLAY, "fullscreen", fullscreen)
	config.set_value(SECTION_DISPLAY, "resolution_index", resolution_index)
	config.set_value(SECTION_DIALOGUE, "text_speed", text_speed)
	config.set_value(SECTION_DIALOGUE, "auto_delay", auto_delay)
	config.set_value(SECTION_DIALOGUE, "skip_unread", skip_unread)
	config.set_value(SECTION_ACCESS, "reduce_screen_noise", reduce_screen_noise)
	config.set_value(SECTION_ACCESS, "audio_subtitles", audio_subtitles)
	config.set_value(SECTION_ACCESS, "show_tutorial", show_tutorial)
	var err: Error = config.save(SETTINGS_PATH)
	if err != OK:
		push_warning("Settings: không lưu được %s (%s)" % [SETTINGS_PATH, error_string(err)])


## Áp dụng toàn bộ cài đặt hiện tại rồi phát settings_changed.
func apply() -> void:
	music_volume = clampf(music_volume, 0.0, 1.0)
	sfx_volume = clampf(sfx_volume, 0.0, 1.0)
	resolution_index = clampi(resolution_index, 0, RESOLUTIONS.size() - 1)
	AudioManager.set_bus_volume_linear(AudioManager.MUSIC_BUS, music_volume)
	AudioManager.set_bus_volume_linear(AudioManager.SFX_BUS, sfx_volume)
	_apply_display()
	settings_changed.emit()


# --- Nội bộ ---------------------------------------------------------------

func _apply_display() -> void:
	# Chạy --headless (test, server) thì không đụng tới cửa sổ.
	if DisplayServer.get_name() == "headless":
		return
	var current_mode: DisplayServer.WindowMode = DisplayServer.window_get_mode()
	if fullscreen:
		if current_mode != DisplayServer.WINDOW_MODE_FULLSCREEN \
				and current_mode != DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		return

	if current_mode != DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	var target_size: Vector2i = RESOLUTIONS[resolution_index]
	# Chỉ đổi khi khác kích thước hiện tại (tránh giật cửa sổ lúc khởi động).
	if DisplayServer.window_get_size() != target_size:
		DisplayServer.window_set_size(target_size)
		_center_window(target_size)


func _center_window(window_size: Vector2i) -> void:
	var screen: int = DisplayServer.window_get_current_screen()
	var usable: Rect2i = DisplayServer.screen_get_usable_rect(screen)
	var offset: Vector2i = (usable.size - window_size) / 2
	var pos: Vector2i = usable.position + Vector2i(maxi(offset.x, 0), maxi(offset.y, 0))
	DisplayServer.window_set_position(pos)


## Đọc số thực an toàn (giá trị sai kiểu thì dùng mặc định).
static func _read_float(config: ConfigFile, section: String, key: String, fallback: float) -> float:
	var value: Variant = config.get_value(section, key, fallback)
	if typeof(value) == TYPE_FLOAT or typeof(value) == TYPE_INT:
		return float(value)
	return fallback


static func _read_int(config: ConfigFile, section: String, key: String, fallback: int) -> int:
	var value: Variant = config.get_value(section, key, fallback)
	if typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT:
		return int(value)
	return fallback


static func _read_bool(config: ConfigFile, section: String, key: String, fallback: bool) -> bool:
	var value: Variant = config.get_value(section, key, fallback)
	if typeof(value) == TYPE_BOOL:
		return bool(value)
	if typeof(value) == TYPE_INT:
		return int(value) != 0
	return fallback
