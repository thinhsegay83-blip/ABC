extends "res://tests/test_case.gd"

const ReadLogScript: GDScript = preload("res://scripts/dialogue/read_log.gd")
const PATH: String = "user://test_read_log.cfg"


func after_each() -> void:
	if FileAccess.file_exists(PATH):
		DirAccess.remove_absolute(PATH)


func test_mark_save_load() -> void:
	var read_log: ReadLog = ReadLogScript.new()
	assert_false(read_log.is_read("a:0"))
	read_log.mark_read("a:0")
	assert_true(read_log.is_read("a:0"))
	read_log.save_to(PATH)
	var other: ReadLog = ReadLogScript.new()
	other.load_from(PATH)
	assert_true(other.is_read("a:0"))
	assert_false(other.is_read("a:1"))
