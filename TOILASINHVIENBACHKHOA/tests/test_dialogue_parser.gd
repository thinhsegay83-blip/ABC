extends "res://tests/test_case.gd"

const Parser: GDScript = preload("res://scripts/dialogue/dialogue_parser.gd")

const SAMPLE: String = """
# chú thích
== a_node
@trigger interact minh
@when day >= 2
@when flag.x == 1
minh: Xin chào: đây là dấu hai chấm.
minh (cuoi): Câu có [b]BBCode[/b]. [if stat.sanity > 10]
narrator: Gió thổi.
* Đồng ý -> b_node [need money >= 100 | Không đủ tiền]
* Từ chối -> c_node [if flag.x == 0]
~ set da_gop_quy 1
~ toast "Hai từ có dấu cách"

== b_node
player: Được.
"""


func test_parse_structure() -> void:
	var parsed: DialogueScript = Parser.parse(SAMPLE, "mau.dlg")
	assert_eq(parsed.errors.size(), 0, str(parsed.errors))
	var node: Dictionary = parsed.nodes["a_node"]
	assert_eq(node["meta"]["trigger"], ["interact minh"])
	assert_eq((node["meta"]["when"] as Array).size(), 2, "khóa metadata lặp")
	var entries: Array = node["entries"]
	assert_eq(entries[0]["text"], "Xin chào: đây là dấu hai chấm.")
	assert_eq(entries[0]["expression"], "thuong")
	assert_eq(entries[1]["expression"], "cuoi")
	assert_eq(entries[1]["cond"], "stat.sanity > 10")
	assert_eq(entries[1]["text"], "Câu có [b]BBCode[/b].")
	assert_eq(entries[2]["speaker"], "narrator")
	var choices: Array = entries[3]["options"]
	assert_eq(choices.size(), 2, "2 lựa chọn liền nhau = 1 nhóm")
	assert_eq(choices[0]["need"], "money >= 100")
	assert_eq(choices[0]["need_reason"], "Không đủ tiền")
	assert_eq(choices[1]["cond"], "flag.x == 0")
	assert_eq(entries[5]["args"], PackedStringArray(["Hai từ có dấu cách"]))
	assert_eq(parsed.order, ["a_node", "b_node"] as Array[String])


func test_errors_with_line_numbers() -> void:
	var text: String = "minh: ngoài node\n== a\n* thiếu mũi tên\n~ lenh_la 1\nminh: x [if khong hop le]\n== a\n== b\nminh: hi\n@trigger muon\n* x -> y [need money > 1]\n"
	var errors: PackedStringArray = Parser.parse(text, "loi.dlg").errors
	var joined: String = "\n".join(errors)
	assert_true(joined.contains("loi.dlg:1:"), "nội dung ngoài node")
	assert_true(joined.contains("loi.dlg:3:"), "lựa chọn thiếu ->")
	assert_true(joined.contains("loi.dlg:4:"), "lệnh lạ")
	assert_true(joined.contains("loi.dlg:5:"), "điều kiện sai")
	assert_true(joined.contains("loi.dlg:6:"), "trùng node")
	assert_true(joined.contains("loi.dlg:9:"), "metadata sai chỗ")
	assert_true(joined.contains("loi.dlg:10:"), "need thiếu |")


func test_extra_command_accepted() -> void:
	var parsed: DialogueScript = Parser.parse("== a\n~ quest start q1\n", "x.dlg", PackedStringArray(["quest"]))
	assert_eq(parsed.errors.size(), 0)
