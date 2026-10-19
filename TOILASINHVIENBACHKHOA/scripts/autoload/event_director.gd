extends Node
## EventDirector (bước 5) — sự kiện tự kích (storylet), NPC theo lịch, nhiệm vụ, tin nhắn, cuộc gọi.
## Sự kiện = node hội thoại có @trigger (xem docs/ARCHITECTURE.md mục "Bước 5").
## Autoload: không khai báo class_name. Đăng ký SAU StudentLife (để new_day của StudentLife chạy trước).

signal messages_changed
signal quests_changed
signal calls_changed

const NPC_IDS: Array[String] = [
	"minh", "chu_quan", "k", "tien_boi", "thu_khoa", "giang_vien", "tuan", "khoa",
]
const QUEST_IDS: Array[String] = [
	"q_hoc_phi", "q_viec_lam", "q_quy_phong", "q_minh", "q_truyen_thuyet",
]
## Người gửi tin nhắn / danh bạ không phải NPC trên bản đồ.
const CONTACT_NAMES: Dictionary = {
	"me": "Mẹ",
	"nhom_lop": "Nhóm lớp",
	"bql_ktx": "Ban quản lý KTX",
}
const AREA_IDS: Array[String] = ["ktx_room", "ktx_hallway", "lecture_hall", "library", "food_shop"]

var npcs: Dictionary = {}  # id -> NpcData
var quests: Array[QuestData] = []

var _queue: Array[String] = []
var _blockers: Dictionary = {}
var _indexed_library: DialogueLibrary = null
var _triggered: Array[Dictionary] = []
var _bound_flags: FlagStore = null
var _sleep_pending: bool = false
var _running_event: String = ""
## Nơi người chơi đang ở (bước 2 cập nhật khi chuyển khu; LifeUI tạm cập nhật khi chọn nơi).
var current_place: String = "ktx_room"


func _ready() -> void:
	for id: String in NPC_IDS:
		var npc: NpcData = load("res://data/npcs/%s.tres" % id) as NpcData
		if npc != null:
			npcs[id] = npc
	for id: String in QUEST_IDS:
		var quest: QuestData = load("res://data/quests/%s.tres" % id) as QuestData
		if quest != null:
			quests.append(quest)
	Game.state_replaced.connect(_on_state_replaced)
	Game.new_day.connect(_on_new_day)
	Game.time_changed.connect(_on_time_changed)
	DialogueSystem.dialogue_finished.connect(_on_dialogue_finished)
	StudentLife.add_sleep_interrupter(_on_sleep)
	_register_dialogue_hooks()


func _exit_tree() -> void:
	for variable: String in ["quest.", "npc_here."]:
		DialogueCondition.unregister_variable(variable)


func _process(_delta: float) -> void:
	if not Game.has_active_game() or not _blockers.is_empty() or DialogueSystem.is_active():
		return
	while not _queue.is_empty():
		var node_id: String = _queue.pop_front()
		if _start_event(node_id, true):
			return
	if _sleep_pending:
		_sleep_pending = false
		if StudentLife.sim.is_sleep_interrupted():
			StudentLife.complete_sleep()


# --- API ------------------------------------------------------------------

## Chặn chạy sự kiện tự động (vd. màn tổng kết ngày đang mở).
func block(key: String) -> void:
	_blockers[key] = true


func unblock(key: String) -> void:
	_blockers.erase(key)


## Nói chuyện với NPC/vật: sự kiện @trigger interact <id> ưu tiên cao nhất, không có thì hội thoại mặc định.
func interact(target_id: String) -> bool:
	if not Game.has_active_game() or DialogueSystem.is_active():
		return false
	var story: StoryState = Game.state.story
	if npcs.has(target_id) and story.meet(target_id):
		messages_changed.emit()
	var events: Array[String] = select("interact", target_id)
	if not events.is_empty():
		return _start_event(events[0], false)
	var npc: NpcData = npcs.get(target_id, null) as NpcData
	if npc != null and not npc.default_dialogue.is_empty():
		return DialogueSystem.start(npc.default_dialogue)
	return false


