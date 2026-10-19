class_name QuestData
extends Resource
## Nhiệm vụ (H2). steps: [{text, done_condition}] — bước tự xong khi điều kiện đúng.

@export var id: String = ""
@export var title: String = ""
@export_multiline var description: String = ""
## Tự bắt đầu khi điều kiện đúng; rỗng = chỉ bắt đầu bằng lệnh "~ quest start".
@export var start_condition: String = ""
@export var steps: Array[Dictionary] = []
## Ngày hạn (0 = không có). Có thể đổi theo cờ: deadline_flag_extended.
@export var deadline_day: int = 0
## Nếu cờ này == 1 thì hạn dùng extended_deadline_day (vd. học phí được gia hạn).
@export var deadline_extend_flag: String = ""
@export var extended_deadline_day: int = 0
@export var optional: bool = false
