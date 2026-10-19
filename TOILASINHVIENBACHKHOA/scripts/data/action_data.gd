class_name ActionData
extends Resource
## Một hành động tốn thời gian (C1, D1): đi học, tự học, làm thêm, nghỉ, ngủ…

@export var id: String = ""
@export var display_name: String = ""
## Nơi làm được hành động: ktx_room, ktx_hallway, lecture_hall, library, food_shop.
@export var place_id: String = ""
## "class" (vào học) / "study" / "work" / "rest" / "sleep" / "special" / "outing" (đi chơi, gọi từ hội thoại).
@export var category: String = "rest"
@export var slot_cost: int = 1
## Khung giờ được phép (GameClock.Slot). Rỗng = mọi khung.
@export var allowed_slots: Array[int] = []
## Điều kiện dạng "flag.ten_co == 1" (rỗng = luôn được).
@export var requires: String = ""
## Lý do hiện khi `requires` sai.
@export var requires_reason: String = ""
## Ẩn hẳn khỏi menu khi `requires` sai (thay vì hiện mờ).
@export var hide_when_locked: bool = false
@export var stamina: int = 0
@export var hunger: int = 0
@export var sanity: int = 0
@export var knowledge: int = 0
@export var base_wage: int = 0
@export var tip_max: int = 0
@export var counts_as_shift: bool = false
## Câu báo khi khung giờ không hợp lệ, vd. "Quán chỉ cần người buổi Sáng/Chiều".
@export var wrong_slot_reason: String = ""
## Hành động đặc biệt: đặt cờ này = 1 (vd. xin việc).
@export var sets_flag: String = ""
## Chi phí (đi chơi…), trả qua Economy; thiếu tiền thì không làm được.
@export var price: int = 0
## Cộng vào cờ mỗi lần làm (vd. dinh_lieu_k +10 khi phát tờ rơi cho K.).
@export var adds_flag: String = ""
@export var adds_flag_amount: int = 0
## Quan hệ với NPC đi cùng (tham số "npc").
@export var relationship_delta: int = 0
## Câu narrator ngẫu nhiên khi làm (đi chơi…).
@export var narration: Array[String] = []
