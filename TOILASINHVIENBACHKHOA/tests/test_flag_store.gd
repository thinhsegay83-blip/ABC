extends "res://tests/test_case.gd"

const FlagStoreScript: GDScript = preload("res://scripts/core/flag_store.gd")

var flags: FlagStore


func before_each() -> void:
	flags = FlagStoreScript.new()


func test_default_value() -> void:
	assert_false(flags.has_flag("da_gop_quy"))
	assert_eq(flags.get_flag("da_gop_quy"), 0)
	assert_eq(flags.get_flag("da_gop_quy", 7), 7)


func test_set_get_clear() -> void:
	flags.set_flag("minh_trang_thai", 2)
	assert_true(flags.has_flag("minh_trang_thai"))
	assert_eq(flags.get_flag("minh_trang_thai"), 2)
	flags.clear()
	assert_false(flags.has_flag("minh_trang_thai"))


func test_dict_round_trip_through_json() -> void:
	flags.set_flag("ktx_khu", 2)
	flags.set_flag("thoat_cau_thang", 1)
	var copy: FlagStore = FlagStoreScript.new()
	copy.from_dict(json_round_trip(flags.to_dict()))
	assert_eq(copy.get_flag("ktx_khu"), 2)
	assert_eq(copy.get_flag("thoat_cau_thang"), 1)
