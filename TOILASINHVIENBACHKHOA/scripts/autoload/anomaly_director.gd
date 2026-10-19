extends Node
## AnomalyDirector (bước 6) — radar điện thoại (G1), vùng tiếng ù trừ Sanity (G2),
## vòng lặp cầu thang (G3), lệnh cho sự kiện đêm (G4).
## Chưa có bản đồ: nguồn/vùng tính theo NƠI người chơi đang ở (EventDirector.current_place);
## bước 2 có thể thay bằng vị trí thật qua RadarMath.signal_at().
## Autoload: không khai báo class_name. Đăng ký sau EventDirector.
## Tông: bí ẩn nhẹ — tiếng ù nhỏ, fade-in, không âm thanh đột ngột.

signal radar_changed(bars: int, hum_hz: float)
signal stair_loop_started
signal stair_landing_changed(index: int)
signal stair_loop_ended(escaped: bool)
## Cho bản đồ (bước 2): cảnh đêm, NPC đi/ẩn.
signal night_scene(active: bool)
signal npc_moved(npc_id: String, anchor_id: String, seconds: float)
signal npc_hidden(npc_id: String)
## Kịch bản đưa người chơi sang khu khác (cảnh đêm, cao trào, thoát cầu thang, ngủ tiếp).
## Bản đồ nghe để dịch chuyển nhân vật; spawn_id rỗng = điểm vào mặc định của khu.
signal area_change_requested(area_id: String, spawn_id: String)

const CATALOG_PATH: String = "res://data/anomalies/stair_anomalies.tres"
const HINTS_PATH: String = "res://data/puzzle_hints.tres"
const HUM_PATH: String = "res://audio/sfx/hum_25hz_tuong_trung.wav"
const TICK_PATH: String = "res://audio/sfx/radar_tick.wav"
const HUM_VOLUME_DB: float = -12.0
const SILENT_DB: float = -60.0
const UPDATE_INTERVAL: float = 0.2
const SUBTITLE_HUM: String = "(Tiếng ù rất trầm, như rung trong lồng ngực…)"
const LOOP_FLAG: String = "sys_cau_thang_da_vao"

var catalog: StairAnomalyCatalog
var hints: PuzzleHintConfig
var loop: StairLoopState = StairLoopState.new()
var bars: int = 0
var hum_hz: float = 0.0
var in_zone: bool = false
## Đã hỏi câu Vật lý trong lần vào vòng lặp này chưa.
var question_asked: bool = false
## Lệnh "~ stair_loop start" chạy giữa hội thoại → chờ hội thoại xong mới vào vòng lặp.
var pending_start: bool = false

var _drain: DrainCounter = DrainCounter.new(1, 5.0, 10)
var _update_timer: float = 0.0
var _tick_timer: float = 0.0
var _hum_player: AudioStreamPlayer
var _tick_player: AudioStreamPlayer
var _hum_tween: Tween
var _overlay_layer: CanvasLayer
var _edges: Array[ColorRect] = []
var _subtitle: Label
var _drain_toast_shown: bool = false
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	catalog = load(CATALOG_PATH) as StairAnomalyCatalog
	hints = load(HINTS_PATH) as PuzzleHintConfig
	if hints == null:
		hints = PuzzleHintConfig.new()
	_rng.randomize()
	_build_audio()
	_build_overlay()
	Game.state_replaced.connect(_on_state_replaced)
	_register_dialogue_hooks()


func _exit_tree() -> void:
	for variable: String in ["stair.anomaly", "stair.active", "stair.hint"]:
		DialogueCondition.unregister_variable(variable)


func _process(delta: float) -> void:
	if not Game.has_active_game():
		_set_hum(false)
		_update_overlay(0)
		return
	_update_timer -= delta
	if _update_timer <= 0.0:
		_update_timer = UPDATE_INTERVAL
		_recompute()
	var drained: int = _drain.update(delta, in_zone, _is_controllable())
	if drained > 0:
		Game.state.stats.change_stat(PlayerStats.Stat.SANITY, -drained)
		if not _drain_toast_shown:
			_drain_toast_shown = true
			Toast.show_message("Tiếng ù làm bạn bồn chồn (Sanity −%d)" % drained)
	if bars > 0 and not get_tree().paused:
		_tick_timer -= delta
		if _tick_timer <= 0.0:
			_tick_timer = 1.6 / bars
			if _tick_player.stream != null:
				_tick_player.play()


