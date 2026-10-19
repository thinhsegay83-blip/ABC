extends RefCounted
## Dựng một ván + LifeSim cho test (không cần autoload). Không phải file test (không có tiền tố test_).

const GameStateScript: GDScript = preload("res://scripts/core/game_state.gd")
const LifeSimScript: GDScript = preload("res://scripts/life/life_sim.gd")
const LifeCatalogScript: GDScript = preload("res://scripts/life/life_catalog.gd")
const TimeDecayScript: GDScript = preload("res://scripts/data/time_decay_config.gd")

var state: GameState
var sim: LifeSim
var decay: TimeDecayConfig
var messages: Array[String] = []
var summaries: Array[Dictionary] = []


func _init(difficulty_id: String = "hard", schedule_seed: int = 12345) -> void:
	state = GameStateScript.new()
	state.setup_new_game(load("res://data/difficulty_%s.tres" % difficulty_id) as DifficultyConfig)
	decay = load("res://data/time_decay.tres") as TimeDecayConfig
	var catalog: LifeCatalog = LifeCatalogScript.load_default()
	sim = LifeSimScript.new(catalog, func() -> void: state.advance_time(decay))
	sim.rng.seed = 7
	sim.message_posted.connect(func(text: String) -> void: messages.append(text))
	sim.day_summary_ready.connect(func(s: Dictionary) -> void: summaries.append(s))
	sim.state = state
	sim.start_new_life(schedule_seed)
	sim.attach_clock(state.clock)


func stat(which: int) -> int:
	return state.stats.get_stat(which)


## Qua n khung giờ (như bấm "Qua khung giờ" trong debug).
func pass_slots(n: int) -> void:
	for _i in n:
		state.advance_time(decay)


## Tua tới (day, slot) bằng cách đi tuần tự từng khung, giữ Thể lực/Đói/Sanity đầy
## để các test không bị ảnh hưởng bởi đói lả.
func walk_to(day: int, slot: int) -> void:
	while state.clock.day * 4 + state.clock.slot < day * 4 + slot:
		state.stats.set_stat(PlayerStats.Stat.STAMINA, 100)
		state.stats.set_stat(PlayerStats.Stat.HUNGER, 100)
		state.stats.set_stat(PlayerStats.Stat.SANITY, 100)
		state.advance_time(decay)


## Ngày (>= start) đầu tiên có tiết ở khung bất kỳ: trả Vector2i(day, slot).
func first_class_from(start_day: int) -> Vector2i:
	for day in range(start_day, start_day + 14):
		for slot: int in [0, 1]:
			if not sim.class_at(day, slot).is_empty():
				return Vector2i(day, slot)
	return Vector2i(-1, -1)


func ledger_has(label: String) -> bool:
	for entry: Dictionary in state.life.ledger_today:
		if str(entry["label"]) == label:
			return true
	return false
