extends RefCounted
## Bot chơi thử MVP (bước 7): chơi trọn một ván tới màn "Còn tiếp…" bằng autoload thật,
## không cần cảnh/bản đồ — giống người chơi bấm menu Q / điện thoại / cầu thang dạng chữ.
## Không phải file test (không có tiền tố test_). Dùng trong test_playthrough_mvp.gd.
##
## Chạy đồng bộ: tự gọi EventDirector.pump(), AnomalyDirector.start_pending() và
## LifeSim.check_collapse() thay cho _process / call_deferred của game thật.

const STUDY: String = "cham_hoc"
const WORK: String = "cham_lam"
const FOLLOW_K: String = "theo_k"
const STRATEGY_NAMES: Dictionary = {STUDY: "Chăm học", WORK: "Chăm làm", FOLLOW_K: "Theo K."}

const MAX_SLOT_STEPS: int = 400
const MAX_SETTLE_STEPS: int = 3000
const MAX_LOOP_CHOICES: int = 60
const LAST_DAY: int = 30
## Đói dưới mức này thì đi ăn; ăn tới khi đạt FULL_HUNGER.
const EAT_BELOW: int = 45
const FULL_HUNGER: int = 70
const TIRED_STAMINA: int = 30
## Giữ lại sau khi đóng học phí để còn tiền ăn.
const TUITION_RESERVE: int = 100000

## Lựa chọn ưu tiên theo chuỗi con của nội dung lựa chọn (thứ tự = độ ưu tiên).
const COMMON_PICKS: Array[String] = [
	"Góp 200.000", "Con sẽ đi làm thêm", "Con làm", "Nói thẳng", "Đi xem sao",
	"3,43 m", "Trả lời lại", "Để hôm khác",
]
const K_PICKS: Array[String] = ["Kể thêm đi anh", "Nhận việc", "Để em tính", "Để Minh nghỉ"]
const NO_K_PICKS: Array[String] = ["Vào CLB có phải đóng phí", "Từ chối", "Em nghỉ phát tờ rơi"]

var strategy: String
## "A" hoặc "B": lựa chọn KTX ở đoạn mở đầu.
var ktx: String
## Số lần cố tình đi sai trong vòng lặp cầu thang (để chạy cả nhánh sai).
var planned_mistakes: int = 0

# --- Kết quả ---
var stuck: String = ""
var fallbacks: int = 0
var collapses: int = 0
var lines_seen: int = 0
var loop_choices: int = 0
var choices_made: Array[String] = []
var events_seen: Array[String] = []
var dialogues_started: Array[String] = []

var _choices: Array = []
var _met_today: Dictionary = {}
var _met_day: int = -1


func _init(strategy_id: String, ktx_choice: String = "A", mistakes: int = 0) -> void:
	strategy = strategy_id
	ktx = ktx_choice
	planned_mistakes = mistakes


## Chơi một ván mới tới khi mvp_hoan_thanh = 1 (hoặc kẹt). Trả GameState cuối ván.
func play(difficulty_id: String, seed_value: int) -> GameState:
	_attach()
	StudentLife.sim.rng.seed = seed_value
	Game.new_game(difficulty_id)
	var state: GameState = Game.state
	var steps: int = 0
	while stuck.is_empty() and not _finished(state):
		steps += 1
		if steps > MAX_SLOT_STEPS or state.clock.day > LAST_DAY:
			stuck = "quá giới hạn ở ngày %d khung %d" % [state.clock.day, state.clock.slot]
			break
		settle()
		if _finished(state) or not stuck.is_empty():
			break
		_act_slot()
	settle()  # đọc hết hội thoại kết thúc
	_detach()
	# Tiếng ù tắt bằng tween (cần khung hình) → dừng hẳn để không còn phát lúc thoát test.
	var hum: AudioStreamPlayer = AnomalyDirector.get("_hum_player")
	if hum != null:
		hum.stop()
	return state


## Chạy hết hội thoại / sự kiện / vòng lặp đang chờ cho tới khi game "đứng yên".
func settle() -> void:
	for _i in MAX_SETTLE_STEPS:
		if not stuck.is_empty():
			return
		if DialogueSystem.is_active():
			_step_dialogue()
			continue
		if AnomalyDirector.pending_start:
			AnomalyDirector.start_pending()
			continue
		if AnomalyDirector.loop.active:
			_step_loop()
			continue
		var key: int = _key()
		if EventDirector.pump():
			continue
		if EventDirector.has_pending() or _key() != key:
			continue
		if Game.state.flags.get_flag("mvp_hoan_thanh") == 0 and StudentLife.sim.check_collapse():
			collapses += 1
			continue
		return
	stuck = "settle không dừng (ngày %d khung %d)" % [Game.state.clock.day, Game.state.clock.slot]


