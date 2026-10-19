class_name ShopData
extends Resource
## Quầy bán hàng (D6). QĐ-4.1 = A: không có khu cửa hàng riêng.

@export var id: String = ""
@export var display_name: String = ""
@export var place_id: String = ""
@export var item_ids: Array[String] = []
## Khung giờ mở cửa (GameClock.Slot). Rỗng = mọi khung.
@export var open_slots: Array[int] = []
