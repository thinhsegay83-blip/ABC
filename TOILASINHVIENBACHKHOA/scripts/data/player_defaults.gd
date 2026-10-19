class_name PlayerDefaults
extends Resource
## Tên gợi ý khi bắt đầu ván (J10, QĐ-3.2 = A + nút ngẫu nhiên).

@export var default_name: String = "Phong"
@export var random_names: Array[String] = []

const PATH: String = "res://data/player_defaults.tres"


static func load_default() -> PlayerDefaults:
	var defaults: PlayerDefaults = load(PATH) as PlayerDefaults
	return defaults if defaults != null else PlayerDefaults.new()


## Tên dùng được: tên đã lưu, hoặc tên mặc định nếu trống.
static func name_or_default(name: String) -> String:
	return name if not name.strip_edges().is_empty() else load_default().default_name