func strategy_name() -> String:
	return str(STRATEGY_NAMES.get(strategy, strategy))


# --- Hội thoại -------------------------------------------------------------

func _step_dialogue() -> void:
	if _choices.is_empty():
		DialogueSystem.advance()
		if DialogueSystem.is_active() and _choices.is_empty() and not _waiting_line():
			stuck = "hội thoại không tiến được"
		return
	var options: Array = _choices
	_choices = []
	var picked: Dictionary = _pick(options)
	if picked.is_empty():
		stuck = "không có lựa chọn nào bấm được: %s" % str(options)
		return
	choices_made.append(str(picked["text"]))
	DialogueSystem.choose(int(picked["index"]), str(picked["text"]))


func _waiting_line() -> bool:
	return bool(DialogueSystem.get("_runner").get("_waiting_line"))


func _pick(options: Array) -> Dictionary:
	var prefs: Array[String] = []
	if strategy == FOLLOW_K:
		prefs.append_array(K_PICKS)
	else:
		prefs.append_array(NO_K_PICKS)
	prefs.append("KTX Khu " + ktx)
	prefs.append_array(COMMON_PICKS)
	for pref: String in prefs:
		for option: Dictionary in options:
			if option["enabled"] and str(option["text"]).contains(pref):
				return option
	for option: Dictionary in options:
		if option["enabled"]:
			return option
	return {}


func _on_choices(options: Array) -> void:
	_choices = options


func _on_line(_line: Dictionary) -> void:
	lines_seen += 1


func _on_event(event_name: String, _args: PackedStringArray) -> void:
	events_seen.append(event_name)


func _on_started(node_id: String) -> void:
	dialogues_started.append(node_id)


func _attach() -> void:
	DialogueSystem.choices_shown.connect(_on_choices)
	DialogueSystem.line_shown.connect(_on_line)
	DialogueSystem.dialogue_event.connect(_on_event)
	DialogueSystem.dialogue_started.connect(_on_started)


func _detach() -> void:
	DialogueSystem.choices_shown.disconnect(_on_choices)
	DialogueSystem.line_shown.disconnect(_on_line)
	DialogueSystem.dialogue_event.disconnect(_on_event)
	DialogueSystem.dialogue_started.disconnect(_on_started)


# --- Vòng lặp cầu thang ------------------------------------------------------

func _step_loop() -> void:
	loop_choices += 1
	if loop_choices > MAX_LOOP_CHOICES:
		stuck = "vòng lặp cầu thang không thoát được"
		return
	if AnomalyDirector.physics_question_available():
		AnomalyDirector.ask_physics_question()
		return
	var loop: StairLoopState = AnomalyDirector.loop
	var correct: String = "up" if loop.current_anomaly.is_empty() else "down"
	var direction: String = correct
	if planned_mistakes > 0:
		planned_mistakes -= 1
		direction = "down" if correct == "up" else "up"
	AnomalyDirector.stair_choose(direction)


# --- Một khung giờ -----------------------------------------------------------

func _act_slot() -> void:
	var state: GameState = Game.state
	var key: int = _key()
	if _met_day != state.clock.day:
		_met_day = state.clock.day
		_met_today.clear()
	_answer_calls()
	if _key() != key or _busy():
		return
	_try_pay_tuition()
	_eat()
	if _key() != key or _busy():
		return
	var slot: int = state.clock.slot
	var sim: LifeSim = StudentLife.sim
	if slot == GameClock.Slot.NIGHT:
		_go_home()
		if _key() == key and not _busy():
			_do("ngu")
		return
	if not sim.class_now().is_empty():
		_go("lecture_hall")
		if _key() == key and not _busy():
			_do("di_hoc")
		return
	if strategy == FOLLOW_K:
		_seek("k")
		if _key() != key or _busy():
			return
	if _stat(PlayerStats.Stat.STAMINA) < TIRED_STAMINA:
		_go_home()
		if _key() == key and not _busy():
			_do("ngu" if slot == GameClock.Slot.EVENING else "nghi")
		return
	_work_or_study(slot, key)


