extends "res://tests/test_case.gd"
## Lịch nội dung tuần 1–4 (bước 7): beat bắt buộc, cao trào ngày 28, truyền thuyết tuần 2, màn kết thúc.
## Dùng thư viện nội dung thật (content/dialogue/) + biến điều kiện do autoload đăng ký.

const GameStateScript: GDScript = preload("res://scripts/core/game_state.gd")
## Cờ do code đặt (không qua `~ set`): học phí, quỹ phòng, dính líu K., vòng lặp, hành động, trạng thái NPC.
const CODE_SET_FLAGS: Array[String] = [
	"da_dong_hoc_phi", "hoc_phi_tre_han", "hoc_phi_qua_han", "da_gop_quy", "quy_phong",
	"sys_quy_phong_ngay_gop", "dinh_lieu_k", "sys_cau_thang_da_vao", "thoat_cau_thang",
	"radar_lan_dau", "mvp_hoan_thanh", "lam_them_quan", "nhan_viec_to_roi", "minh_trang_thai",
]
## node → ngày @required (beat phải chạy, quá hạn thì chạy bù).
const REQUIRED: Dictionary = {
	"intro_mo_dau": 1, "t1_gap_minh": 1, "t2_to_roi_bang_tin": 8,
	"t3_minh_tham_quang": 16, "t4_minh_up_mat": 24, "t4_cao_trao_dem": 28,
}

var library: DialogueLibrary
var nodes: Array[Dictionary]
var state: GameState


func before_each() -> void:
	var dialogue: Node = (Engine.get_main_loop() as SceneTree).root.get_node("DialogueSystem")
	library = DialogueLibrary.load_dir(DialogueLibrary.DEFAULT_DIR, dialogue.command_names())
	nodes = library.triggered_nodes()
	state = GameStateScript.new()
	state.setup_new_game(load("res://data/difficulty_hard.tres") as DifficultyConfig)


func _select(trigger: String, arg: String = "") -> Array[String]:
	return EventSelector.select(nodes, trigger, arg, state, state.story)


func _node(node_id: String) -> Dictionary:
	return library.get_dialogue(node_id) if library.has_dialogue(node_id) else {}


func test_required_beats_declared() -> void:
	for node_id: String in REQUIRED.keys():
		var node: Dictionary = _node(node_id)
		assert_false(node.is_empty(), "thiếu node " + node_id)
		if node.is_empty():
			continue
		var values: Array = (node["meta"] as Dictionary).get("required", [])
		assert_eq(values.size(), 1, node_id + ": có @required")
		if values.size() == 1:
			assert_eq(str(values[0]).to_int(), int(REQUIRED[node_id]), node_id + ": ngày @required")
	var declared: int = 0
	for node: Dictionary in nodes:
		if not ((node["meta"] as Dictionary).get("required", []) as Array).is_empty():
			declared += 1
			assert_true(REQUIRED.has(str(node["id"])), "beat bắt buộc lạ: " + str(node["id"]))
	assert_eq(declared, REQUIRED.size())


func test_day_one_order() -> void:
	var events: Array[String] = _select("day_start")
	assert_true(events.size() >= 2)
	if events.size() >= 2:
		assert_eq(events[0], "intro_mo_dau", "mở đầu chạy trước")
		assert_eq(events[1], "t1_gap_minh")


func test_intro_has_fiction_note_and_ktx_choice() -> void:
	var node: Dictionary = _node("intro_mo_dau")
	var text: String = ""
	var options: Array[String] = []
	for entry: Dictionary in node.get("entries", []):
		if entry["type"] == "line":
			text += str(entry["text"]) + "\n"
		elif entry["type"] == "choices":
			for option: Dictionary in entry["options"]:
				options.append(str(option["target"]))
	assert_true(text.contains("hư cấu"), "mở đầu có dòng tuyên bố hư cấu")
	assert_eq(options, ["intro_khu_a", "intro_khu_b"] as Array[String])


func test_legend_from_week_two() -> void:
	state.clock.set_time(9, GameClock.Slot.EVENING)
	assert_false(_select("interact", "tien_boi").has("tien_boi_truyen_thuyet"), "ngày 9 chưa kể")
	state.clock.set_time(10, GameClock.Slot.EVENING)
	assert_true(_select("interact", "tien_boi").has("tien_boi_truyen_thuyet"), "từ ngày 10 kể")
	state.clock.set_time(21, GameClock.Slot.MORNING)
	assert_true(_select("day_start").has("t3_truyen_thuyet_du_phong"), "chưa nghe → dự phòng ngày 21")
	state.flags.set_flag("nghe_truyen_thuyet", 1)
	assert_false(_select("day_start").has("t3_truyen_thuyet_du_phong"))


