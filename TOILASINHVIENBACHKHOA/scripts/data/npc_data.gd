class_name NpcData
extends Resource
## NPC theo lịch khung giờ (E2). Mỗi mục lịch là Dictionary:
## {day_from, day_to (0 = không giới hạn), weekdays: [] (rỗng = mọi ngày), slots: [] (rỗng = mọi khung),
##  place: area_id ("" = vắng mặt), anchor: id điểm đứng trên bản đồ, condition: "", behavior: "stand"/"sit"/"face_wall"}
## Mục đầu tiên khớp thắng.

@export var id: String = ""
## CharacterData để lấy tên/chân dung.
@export var character_id: String = ""
@export var schedule: Array[Dictionary] = []
## Cờ trạng thái (vd. minh_trang_thai) — bước 2 đổi sprite theo giá trị này.
@export var state_flag: String = ""
## Hội thoại khi nói chuyện mà không có sự kiện @trigger interact nào khớp.
@export var default_dialogue: String = ""
## Câu lẩm bẩm khi behavior = "face_wall" (E3, trạng thái 3 của Minh).
@export var murmurs: Array[String] = []