## Bước 2 gọi sau khi chuyển khu xong (LifeUI tạm gọi khi chọn nơi).
func enter_area(area_id: String) -> void:
	current_place = area_id
	_enqueue(select("enter_area", area_id))


## Nghe/gọi điện trong điện thoại (QĐ-5.3 = A: chỉ cuộc gọi theo kịch bản).
func phone_call(contact_id: String) -> bool:
	var story: StoryState = Game.state.story
	story.pending_calls.erase(contact_id)
	calls_changed.emit()
	var events: Array[String] = select("phone_call", contact_id)
	if events.is_empty():
		return false
	return _start_event(events[0], false)


func has_call_event(contact_id: String) -> bool:
	return not select("phone_call", contact_id).is_empty()


func select(trigger: String, arg: String = "") -> Array[String]:
	if not Game.has_active_game():
		return []
	return EventSelector.select(_triggered_nodes(), trigger, arg, Game.state, Game.state.story)


## NPC đang ở một nơi: [{npc: NpcData, info: {place, anchor, behavior}}].
func npcs_at(place_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not Game.has_active_game():
		return result
	for id: String in NPC_IDS:
		var npc: NpcData = npcs.get(id, null) as NpcData
		if npc == null:
			continue
		var info: Dictionary = NpcSchedule.resolve(npc, Game.state)
		if not info.is_empty() and info["place"] == place_id:
			result.append({"npc": npc, "info": info})
	return result


func contact_name(contact_id: String) -> String:
	if CONTACT_NAMES.has(contact_id):
		return str(CONTACT_NAMES[contact_id])
	return DialogueSystem.display_name_of(contact_id)


func get_quest(quest_id: String) -> QuestData:
	for quest: QuestData in quests:
		if quest.id == quest_id:
			return quest
	return null


## Đánh giá lại nhiệm vụ (tự bắt đầu / tự xong) và báo toast.
func refresh_quests() -> void:
	if not Game.has_active_game():
		return
	var events: Array[Dictionary] = QuestLog.evaluate(Game.state.story, quests, Game.state)
	for event: Dictionary in events:
		var quest: QuestData = event["quest"]
		if event["kind"] == "started":
			Toast.show_message("Nhiệm vụ mới: " + quest.title)
		else:
			Toast.show_message("Hoàn thành: " + quest.title)
	if not events.is_empty():
		quests_changed.emit()


# --- Nội bộ ---------------------------------------------------------------

func _triggered_nodes() -> Array[Dictionary]:
	var library: DialogueLibrary = DialogueSystem.get_library()
	if library != _indexed_library:
		_indexed_library = library
		_triggered = library.triggered_nodes()
	return _triggered


func _enqueue(node_ids: Array[String]) -> void:
	for node_id: String in node_ids:
		if not _queue.has(node_id) and node_id != _running_event:
			_queue.append(node_id)


## recheck: kiểm tra lại @when/@once/@daily lúc thật sự chạy (trạng thái có thể đã đổi).
func _start_event(node_id: String, recheck: bool) -> bool:
	var library: DialogueLibrary = DialogueSystem.get_library()
	if not library.has_dialogue(node_id):
		return false
	var node: Dictionary = library.get_dialogue(node_id)
	if recheck and not EventSelector.conditions_hold(node, Game.state, Game.state.story):
		return false
	Game.state.story.events_fired[node_id] = Game.state.clock.day
	_running_event = node_id
	if not DialogueSystem.start(node_id):
		_running_event = ""
		return false
	return true


func _on_dialogue_finished(_node_id: String) -> void:
	_running_event = ""
	refresh_quests()


func _on_state_replaced() -> void:
	_queue.clear()
	_blockers.clear()
	_sleep_pending = false
	_running_event = ""
	_bind_flags()
	refresh_quests()


func _on_new_day(_day: int) -> void:
	_enqueue(select("day_start"))
	refresh_quests()


func _on_time_changed(_day: int, _slot: int) -> void:
	_bind_flags()
	_enqueue(select("slot_start"))
	refresh_quests()


## Sự kiện @trigger sleep khớp → xếp hàng, giấc ngủ dừng ở khung Đêm; xong thì ngủ tiếp.
func _on_sleep(_context: Dictionary) -> bool:
	var events: Array[String] = select("sleep")
	if events.is_empty():
		return false
	_enqueue(events)
	_sleep_pending = true
	return true


func _bind_flags() -> void:
	var flags: FlagStore = Game.state.flags if Game.state != null else null
	if flags == _bound_flags:
		return
	if _bound_flags != null and _bound_flags.flag_changed.is_connected(_on_flag_changed):
		_bound_flags.flag_changed.disconnect(_on_flag_changed)
	_bound_flags = flags
	if flags != null:
		flags.flag_changed.connect(_on_flag_changed)


func _on_flag_changed(_key: String, _value: int) -> void:
	# Trong hội thoại: đợi xong mới đánh giá (tránh toast chen giữa câu thoại).
	if not DialogueSystem.is_active():
		refresh_quests()


## Lệnh + biến điều kiện của bước 5.
func _register_dialogue_hooks() -> void:
	DialogueSystem.register_command("message", func(args: PackedStringArray, state: GameState) -> void:
		if args.size() < 2:
			return
		state.story.add_message(args[0], args[1], state.clock.day, state.clock.slot)
		Toast.show_message("[Tin nhắn] %s: %s" % [contact_name(args[0]), args[1]], 3.5)
		messages_changed.emit()
	)
	DialogueSystem.register_command("ring", func(args: PackedStringArray, state: GameState) -> void:
		if args.is_empty() or state.story.pending_calls.has(args[0]):
			return
		state.story.pending_calls.append(args[0])
		Toast.show_message("[Cuộc gọi] %s đang gọi… (Tab → Danh bạ)" % contact_name(args[0]), 4.0)
		calls_changed.emit()
	)
	DialogueSystem.register_command("quest", func(args: PackedStringArray, state: GameState) -> void:
		if args.size() < 2:
			return
		var quest: QuestData = get_quest(args[1])
		if quest == null:
			push_warning("EventDirector: không có nhiệm vụ '%s'" % args[1])
			return
		match args[0]:
			"start":
				if QuestLog.start(state.story, quest, state.clock.day):
					Toast.show_message("Nhiệm vụ mới: " + quest.title)
			"done":
				if QuestLog.complete(state.story, quest.id):
					Toast.show_message("Hoàn thành: " + quest.title)
			"fail":
				if QuestLog.fail(state.story, quest.id):
					Toast.show_message("Thất bại: " + quest.title)
		quests_changed.emit()
	)
	DialogueSystem.register_command("npc_state", func(args: PackedStringArray, state: GameState) -> void:
		var npc: NpcData = npcs.get(args[0], null) as NpcData if not args.is_empty() else null
		if npc != null and not npc.state_flag.is_empty() and args.size() >= 2:
			state.flags.set_flag(npc.state_flag, args[1].to_int())
	)
	DialogueSystem.register_command("meet", func(args: PackedStringArray, state: GameState) -> void:
		if not args.is_empty() and state.story.meet(args[0]):
			messages_changed.emit()
	)
	DialogueCondition.register_variable("quest.", func(variable: String, state: GameState) -> int:
		return state.story.quest_state(variable.substr(6))
	)
	DialogueCondition.register_variable("npc_here.", func(variable: String, state: GameState) -> int:
		var npc: NpcData = npcs.get(variable.substr(9), null) as NpcData
		if npc == null:
			return 0
		var info: Dictionary = NpcSchedule.resolve(npc, state)
		return 1 if not info.is_empty() and info["place"] == current_place else 0
	)