func test_climax_night_or_sleep_day_28() -> void:
	state.clock.set_time(27, GameClock.Slot.NIGHT)
	assert_false(_select("slot_start").has("t4_cao_trao_dem"))
	assert_false(_select("sleep").has("t4_cao_trao_ngu"))
	state.clock.set_time(28, GameClock.Slot.EVENING)
	assert_true(_select("sleep").has("t4_cao_trao_ngu"), "ngủ sớm Tối ngày 28 vẫn vào cao trào")
	state.clock.set_time(28, GameClock.Slot.NIGHT)
	assert_true(_select("slot_start").has("t4_cao_trao_dem"))
	state.flags.set_flag("sys_cao_trao", 1)
	assert_false(_select("slot_start").has("t4_cao_trao_dem"), "chỉ một lần")
	assert_false(_select("sleep").has("t4_cao_trao_ngu"))


func test_climax_starts_stair_loop() -> void:
	var commands: Array[String] = _commands_of("t4_cao_trao_noi_dung")
	assert_true(commands.has("set sys_cao_trao 1"))
	assert_true(commands.has("night_wake"))
	assert_eq(commands[commands.size() - 1], "stair_loop start", "vòng lặp là lệnh cuối")


func test_ending_after_escape() -> void:
	state.flags.set_flag("thoat_cau_thang", 1)
	assert_true(_select("flag_set", "thoat_cau_thang").has("t4_thoat_cau_thang"))
	var commands: Array[String] = _commands_of("t4_thoat_cau_thang")
	assert_true(commands.has("set mvp_hoan_thanh 1"))
	assert_true(commands.has("emit to_be_continued"))


func test_demo_content_not_loaded() -> void:
	for node_id: String in library.content.order:
		assert_false(node_id.begins_with("demo_"), "demo vẫn bị nạp: " + node_id)


func test_every_week_has_scheduled_beats() -> void:
	var per_week: Dictionary = {1: 0, 2: 0, 3: 0, 4: 0}
	for day in range(1, 29):
		for slot: int in [GameClock.Slot.MORNING, GameClock.Slot.EVENING, GameClock.Slot.NIGHT]:
			state.clock.set_time(day, slot)
			var count: int = _select("day_start").size() + _select("slot_start").size()
			per_week[state.clock.get_week()] = int(per_week[state.clock.get_week()]) + count
	for week: int in per_week.keys():
		assert_true(int(per_week[week]) > 0, "tuần %d không có beat theo lịch" % week)


## BUOC_7 3.9: cờ được đọc ở @when / [if] / need / lịch NPC / nhiệm vụ phải có nơi đặt.
func test_read_flags_are_set_somewhere() -> void:
	var regex: RegEx = RegEx.create_from_string("flag\\.([a-z0-9_]+)")
	var read_text: String = ""
	var set_flags: Array[String] = CODE_SET_FLAGS.duplicate()
	for node_id: String in library.content.order:
		var node: Dictionary = library.content.nodes[node_id]
		read_text += str((node["meta"] as Dictionary).get("when", "")) + "\n"
		for entry: Dictionary in node["entries"]:
			read_text += str(entry.get("cond", "")) + "\n"
			if entry["type"] == "choices":
				for option: Dictionary in entry["options"]:
					read_text += str(option["cond"]) + " " + str(option["need"]) + "\n"
			elif entry["type"] == "cmd" and str(entry["name"]) in ["set", "add"]:
				set_flags.append(str((entry["args"] as PackedStringArray)[0]))
	var director: Node = (Engine.get_main_loop() as SceneTree).root.get_node("EventDirector")
	for npc: NpcData in director.npcs.values():
		for item: Dictionary in npc.schedule:
			read_text += str(item.get("condition", "")) + "\n"
	for quest: QuestData in director.quests:
		read_text += quest.start_condition + "\n"
		for step: Dictionary in quest.steps:
			read_text += str(step["done_condition"]) + "\n"
	var unset: Array[String] = []
	for m: RegExMatch in regex.search_all(read_text):
		var flag: String = m.get_string(1)
		if not set_flags.has(flag) and not unset.has(flag):
			unset.append(flag)
	assert_eq(unset, [] as Array[String], "cờ chỉ đọc mà không bao giờ được đặt")


func _commands_of(node_id: String) -> Array[String]:
	var result: Array[String] = []
	for entry: Dictionary in _node(node_id).get("entries", []):
		if entry["type"] == "cmd":
			result.append((str(entry["name"]) + " " + " ".join(entry["args"])).strip_edges())
	return result
