class_name DialogueLibrary
extends RefCounted
## Nạp và gộp mọi file .dlg trong một thư mục.
## Lưu ý xuất bản: .dlg không phải resource → thêm "*.dlg" vào
## Export → Resources → Filters to export non-resource files.

const DEFAULT_DIR: String = "res://content/dialogue/"

var content: DialogueScript = DialogueScript.new()


static func load_dir(dir_path: String = DEFAULT_DIR, extra_commands: PackedStringArray = PackedStringArray()) -> DialogueLibrary:
	var library: DialogueLibrary = DialogueLibrary.new()
	var files: PackedStringArray = DirAccess.get_files_at(dir_path)
	files.sort()
	for file_name: String in files:
		if not file_name.ends_with(".dlg"):
			continue
		var text: String = FileAccess.get_file_as_string(dir_path.path_join(file_name))
		DialogueParser.parse(text, file_name, extra_commands, library.content)
	return library


static func from_text(text: String, file_name: String = "test.dlg", extra_commands: PackedStringArray = PackedStringArray()) -> DialogueLibrary:
	var library: DialogueLibrary = DialogueLibrary.new()
	DialogueParser.parse(text, file_name, extra_commands, library.content)
	return library


func has_dialogue(node_id: String) -> bool:
	return content.nodes.has(node_id)


func get_dialogue(node_id: String) -> Dictionary:
	return content.nodes.get(node_id, {})


func get_errors() -> PackedStringArray:
	return content.errors


## Các node có metadata @trigger, theo thứ tự file/dòng.
func triggered_nodes() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for node_id: String in content.order:
		var node: Dictionary = content.nodes[node_id]
		if (node["meta"] as Dictionary).has("trigger"):
			result.append(node)
	return result