func _work_or_study(slot: int, key: int) -> void:
	var state: GameState = Game.state
	var flags: FlagStore = state.flags
	var can_shift: bool = state.life.shifts_today < StudentLife.catalog.economy.max_shifts_per_day
	var has_job: bool = flags.get_flag("lam_them_quan") == 1
	# Chưa có việc: ghé quán từ ngày 3 (đoạn xin việc tự chạy khi vào quán).
	if not has_job and state.clock.day >= 3 and slot != GameClock.Slot.NIGHT:
		_go("food_shop")
		if _key() != key or _busy():
			return
		has_job = flags.get_flag("lam_them_quan") == 1
	var flyer_job: bool = flags.get_flag("nhan_viec_to_roi") == 1 and state.clock.get_week() >= 3
	if strategy == FOLLOW_K and flyer_job and can_shift:
		_go("lecture_hall")
		if _key() == key and not _busy():
			_do("phat_to_roi")
		return
	if slot == GameClock.Slot.EVENING:
		if has_job and can_shift and not (strategy == STUDY and Tuition.is_paid(state)):
			_go("food_shop")
			if _key() == key and not _busy():
				_do("bung_ca_phe")
			return
		if strategy == STUDY:
			_go("library")
			if _key() == key and not _busy():
				_do("tu_hoc")
			return
		_go_home()
		if _key() == key and not _busy():
			_do("ngu")
		return
	if strategy != STUDY and has_job and can_shift:
		_go("food_shop")
		if _key() == key and not _busy():
			_do("lam_quan_com")
		return
	_go("library")
	if _key() == key and not _busy():
		_do("tu_hoc")


func _do(action_id: String) -> void:
	var key: int = _key()
	var result: Dictionary = StudentLife.perform_action(action_id)
	if result.get("ok", false) and (_key() != key or _busy() or EventDirector.has_pending()):
		return
	# Không làm được (hoặc không tốn giờ): nghỉ cho qua khung, cùng lắm thì tua 1 khung.
	fallbacks += 1
	var fallback: Dictionary = StudentLife.perform_action("nghi")
	if not fallback.get("ok", false) or _key() == key:
		Game.advance_time()


func _go(place: String) -> void:
	if EventDirector.current_place != place:
		EventDirector.enter_area(place)
		settle()
	_meet_here()


func _go_home() -> void:
	if EventDirector.current_place != "ktx_room":
		_go("ktx_hallway")
		if _busy():
			return
		_go("ktx_room")
	else:
		_meet_here()


## Gặp mỗi NPC ở nơi hiện tại một lần mỗi ngày.
func _meet_here() -> void:
	var key: int = _key()
	for entry: Dictionary in EventDirector.npcs_at(EventDirector.current_place):
		var npc: NpcData = entry["npc"]
		if _met_today.has(npc.id):
			continue
		_met_today[npc.id] = true
		if EventDirector.interact(npc.id):
			settle()
		if _key() != key or _busy():
			return


## Chủ động đi tìm một NPC (chiến lược Theo K.).
func _seek(npc_id: String) -> void:
	if _met_today.has(npc_id):
		return
	var npc: NpcData = EventDirector.npcs.get(npc_id, null) as NpcData
	if npc == null:
		return
	var info: Dictionary = NpcSchedule.resolve(npc, Game.state)
	if info.is_empty() or str(info["place"]).is_empty():
		return
	_go(str(info["place"]))


func _answer_calls() -> void:
	for contact: String in Game.state.story.pending_calls.duplicate():
		EventDirector.phone_call(contact)
		settle()


func _try_pay_tuition() -> void:
	var state: GameState = Game.state
	if Tuition.is_paid(state):
		return
	var due: int = Tuition.amount_due(state, StudentLife.catalog.economy)
	if state.stats.get_money() >= due + TUITION_RESERVE:
		StudentLife.pay_tuition()


func _eat() -> void:
	if _stat(PlayerStats.Stat.HUNGER) >= EAT_BELOW:
		return
	var state: GameState = Game.state
	var comfortable: bool = Tuition.is_paid(state) and state.stats.get_money() > 400000
	var shop: String = "may_ban_nuoc"
	var item: String = "mi_goi"
	if comfortable and state.clock.slot != GameClock.Slot.NIGHT:
		shop = "quay_quan"
		item = "com_tam"
	_go("food_shop" if shop == "quay_quan" else "ktx_hallway")
	if _busy():
		return
	for _i in 6:
		if _stat(PlayerStats.Stat.HUNGER) >= FULL_HUNGER:
			return
		if not StudentLife.buy_item(shop, item).get("ok", false):
			return


# --- Tiện ích ----------------------------------------------------------------

func _finished(state: GameState) -> bool:
	return state.flags.get_flag("mvp_hoan_thanh") == 1 and not DialogueSystem.is_active()


func _busy() -> bool:
	return DialogueSystem.is_active() or AnomalyDirector.loop.active or AnomalyDirector.pending_start \
			or EventDirector.has_pending()


func _key() -> int:
	return Game.state.clock.day * 4 + Game.state.clock.slot


func _stat(which: int) -> int:
	return Game.state.stats.get_stat(which)
