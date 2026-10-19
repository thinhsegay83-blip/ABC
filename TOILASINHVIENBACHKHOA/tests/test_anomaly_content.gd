extends "res://tests/test_case.gd"
## Nội dung lõi của dị tượng tồn tại, parse 0 lỗi, đúng tông (không kinh dị, không kỳ thị).

const REQUIRED_NODES: Array[String] = [
	"tien_boi_truyen_thuyet", "cau_thang_bat_dau", "cau_thang_sai_1", "cau_thang_sai_2", "cau_thang_sai_3",
	"cau_thang_dung_1", "cau_thang_dung_2", "cau_thang_dung_3", "cau_thang_thoat",
	"goi_y_1", "goi_y_2", "goi_y_3", "goi_tien_boi", "cau_thang_cau_hoi", "t3_dem_minh_ra_ngoai",
]
const FORBIDDEN: Array[String] = ["máu", "xác chết", "ma quỷ", "hồn ma", "điên", "loạn trí", "tâm thần"]
const ANOMALY_FILES: Array[String] = ["cau_thang.dlg", "truyen_thuyet.dlg", "g4_dem_tuan3.dlg"]


func test_core_content() -> void:
	var dialogue: Node = (Engine.get_main_loop() as SceneTree).root.get_node("DialogueSystem")
	var library: DialogueLibrary = DialogueLibrary.load_dir(DialogueLibrary.DEFAULT_DIR, dialogue.command_names())
	assert_eq(library.get_errors().size(), 0, "\n".join(library.get_errors()))
	for node_id: String in REQUIRED_NODES:
		assert_true(library.has_dialogue(node_id), "thiếu node " + node_id)
	var legend: String = FileAccess.get_file_as_string("res://content/dialogue/truyen_thuyet.dlg")
	for keyword: String in ["đi xuống", "đi lên", "bốn", "ống", "3,43"]:
		assert_true(legend.contains(keyword) or legend.contains(keyword.replace("đi xuống", "quay xuống")),
				"truyền thuyết thiếu ý: " + keyword)


func test_tone() -> void:
	for file_name: String in ANOMALY_FILES:
		var text: String = FileAccess.get_file_as_string("res://content/dialogue/" + file_name).to_lower()
		for word: String in FORBIDDEN:
			assert_false(text.contains(word), "%s có cụm từ cấm '%s'" % [file_name, word])
