extends "res://tests/test_case.gd"

const GameClockScript: GDScript = preload("res://scripts/core/game_clock.gd")

var clock: GameClock


func before_each() -> void:
	clock = GameClockScript.new()


func test_starts_monday_morning() -> void:
	assert_eq(clock.day, 1)
	assert_eq(clock.slot, GameClock.Slot.MORNING)
	assert_eq(clock.get_week(), 1)
	assert_eq(clock.get_weekday(), 0)


func test_advance_through_slots() -> void:
	clock.advance()
	assert_eq(clock.slot, GameClock.Slot.AFTERNOON)
	clock.advance()
	clock.advance()
	assert_eq(clock.slot, GameClock.Slot.NIGHT)
	assert_eq(clock.day, 1)


func test_night_rolls_to_next_day_and_emits() -> void:
	var days: Array[int] = []
	clock.new_day.connect(func(d: int) -> void: days.append(d))
	for i in GameClock.SLOT_COUNT:
		clock.advance()
	assert_eq(clock.day, 2)
	assert_eq(clock.slot, GameClock.Slot.MORNING)
	assert_eq(days.size(), 1)
	assert_eq(days[0], 2)


func test_week_and_weekday() -> void:
	clock.set_time(7, GameClock.Slot.MORNING)
	assert_eq(clock.get_week(), 1)
	assert_eq(clock.get_weekday(), 6)
	clock.set_time(8, GameClock.Slot.MORNING)
	assert_eq(clock.get_week(), 2)
	assert_eq(clock.get_weekday(), 0)
	clock.set_time(28, GameClock.Slot.NIGHT)
	assert_eq(clock.get_week(), 4)


func test_set_time_clamps_and_no_new_day() -> void:
	var fired: Array[int] = [0]
	clock.new_day.connect(func(_d: int) -> void: fired[0] += 1)
	clock.set_time(0, 9)
	assert_eq(clock.day, 1)
	assert_eq(clock.slot, GameClock.Slot.NIGHT)
	assert_eq(fired[0], 0)


func test_names() -> void:
	assert_eq(GameClock.slot_display_name(GameClock.Slot.EVENING), "Tối")
	assert_eq(GameClock.weekday_display_name(6), "Chủ Nhật")


func test_dict_round_trip_through_json() -> void:
	clock.set_time(12, GameClock.Slot.EVENING)
	var copy: GameClock = GameClockScript.new()
	copy.from_dict(json_round_trip(clock.to_dict()))
	assert_eq(copy.day, 12)
	assert_eq(copy.slot, GameClock.Slot.EVENING)
