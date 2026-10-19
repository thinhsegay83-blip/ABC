class_name CharacterData
extends Resource
## Nhân vật nói trong hội thoại (E1). Chân dung do phần đồ họa (bước 2) bổ sung;
## thiếu chân dung thì hộp thoại ẩn khung chân dung.

@export var id: String = ""
@export var display_name: String = ""
@export var name_color: Color = Color(0.98, 0.83, 0.42, 1.0)
## Biểu cảm (thuong, cuoi, buon, ngac_nhien, met…) → Texture2D.
@export var portraits: Dictionary = {}
@export var default_expression: String = "thuong"


func get_portrait(expression: String) -> Texture2D:
	if portraits.has(expression):
		return portraits[expression] as Texture2D
	return portraits.get(default_expression, null) as Texture2D