# --- Radar + vùng ---------------------------------------------------------

## Nguồn dị tượng đang bật ở nơi người chơi đứng: [{id, strength, hum_hz}].
func active_sources() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not Game.has_active_game():
		return result
	var state: GameState = Game.state
	var place: String = EventDirector.current_place
	for person: Dictionary in EventDirector.npcs_at(place):
		var npc: NpcData = person["npc"]
		if npc.id == "minh" and state.flags.get_flag("minh_trang_thai") >= 2:
			var face_wall: bool = person["info"]["behavior"] == "face_wall"
			result.append({"id": "src_minh", "strength": 0.5 if face_wall else 0.3,
					"hum_hz": StairPhysics.base_hz() if face_wall else 0.0})
		if npc.id == "k" and state.clock.get_week() >= 3:
			result.append({"id": "src_to_roi", "strength": 0.35, "hum_hz": 0.0})
	if place == "ktx_hallway" and state.clock.get_week() >= 3 and state.clock.slot == GameClock.Slot.NIGHT:
		result.append({"id": "src_cau_thang", "strength": 0.5, "hum_hz": StairPhysics.base_hz()})
	return result


func _recompute() -> void:
	var new_bars: int = 0
	var new_hz: float = 0.0
	if loop.active:
		new_bars = maxi(1, 4 - loop.streak)
		new_hz = catalog.landing_hz(loop.current_anomaly)
		in_zone = false  # trong vòng lặp: phạt theo lượt sai, không trừ theo giây
	else:
		var sources: Array[Dictionary] = active_sources()
		var signals: Array[Dictionary] = []
		for source: Dictionary in sources:
			# Cùng nơi = khoảng cách 0 (chưa có bản đồ).
			signals.append({"position": Vector2.ZERO, "strength": source["strength"], "radius": 1.0})
			new_hz = maxf(new_hz, float(source["hum_hz"]))
		new_bars = RadarMath.bars(RadarMath.signal_at(Vector2.ZERO, signals))
		in_zone = new_hz > 0.0
	if in_zone or loop.active:
		_set_hum(true)
	else:
		_set_hum(false)
		_drain_toast_shown = false
	if new_bars >= 1 and Game.state.flags.get_flag("radar_lan_dau") == 0:
		Game.state.flags.set_flag("radar_lan_dau", 1)
		Toast.show_message("Điện thoại bỗng nhiễu sóng…")
	_update_overlay(new_bars)
	if new_bars != bars or not is_equal_approx(new_hz, hum_hz):
		bars = new_bars
		hum_hz = new_hz
		radar_changed.emit(bars, hum_hz)


## Người chơi đang tự do điều khiển (không pause, không hội thoại, không menu/điện thoại).
func _is_controllable() -> bool:
	if get_tree().paused or DialogueSystem.is_active():
		return false
	for group: StringName in [&"life_ui", &"phone"]:
		for node: Node in get_tree().get_nodes_in_group(group):
			if node.has_method("is_any_open") and node.call("is_any_open"):
				return false
			if node.has_method("is_open") and node.call("is_open"):
				return false
	return true


# --- Vòng lặp cầu thang (G3) ----------------------------------------------

func begin_stair_loop() -> void:
	if loop.active or catalog == null or not Game.has_active_game():
		return
	loop.start(_rng.randi(), catalog.ids(), hints.required_streak)
	question_asked = false
	SaveGate.block("stair_loop")
	AudioManager.stop_music(1.0)
	get_tree().call_group(&"life_ui", &"close_all")
	get_tree().call_group(&"phone", &"close")
	stair_loop_started.emit()
	_recompute()
	if Game.state.flags.get_flag(LOOP_FLAG) == 0:
		Game.state.flags.set_flag(LOOP_FLAG, 1)
		DialogueSystem.start("cau_thang_bat_dau")
	stair_landing_changed.emit(loop.landing_index)


## Vào vòng lặp nếu có lệnh đang chờ và không còn hội thoại nào chạy.
func start_pending() -> void:
	if not pending_start:
		return
	if not Game.has_active_game():
		pending_start = false  # đã về menu chính trước khi kịp vào cầu thang
		return
	if DialogueSystem.is_active():
		start_pending.call_deferred()  # thử lại khung hình sau
		return
	pending_start = false
	begin_stair_loop()


