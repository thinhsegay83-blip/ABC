extends "res://tests/test_case.gd"


func after_each() -> void:
	SaveGate.clear()


func test_block_unblock() -> void:
	SaveGate.clear()
	assert_false(SaveGate.is_blocked())
	SaveGate.block("a")
	SaveGate.block("b")
	SaveGate.unblock("a")
	assert_true(SaveGate.is_blocked())
	SaveGate.unblock("b")
	assert_false(SaveGate.is_blocked())
	SaveGate.block("x")
	SaveGate.clear()
	assert_false(SaveGate.is_blocked())
