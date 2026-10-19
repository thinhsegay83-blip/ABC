extends "res://tests/test_case.gd"

const Runner: GDScript = preload("res://scripts/dialogue/dialogue_runner.gd")
const Library: GDScript = preload("res://scripts/dialogue/dialogue_library.gd")
const GameStateScript: GDScript = preload("res://scripts/core/game_state.gd")

const TEXT: String = """
== start
minh: Chào {player_name}, bạn có {money}.
minh: Câu ẩn [if flag.an == 1]
~ set gap 1
~ stat sanity -500
~ money -2000 "Phạt"
~ rel minh 5
~ emit su_kien a b
* Đi -> di [need money >= 999999 | Không đủ tiền]
* Ở lại -> o_lai
* Bí mật -> di [if flag.an == 1]

== o_lai
minh: Ở lại.
~ goto cuoi

== di
minh: Đi.

== cuoi
minh: Hết.

== vong
~ goto vong
"""

var state: GameState
var runner: DialogueRunner
var lines: Array[String] = []
var choices: Array = []
var events: Array[String] = []
var finished: Array[String] = []


func before_each() -> void:
	state = GameStateScript.new()
	state.player_name = "Phong"
	state.stats.set_money(1000)
	runner = Runner.new(Library.from_text(TEXT), state)
	lines.clear()
	choices = []
	events.clear()
	finished.clear()
	runner.line_shown.connect(func(e: Dictionary) -> void: lines.append(str(e["text"])))
	runner.choices_shown.connect(func(c: Array) -> void: choices = c)
	runner.event_emitted.connect(func(n: String, a: PackedStringArray) -> void: events.append(n + ":" + ",".join(a)))
	runner.finished.connect(func(id: String) -> void: finished.append(id))


## Lambda ở trên bắt self → bỏ runner để test ↔ runner không giữ nhau (rò rỉ lúc thoát).
func after_each() -> void:
	runner = null


func test_missing_node() -> void:
	assert_false(runner.start("khong_co"))


func test_full_flow() -> void:
	assert_true(runner.start("start"))
	assert_eq(lines, ["Chào Phong, bạn có 1.000 đ."] as Array[String])
	runner.advance()
	assert_eq(lines.size(), 1, "câu [if] sai bị bỏ")
	assert_eq(state.flags.get_flag("gap"), 1)
	assert_eq(state.stats.get_stat(PlayerStats.Stat.SANITY), 0, "kẹp 0")
	assert_eq(state.stats.get_money(), -1000, "tiền âm được")
	assert_eq(state.stats.get_relationship("minh"), 5)
	assert_eq(events, ["su_kien:a,b"] as Array[String])
	assert_eq(choices.size(), 2, "lựa chọn [if] sai bị ẩn")
	assert_false(choices[0]["enabled"])
	assert_eq(choices[0]["reason"], "Không đủ tiền")
	runner.choose(0)
	assert_eq(lines.size(), 1, "không chọn được lựa chọn khóa")
	runner.choose(1)
	assert_eq(lines[1], "Ở lại.")
	runner.advance()
	assert_eq(lines[2], "Hết.", "goto")
	runner.advance()
	assert_false(runner.is_running(), "kết thúc ngầm cuối node")
	assert_eq(finished, ["start"] as Array[String])


func test_infinite_loop_stops() -> void:
	runner.start("vong")
	assert_false(runner.is_running())
	assert_true(runner.errors.size() > 0)