## "up"/"down". Trả "correct" / "wrong" / "escaped".
func stair_choose(direction: String) -> String:
	if not loop.active:
		return ""
	var result: String = loop.choose(direction)
	match result:
		"wrong":
			Game.state.stats.change_stat(PlayerStats.Stat.SANITY, hints.wrong_sanity)
			DialogueSystem.start("cau_thang_sai_%d" % _rng.randi_range(1, 3))
		"correct":
			if loop.streak >= 2:
				DialogueSystem.start("cau_thang_dung_%d" % mini(loop.streak - 1, 3))
		"escaped":
			_end_loop(true)
			return result
	loop.next_landing()
	_recompute()
	stair_landing_changed.emit(loop.landing_index)
	return result


## Gợi ý do người chơi chủ động mở (nút "Suy nghĩ" / phím G).
func show_hint() -> bool:
	if not loop.active:
		return false
	return DialogueSystem.start("goi_y_%d" % current_hint_level())


func current_hint_level() -> int:
	var knowledge: int = Game.state.stats.get_stat(PlayerStats.Stat.KNOWLEDGE) if Game.has_active_game() else 0
	return loop.hint_level(knowledge, hints)


func can_call_senior() -> bool:
	return loop.active and loop.should_offer_assist(hints) and not loop.assist_used_here


func call_senior() -> bool:
	if not can_call_senior():
		return false
	loop.assist_used_here = true
	Game.state.stats.change_stat(PlayerStats.Stat.SANITY, hints.assist_sanity)
	return DialogueSystem.start("goi_tien_boi")


## Câu hỏi Vật lý tùy chọn ở chiếu nghỉ thứ 2 khi mức gợi ý ≥ 2.
func physics_question_available() -> bool:
	return loop.active and loop.landing_index >= 1 and not question_asked \
			and current_hint_level() >= 2 and Game.state.flags.get_flag("hieu_vong_lap") == 0


func ask_physics_question() -> bool:
	if not physics_question_available():
		return false
	question_asked = true
	return DialogueSystem.start("cau_thang_cau_hoi")


func landing_lines() -> Array[String]:
	return catalog.landing_lines(loop.current_anomaly) if loop.active else []


## Thoát ngay (debug) hoặc hủy (tải game khác).
func abort_loop() -> void:
	if loop.active:
		_end_loop(false)


func _end_loop(escaped: bool) -> void:
	loop.active = false
	SaveGate.unblock("stair_loop")
	if escaped:
		Game.state.flags.set_flag("thoat_cau_thang", 1)
		DialogueSystem.dialogue_event.emit("stair_loop_escaped", PackedStringArray())
		DialogueSystem.start("cau_thang_thoat")
	_request_area("ktx_hallway", "")
	_recompute()
	stair_loop_ended.emit(escaped)


# --- Âm thanh, lớp phủ, phụ đề --------------------------------------------

func _set_hum(on: bool) -> void:
	if _hum_player == null or _hum_player.stream == null:
		_subtitle.visible = on and Settings.audio_subtitles
		return
	_subtitle.visible = on and Settings.audio_subtitles
	if on == _hum_player.playing and (_hum_tween == null or not _hum_tween.is_running()):
		return
	if _hum_tween != null:
		_hum_tween.kill()
	_hum_tween = create_tween()
	if on:
		if not _hum_player.playing:
			_hum_player.volume_db = SILENT_DB
			_hum_player.play()
		_hum_tween.tween_property(_hum_player, "volume_db", HUM_VOLUME_DB, 1.0)
	else:
		_hum_tween.tween_property(_hum_player, "volume_db", SILENT_DB, 1.0)
		_hum_tween.tween_callback(_hum_player.stop)


func _build_audio() -> void:
	_hum_player = AudioStreamPlayer.new()
	_hum_player.bus = AudioManager.SFX_BUS
	_hum_player.volume_db = SILENT_DB
	var hum: AudioStreamWAV = _load_wav(HUM_PATH)
	if hum != null:
		# Bật lặp bằng code (không phụ thuộc thiết lập import).
		hum.loop_mode = AudioStreamWAV.LOOP_FORWARD
		hum.loop_begin = 0
		hum.loop_end = hum.data.size() / 2  # 16 bit mono → 2 byte mỗi mẫu
		_hum_player.stream = hum
	add_child(_hum_player)
	_tick_player = AudioStreamPlayer.new()
	_tick_player.bus = AudioManager.SFX_BUS
	_tick_player.volume_db = -18.0
	_tick_player.stream = _load_wav(TICK_PATH)
	add_child(_tick_player)


