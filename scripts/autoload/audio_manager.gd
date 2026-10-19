extends Node
## AudioManager (J5) — nhạc nền + hiệu ứng âm thanh qua 2 bus "Music" và "SFX".
## Autoload: không khai báo class_name.

const MUSIC_BUS: String = "Music"
const SFX_BUS: String = "SFX"
const MASTER_BUS: String = "Master"
const SFX_POOL_SIZE: int = 8
## Mức âm lượng tuyến tính coi như im lặng (tránh linear_to_db(0) = -inf).
const SILENT_LINEAR: float = 0.0001
const SILENT_DB: float = -80.0

var _music_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
var _next_sfx_index: int = 0
var _music_tween: Tween
## Hệ số mờ dần hiện tại của nhạc (0..1), độc lập với âm lượng bus.
var _music_fade: float = 1.0


func _ready() -> void:
	# Chạy cả khi pause để nhạc/âm thanh nút bấm trong menu tạm dừng vẫn hoạt động.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_bus(MUSIC_BUS)
	_ensure_bus(SFX_BUS)

	_music_player = AudioStreamPlayer.new()
	_music_player.name = "MusicPlayer"
	_music_player.bus = MUSIC_BUS
	add_child(_music_player)

	for i: int in range(SFX_POOL_SIZE):
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.name = "SfxPlayer%d" % i
		player.bus = SFX_BUS
		add_child(player)
		_sfx_players.append(player)


## Phát nhạc nền, mờ dần nhạc cũ rồi hiện dần nhạc mới. stream null → bỏ qua.
func play_music(stream: AudioStream, fade_time: float = 0.5) -> void:
	if stream == null or _music_player == null:
		return
	if _music_player.playing and _music_player.stream == stream:
		return
	_kill_music_tween()

	if fade_time <= 0.0:
		_start_music(stream)
		_set_music_fade(1.0)
		return

	var half: float = fade_time * 0.5
	_music_tween = create_tween()
	_music_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	if _music_player.playing:
		_music_tween.tween_method(_set_music_fade, _music_fade, 0.0, half)
	else:
		_set_music_fade(0.0)
	_music_tween.tween_callback(_start_music.bind(stream))
	_music_tween.tween_method(_set_music_fade, 0.0, 1.0, half)


## Dừng nhạc nền (có mờ dần).
func stop_music(fade_time: float = 0.5) -> void:
	if _music_player == null or not _music_player.playing:
		return
	_kill_music_tween()
	if fade_time <= 0.0:
		_music_player.stop()
		_set_music_fade(1.0)
		return
	_music_tween = create_tween()
	_music_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_music_tween.tween_method(_set_music_fade, _music_fade, 0.0, fade_time)
	_music_tween.tween_callback(_music_player.stop)


## Phát một hiệu ứng âm thanh bằng player rảnh trong pool (hết chỗ thì xoay vòng).
func play_sfx(stream: AudioStream) -> void:
	if stream == null or _sfx_players.is_empty():
		return
	var player: AudioStreamPlayer = null
	for candidate: AudioStreamPlayer in _sfx_players:
		if not candidate.playing:
			player = candidate
			break
	if player == null:
		player = _sfx_players[_next_sfx_index]
		_next_sfx_index = (_next_sfx_index + 1) % _sfx_players.size()
	player.stream = stream
	player.play()


## Đặt âm lượng bus theo thang tuyến tính 0..1; 0 → tắt tiếng (mute).
func set_bus_volume_linear(bus_name: String, value: float) -> void:
	var index: int = _get_or_create_bus(bus_name)
	if index == -1:
		push_warning("AudioManager: không có bus '%s'" % bus_name)
		return
	var linear: float = clampf(value, 0.0, 1.0)
	if linear <= 0.0:
		AudioServer.set_bus_mute(index, true)
		AudioServer.set_bus_volume_db(index, SILENT_DB)
	else:
		AudioServer.set_bus_mute(index, false)
		AudioServer.set_bus_volume_db(index, linear_to_db(linear))


func get_bus_volume_linear(bus_name: String) -> float:
	var index: int = AudioServer.get_bus_index(bus_name)
	if index == -1:
		return 0.0
	if AudioServer.is_bus_mute(index):
		return 0.0
	return clampf(db_to_linear(AudioServer.get_bus_volume_db(index)), 0.0, 1.0)


# --- Nội bộ ---------------------------------------------------------------

## Tạo bus (gửi về Master) nếu chưa có. Trả về chỉ số bus.
func _ensure_bus(bus_name: String) -> int:
	var index: int = AudioServer.get_bus_index(bus_name)
	if index != -1:
		return index
	AudioServer.add_bus()
	index = AudioServer.bus_count - 1
	AudioServer.set_bus_name(index, bus_name)
	AudioServer.set_bus_send(index, MASTER_BUS)
	return index


## Bus Music/SFX được tạo tự động nếu thiếu (phòng khi Settings gọi sớm); bus khác thì chỉ tra cứu.
func _get_or_create_bus(bus_name: String) -> int:
	if bus_name == MUSIC_BUS or bus_name == SFX_BUS:
		return _ensure_bus(bus_name)
	return AudioServer.get_bus_index(bus_name)


func _start_music(stream: AudioStream) -> void:
	_music_player.stream = stream
	_music_player.play()


func _set_music_fade(value: float) -> void:
	_music_fade = clampf(value, 0.0, 1.0)
	if _music_player != null:
		_music_player.volume_db = linear_to_db(maxf(_music_fade, SILENT_LINEAR))


func _kill_music_tween() -> void:
	if _music_tween != null and _music_tween.is_valid():
		_music_tween.kill()
	_music_tween = null
