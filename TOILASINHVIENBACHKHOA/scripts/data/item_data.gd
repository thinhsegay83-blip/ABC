class_name ItemData
extends Resource
## Món ăn / đồ uống / giáo trình bán ở cửa hàng (D6, D7).

@export var id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var price: int = 0
## "food" / "drink" / "book" / "story".
@export var category: String = "food"
@export var hunger: int = 0
@export var stamina: int = 0
@export var sanity: int = 0
## Hiệu ứng tạm thời khi dùng, vd. "cafein".
@export var effect_id: String = ""
## Ăn/uống ngay khi mua (không vào túi đồ, không tốn khung giờ).
@export var consume_on_buy: bool = true
## Giáo trình của môn nào (tự học môn đó hiệu quả hơn).
@export var study_subject: String = ""
## Mua mang về được (vào túi đồ, dùng lúc nào cũng được).
@export var can_carry: bool = false
