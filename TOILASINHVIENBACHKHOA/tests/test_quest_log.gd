extends "res://tests/test_case.gd"

const Fixture: GDScript = preload("res://tests/life_fixture.gd")
const GameStateScript: GDScript = preload("res://scripts/core/game_state.gd")

var fx: Object
var quests: Array[QuestData] = []


func before_each() -> void:
	fx = Fixture.new("hard")
	quests.clear()
	for id: String in ["q_hoc_phi", "q_viec_lam", "q_minh", "q_truyen_thuyet"]:
		quests.append(load("res://data/quests/%s.tres" % id) as QuestData)


func test_auto_start_and_done() -> void:
	var events: Array[Dictionary] = QuestLog.evaluate(fx.state.story, quests, fx.state)
	assert_eq(fx.state.story.quest_state("q_hoc_phi"), QuestLog.ACTIVE)
	assert_eq(fx.state.story.quest_state("q_minh"), QuestLog.NOT_STARTED)
	assert_eq(events.size(), 2)
	fx.state.flags.set_flag("lam_them_quan", 1)
	QuestLog.evaluate(fx.state.story, quests, fx.state)
	assert_eq(fx.state.story.quest_state("q_viec_lam"), QuestLog.DONE)


func test_multi_step() -> void:
	fx.state.flags.set_flag("minh_trang_thai", 2)
	QuestLog.evaluate(fx.state.story, quests, fx.state)
	var minh: QuestData = quests[2]
	assert_eq(QuestLog.current_step_text(fx.state.story, minh), "Minh hay ra ngoài lúc đêm…")
	fx.state.flags.set_flag("thay_minh_ra_ngoai", 1)
	fx.state.flags.set_flag("canh_bao_minh", 1)
	QuestLog.evaluate(fx.state.story, quests, fx.state)
	assert_eq(fx.state.story.quest_state("q_minh"), QuestLog.DONE)


func test_deadline_and_extension() -> void:
	var tuition: QuestData = quests[0]
	assert_eq(QuestLog.days_left(tuition, fx.state), 13)
	fx.state.flags.set_flag("hoc_phi_tre_han", 1)
	assert_eq(QuestLog.days_left(tuition, fx.state), 27)


func test_commands_and_save() -> void:
	var legend: QuestData = quests[3]
	assert_true(QuestLog.start(fx.state.story, legend, 1))
	assert_true(QuestLog.fail(fx.state.story, legend.id))
	var copy: GameState = GameStateScript.new()
	copy.from_dict(json_round_trip(fx.state.to_dict()))
	assert_eq(copy.story.quest_state(legend.id), QuestLog.FAILED)
	assert_eq(typeof((copy.story.quests[legend.id] as Dictionary)["state"]), TYPE_INT)
