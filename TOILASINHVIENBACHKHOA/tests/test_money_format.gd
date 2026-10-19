extends "res://tests/test_case.gd"

const MoneyFormatScript: GDScript = preload("res://scripts/core/money_format.gd")


func test_formats() -> void:
	assert_eq(MoneyFormatScript.format_vnd(0), "0 đ")
	assert_eq(MoneyFormatScript.format_vnd(999), "999 đ")
	assert_eq(MoneyFormatScript.format_vnd(1000), "1.000 đ")
	assert_eq(MoneyFormatScript.format_vnd(1500000), "1.500.000 đ")
	assert_eq(MoneyFormatScript.format_vnd(16000000), "16.000.000 đ")
	assert_eq(MoneyFormatScript.format_vnd(-250000), "-250.000 đ")
	assert_eq(MoneyFormatScript.format_vnd(-999), "-999 đ")
