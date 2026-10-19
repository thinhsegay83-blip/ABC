class_name StoryFlagRegistry
extends Resource
## Danh mục cờ cốt truyện (H1): tên cờ → mô tả ý nghĩa các giá trị.
## Quy ước: snake_case tiếng Việt không dấu; cờ hướng dẫn bắt đầu "tut_", cờ hệ thống "sys_".

@export var flags: Dictionary = {}


func has_flag_name(flag_name: String) -> bool:
	return flags.has(flag_name)


func names() -> Array[String]:
	var result: Array[String] = []
	for key: Variant in flags.keys():
		result.append(str(key))
	result.sort()
	return result
