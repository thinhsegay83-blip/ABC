extends "res://tests/test_case.gd"
## Beat bắt buộc (bước 7): kiệt sức/ngất không tua qua Đêm ngày 28; beat quá hạn được chạy bù.

const Fixture: GDScript = preload("res://tests/life_fixture.gd")
const CLIMAX_KEY: int = 28 * 4 + GameClock.Slot.NIGHT

var fx: Object


func before_each() -> void:
	fx = Fixture.new("hard")
	fx.sim.time_barriers.append(CLIMAX_KEY)


func after_each() -> void:
	Game.end_game()


func test_mental_collapse_stops_at_climax() -> void:
	fx.walk_to(28, GameClock.Slot.AFTERNOON)
	fx.state.stats.set_stat(PlayerStats.Stat.SANITY, 0)
	assert_true(fx.sim.check_collapse())
	assert_eq(fx.state.clock.day, 28, "không ngủ li bì sang ngày 29")
	assert_eq(fx.state.clock.slot, GameClock.Slot.NIGHT, "dừng đúng Đêm ngày 28")
	assert_eq(fx.stat(PlayerStats.Stat.SANITY), 30, "vẫn hồi Sanity như thường")


func test_collapse_at_barrier_does_not_move() -> void:
	fx.walk_to(28, GameClock.Slot.NIGHT)
	fx.state.stats.set_stat(PlayerStats.Stat.SANITY, 0)
	assert_true(fx.sim.check_collapse())
	assert_eq(fx.sim.current_key(), CLIMAX_KEY)


func test_collapse_elsewhere_still_two_days() -> void:
	fx.walk_to(10, GameClock.Slot.AFTERNOON)
	fx.state.stats.set_stat(PlayerStats.Stat.SANITY, 0)
	assert_true(fx.sim.check_collapse())
	assert_eq(fx.state.clock.day, 12)
	assert_eq(fx.state.clock.slot, GameClock.Slot.MORNING)


func test_overdue_required_beats() -> void:
	Game.new_game("hard")
	var fired: Dictionary = Game.state.story.events_fired
	fired["intro_mo_dau"] = 1
	fired["t1_gap_minh"] = 1
	assert_false(EventDirector.overdue_required(8).has("t2_to_roi_bang_tin"), "đúng ngày chưa phải quá hạn")
	assert_true(EventDirector.overdue_required(9).has("t2_to_roi_bang_tin"), "qua ngày 8 chưa chạy → chạy bù")
	assert_false(EventDirector.overdue_required(9).has("intro_mo_dau"), "đã chạy thì thôi")
	var late: Array[String] = EventDirector.overdue_required(25)
	assert_true(late.has("t3_minh_tham_quang"))
	assert_true(late.has("t4_minh_up_mat"))
	assert_false(late.has("t4_cao_trao_dem"), "cao trào chưa quá hạn ở ngày 25")


func test_overdue_beat_ignores_when() -> void:
	Game.new_game("hard")
	EventDirector.pump()
	_read_all()
	# Bỏ lỡ ngày 16 (ví dụ tải save cũ): sang ngày 17 thì Minh vẫn "thăm quầng" — @when day == 16 bị bỏ qua.
	var state: GameState = Game.state
	state.story.events_fired.erase("t3_minh_tham_quang")
	state.clock.set_time(17, GameClock.Slot.MORNING)
	EventDirector._enqueue(EventDirector.overdue_required(17))
	assert_true(EventDirector.pump(), "beat quá hạn chạy được")
	_read_all()
	assert_true(state.story.events_fired.has("t3_minh_tham_quang"))
	assert_eq(state.flags.get_flag("minh_trang_thai"), 2)


## Đọc hết hội thoại đang mở (chọn lựa chọn đầu tiên bấm được).
func _read_all() -> void:
	var options: Array = []
	var capture: Callable = func(shown: Array) -> void: options.assign(shown)
	DialogueSystem.choices_shown.connect(capture)
	for _i in 500:
		while DialogueSystem.is_active():
			if options.is_empty():
				DialogueSystem.advance()
				continue
			var shown: Array = options.duplicate()
			options.clear()
			for option: Dictionary in shown:
				if option["enabled"]:
					DialogueSystem.choose(int(option["index"]))
					break
		if not EventDirector.pump():
			break
	DialogueSystem.choices_shown.disconnect(capture)