static func _load_wav(path: String) -> AudioStreamWAV:
	if not ResourceLoader.exists(path):
		return null
	return load(path) as AudioStreamWAV


func _build_overlay() -> void:
	_overlay_layer = CanvasLayer.new()
	_overlay_layer.layer = 85
	add_child(_overlay_layer)
	var root: Control = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay_layer.add_child(root)
	# 4 dải mép màn hình rất nhẹ (alpha ≤ 0,15).
	for side in 4:
		var edge: ColorRect = ColorRect.new()
		edge.color = Color(0.55, 0.45, 0.85, 0.0)
		edge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		match side:
			0:
				edge.set_anchors_preset(Control.PRESET_TOP_WIDE)
				edge.offset_bottom = 18
			1:
				edge.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
				edge.offset_top = -18
			2:
				edge.set_anchors_preset(Control.PRESET_LEFT_WIDE)
				edge.offset_right = 18
			3:
				edge.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
				edge.offset_left = -18
		root.add_child(edge)
		_edges.append(edge)
	_subtitle = Label.new()
	_subtitle.text = SUBTITLE_HUM
	_subtitle.add_theme_font_size_override("font_size", 16)
	_subtitle.add_theme_color_override("font_color", Color(0.85, 0.82, 0.95))
	_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_subtitle.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_subtitle.offset_top = -250
	_subtitle.offset_bottom = -225
	_subtitle.offset_left = -300
	_subtitle.offset_right = 300
	_subtitle.visible = false
	root.add_child(_subtitle)


func _update_overlay(bar_count: int) -> void:
	var alpha: float = 0.0 if Settings.reduce_screen_noise else 0.15 * bar_count / 4.0
	for edge: ColorRect in _edges:
		edge.color.a = alpha * _rng.randf_range(0.6, 1.0)


func _on_state_replaced() -> void:
	pending_start = false
	abort_loop()
	SaveGate.clear()
	bars = 0
	hum_hz = 0.0
	in_zone = false
	_drain = DrainCounter.new(1, 5.0, 10)


func _request_area(area_id: String, spawn_id: String) -> void:
	EventDirector.current_place = area_id
	area_change_requested.emit(area_id, spawn_id)


# --- Lệnh hội thoại -------------------------------------------------------

func _register_dialogue_hooks() -> void:
	DialogueSystem.register_command("stair_loop", func(args: PackedStringArray, _state: GameState) -> void:
		var mode: String = args[0] if not args.is_empty() else "start"
		if mode == "start":
			pending_start = true
			start_pending.call_deferred()
		elif mode == "escape":
			abort_loop()
	)
	DialogueSystem.register_command("night_wake", func(_args: PackedStringArray, _state: GameState) -> void:
		night_scene.emit(true)
	)
	DialogueSystem.register_command("change_area", func(args: PackedStringArray, _state: GameState) -> void:
		if not args.is_empty():
			_request_area(args[0], args[1] if args.size() >= 2 else "")
	)
	DialogueSystem.register_command("npc_move", func(args: PackedStringArray, _state: GameState) -> void:
		if args.size() >= 2:
			npc_moved.emit(args[0], args[1], args[2].to_float() if args.size() >= 3 else 2.0)
	)
	DialogueSystem.register_command("npc_hide", func(args: PackedStringArray, _state: GameState) -> void:
		if not args.is_empty():
			npc_hidden.emit(args[0])
	)
	DialogueSystem.register_command("sleep_resume", func(args: PackedStringArray, _state: GameState) -> void:
		night_scene.emit(false)
		_request_area("ktx_room", "")
		StudentLife.complete_sleep(args[0].to_float() if not args.is_empty() else 1.0)
	)
	DialogueCondition.register_variable("stair.anomaly", func(_variable: String, _state: GameState) -> int:
		return 1 if loop.active and not loop.current_anomaly.is_empty() else 0
	)
	DialogueCondition.register_variable("stair.active", func(_variable: String, _state: GameState) -> int:
		return 1 if loop.active else 0
	)
	DialogueCondition.register_variable("stair.hint", func(_variable: String, _state: GameState) -> int:
		return current_hint_level() if loop.active else 0
	)
