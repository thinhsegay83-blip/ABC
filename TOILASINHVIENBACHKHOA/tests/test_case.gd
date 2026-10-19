class_name TestCase
extends RefCounted
## Lớp cơ sở cho test tự viết (không dùng addon).
## Mỗi assert sai ghi một dòng vào `failures`; run_tests.gd đọc mảng này sau mỗi test.
## File test nên `extends "res://tests/test_case.gd"` (theo đường dẫn, không cần cache class_name).

## Lỗi của test đang chạy (run_tests.gd xóa trước mỗi test).
var failures: Array[String] = []
## Số assert đã gọi — runner dùng để phát hiện test dừng giữa chừng vì lỗi script.
var assert_count: int = 0


## Chạy trước mỗi test; lớp con ghi đè để tạo dữ liệu mới.
func before_each() -> void:
	pass


## Chạy sau mỗi test; lớp con ghi đè để dọn dẹp (xóa file, free Node…).
func after_each() -> void:
	pass


func reset_results() -> void:
	failures.clear()
	assert_count = 0


# --- Assert ---------------------------------------------------------------

## So sánh chặt cả kiểu: 5 (int) khác 5.0 (float) — để bắt lỗi JSON trả float.
## String và StringName được coi là cùng loại.
func assert_eq(actual: Variant, expected: Variant, msg: String = "") -> void:
	assert_count += 1
	if _values_equal(actual, expected):
		return
	var reason: String = "mong đợi %s, nhận được %s" % [_describe(expected), _describe(actual)]
	if typeof(actual) != typeof(expected):
		reason += " (khác kiểu: %s ≠ %s)" % [
			type_string(typeof(actual)), type_string(typeof(expected))
		]
	_fail(reason, msg)


## So sánh số thực có sai số cho phép.
func assert_almost_eq(
	actual: float, expected: float, epsilon: float = 0.0001, msg: String = ""
) -> void:
	assert_count += 1
	if absf(actual - expected) > epsilon:
		_fail("mong đợi %s ± %s, nhận được %s" % [expected, epsilon, actual], msg)


func assert_true(condition: bool, msg: String = "") -> void:
	assert_count += 1
	if not condition:
		_fail("mong đợi true, nhận được false", msg)


func assert_false(condition: bool, msg: String = "") -> void:
	assert_count += 1
	if condition:
		_fail("mong đợi false, nhận được true", msg)


func assert_null(value: Variant, msg: String = "") -> void:
	assert_count += 1
	if value != null:
		_fail("mong đợi null, nhận được %s" % _describe(value), msg)


func assert_not_null(value: Variant, msg: String = "") -> void:
	assert_count += 1
	if value == null:
		_fail("mong đợi khác null, nhận được null", msg)


# --- Tiện ích cho test ----------------------------------------------------

## Mô phỏng lưu/tải: Dictionary → chuỗi JSON → Dictionary (số thành float như save thật).
func json_round_trip(data: Dictionary) -> Dictionary:
	var parsed: Variant = JSON.parse_string(JSON.stringify(data))
	if parsed is Dictionary:
		return parsed
	_fail("JSON round-trip không trả về Dictionary", "json_round_trip")
	return {}


# --- Nội bộ ---------------------------------------------------------------

func _fail(reason: String, msg: String) -> void:
	var text: String = reason
	if not msg.is_empty():
		text = "%s: %s" % [msg, reason]
	var location: String = _caller_location()
	if not location.is_empty():
		text += " [%s]" % location
	failures.append(text)


## Dòng gọi assert trong file test. get_stack() rỗng khi không có debugger → bỏ qua.
func _caller_location() -> String:
	for frame: Dictionary in get_stack():
		var source: String = str(frame.get("source", ""))
		if source.is_empty() or source.ends_with("test_case.gd"):
			continue
		return "%s:%d" % [source.get_file(), int(frame.get("line", 0))]
	return ""


static func _values_equal(actual: Variant, expected: Variant) -> bool:
	var actual_type: int = typeof(actual)
	var expected_type: int = typeof(expected)
	if _is_string_type(actual_type) and _is_string_type(expected_type):
		return str(actual) == str(expected)
	if actual_type != expected_type:
		return false
	return actual == expected


static func _is_string_type(type: int) -> bool:
	return type == TYPE_STRING or type == TYPE_STRING_NAME


## var_to_str phân biệt được 5 và 5.0, chuỗi có ngoặc kép.
static func _describe(value: Variant) -> String:
	if typeof(value) == TYPE_OBJECT:
		return str(value)
	return var_to_str(value).replace("\n", " ")
