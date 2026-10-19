extends SceneTree
## Bộ chạy test tự viết (không cần addon).
## Chạy: godot --headless --path . -s res://tests/run_tests.gd
## Lần đầu cần import trước: godot --headless --path . --import

const TEST_DIR: String = "res://tests/"


func _initialize() -> void:
	var passed: int = 0
	var failed: int = 0
	for file_name: String in _list_test_files():
		var script: GDScript = load(TEST_DIR + file_name) as GDScript
		if script == null:
			print("FAIL %s (không nạp được script)" % file_name)
			failed += 1
			continue
		var suite: Object = script.new()
		for method: Dictionary in suite.get_method_list():
			var method_name: String = str(method.get("name", ""))
			if not method_name.begins_with("test_"):
				continue
			suite.call("reset_results")
			suite.call("before_each")
			suite.call(method_name)
			suite.call("after_each")
			var failures: Array = suite.get("failures")
			var assert_count: int = int(suite.get("assert_count"))
			var label: String = "%s::%s" % [file_name.get_basename(), method_name]
			if failures.is_empty() and assert_count > 0:
				print("PASS %s" % label)
				passed += 1
			else:
				print("FAIL %s" % label)
				if assert_count == 0:
					print("    không có assert nào chạy (lỗi script?)")
				for failure: Variant in failures:
					print("    " + str(failure))
				failed += 1
	print("\nTổng: %d đạt, %d lỗi" % [passed, failed])
	quit(0 if failed == 0 else 1)


func _list_test_files() -> Array[String]:
	var files: Array[String] = []
	for file_name: String in DirAccess.get_files_at(TEST_DIR):
		if file_name.begins_with("test_") and file_name.ends_with(".gd") \
				and file_name != "test_case.gd":
			files.append(file_name)
	files.sort()
	return files
