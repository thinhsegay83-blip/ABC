extends "res://tests/test_case.gd"
## Bot chơi thử trọn MVP (bước 7): 3 chiến lược × 3 chế độ, dùng autoload + nội dung thật.
## Mỗi ván phải tới được màn "Còn tiếp…" ở Đêm ngày 28, chạy đủ các beat bắt buộc.

const Bot: GDScript = preload("res://tests/mvp_bot.gd")
const TEST_SAVE_DIR: String = "user://test_saves_bot/"
const DIFFICULTIES: Array[String] = ["easy", "hard", "extreme"]
const DIFFICULTY_NAMES: Dictionary = {"easy": "Dễ", "hard": "Khó", "extreme": "Cực khó"}
const CLIMAX_NODES: Array[String] = ["t4_cao_trao_dem", "t4_cao_trao_ngu"]

var _old_save_dir: String = ""


func before_each() -> void:
	_old_save_dir = SaveSystem.save_dir
	SaveSystem.save_dir = TEST_SAVE_DIR


func after_each() -> void:
	Game.end_game()
	SaveSystem.save_dir = _old_save_dir
	var dir: DirAccess = DirAccess.open(TEST_SAVE_DIR)
	if dir != null:
		for file_name: String in dir.get_files():
			dir.remove(file_name)


func test_strategy_study() -> void:
	_run_strategy(Bot.STUDY, "A", 0)


func test_strategy_work() -> void:
	_run_strategy(Bot.WORK, "B", 0)


func test_strategy_follow_k() -> void:
	_run_strategy(Bot.FOLLOW_K, "A", 2)


func _run_strategy(strategy: String, ktx: String, mistakes: int) -> void:
	var required: Array[String] = _required_beats()
	assert_true(required.size() >= 5, "có đủ beat @required trong nội dung")
	for i in DIFFICULTIES.size():
		var difficulty: String = DIFFICULTIES[i]
		var bot: RefCounted = Bot.new(strategy, ktx, mistakes)
		var state: GameState = bot.play(difficulty, 4242 + i)
		var label: String = "%s/%s" % [bot.strategy_name(), DIFFICULTY_NAMES[difficulty]]
		assert_eq(bot.stuck, "", label + ": bot bị kẹt")
		assert_eq(bot.fallbacks, 0, label + ": có hành động không làm được")
		var flags: FlagStore = state.flags
		assert_eq(flags.get_flag("mvp_hoan_thanh"), 1, label + ": tới màn kết thúc")
		assert_eq(flags.get_flag("thoat_cau_thang"), 1, label + ": thoát cầu thang")
		assert_eq(flags.get_flag("sys_cao_trao"), 1, label + ": có cao trào")
		assert_eq(state.clock.day, 28, label + ": cao trào đúng ngày 28")
		assert_true(bot.events_seen.has("to_be_continued"), label + ": có sự kiện to_be_continued")
		assert_eq(flags.get_flag("ktx_khu"), 1 if ktx == "A" else 2, label + ": lựa chọn KTX")
		for node_id: String in required:
			if CLIMAX_NODES.has(node_id):
				continue
			assert_true(state.story.events_fired.has(node_id), "%s: beat bắt buộc '%s' chưa chạy" % [label, node_id])
		assert_true(CLIMAX_NODES.any(func(id: String) -> bool: return state.story.events_fired.has(id)),
				label + ": cao trào chạy qua Đêm hoặc khi ngủ")
		assert_eq(flags.get_flag("sys_k_moi"), 1, label + ": K. mời việc (trực tiếp hoặc dự phòng)")
		assert_eq(flags.get_flag("radar_lan_dau"), 1, label + ": radar lần đầu (dự phòng ngày 19)")
		assert_eq(flags.get_flag("lam_them_quan"), 1, label + ": xin được việc ở quán")
		assert_eq(flags.get_flag("da_gop_quy"), 1, label + ": góp quỹ phòng")
		assert_true(flags.get_flag("minh_trang_thai") >= 3, label + ": Minh tới giai đoạn úp mặt")
		if strategy == Bot.FOLLOW_K:
			assert_true(flags.get_flag("nhan_viec_to_roi") >= 1, label + ": nhận việc của K.")
			assert_true(flags.get_flag(StoryVars.K_FLAG) > 0, label + ": có dính líu K.")
			assert_eq(flags.get_flag("canh_bao_minh"), 0, label + ": không cảnh báo Minh")
		else:
			assert_eq(flags.get_flag("nhan_viec_to_roi"), 0, label + ": không nhận việc của K.")
			assert_eq(flags.get_flag("canh_bao_minh"), 1, label + ": cảnh báo Minh")
		_check_balance_intent(strategy, difficulty, state, bot, label)
		print("    %-9s %-8s tiền %12s · %s · Trí tuệ %3d · dính líu K. %3d · %d câu thoại · %d lựa chọn · %d bước cầu thang · ngất/kiệt sức %d" % [
			bot.strategy_name(), DIFFICULTY_NAMES[difficulty], MoneyFormat.format_vnd(state.stats.get_money()),
			_tuition_short(state), state.stats.get_stat(PlayerStats.Stat.KNOWLEDGE),
			flags.get_flag(StoryVars.K_FLAG), bot.lines_seen, bot.choices_made.size(), bot.loop_choices, bot.collapses,
		])
		Game.end_game()


## Ý đồ cân bằng (BUOC_7 mục 3.7 / BALANCE.md). Lệch → test báo đỏ kèm số liệu; KHÔNG tự chỉnh giá.
func _check_balance_intent(strategy: String, difficulty: String, state: GameState, bot: RefCounted, label: String) -> void:
	var paid: bool = Tuition.is_paid(state)
	var late: bool = Tuition.is_late(state)
	var money: String = MoneyFormat.format_vnd(state.stats.get_money())
	match [strategy, difficulty]:
		[Bot.WORK, "easy"]:
			assert_true(paid and not late, label + ": nên đóng kịp hạn chính (tiền cuối %s)" % money)
		[Bot.WORK, "hard"]:
			assert_true(paid and late, label + ": nên hụt hạn chính nhưng đóng được khi gia hạn (tiền cuối %s)" % money)
		[Bot.WORK, "extreme"]:
			assert_false(paid, label + ": không nhận việc K. thì không đóng nổi tới ngày 28 (tiền cuối %s)" % money)
		[Bot.FOLLOW_K, "extreme"]:
			assert_true(paid, label + ": theo K. thì đóng được trong gia hạn (tiền cuối %s)" % money)
	if strategy == Bot.STUDY and difficulty != "extreme":
		assert_true(bot.collapses <= 2, label + ": Chăm học không nên ngất/kiệt sức quá 2 lần")


func _required_beats() -> Array[String]:
	var result: Array[String] = []
	for node: Dictionary in DialogueSystem.get_library().triggered_nodes():
		if not ((node["meta"] as Dictionary).get("required", []) as Array).is_empty():
			result.append(str(node["id"]))
	return result


static func _tuition_short(state: GameState) -> String:
	if not Tuition.is_paid(state):
		return "học phí CHƯA đóng"
	return "học phí trễ hạn (gia hạn)" if Tuition.is_late(state) else "học phí đúng hạn"
