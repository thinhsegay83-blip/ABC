class_name StoryVars
extends RefCounted
## Biến cốt truyện dùng chung: Mức dính líu K. (A8), bậc quan hệ (A6).

const K_FLAG: String = "dinh_lieu_k"
const RELATION_BANDS: Array = [
	[80, "Rất thân"], [60, "Thân"], [40, "Bạn"], [20, "Quen"], [0, "Người lạ"],
]


static func add_k_involvement(state: GameState, amount: int) -> int:
	var value: int = clampi(state.flags.get_flag(K_FLAG) + amount, 0, 100)
	state.flags.set_flag(K_FLAG, value)
	return value


## "thấp" < 30, "vừa" 30–59, "cao" ≥ 60 [ĐX].
static func k_involvement_band(value: int) -> String:
	if value >= 60:
		return "cao"
	if value >= 30:
		return "vừa"
	return "thấp"


## Dòng mô tả dưới tên K. trong danh bạ (QĐ-5.1 = A: không hiện con số).
static func k_contact_note(value: int) -> String:
	match k_involvement_band(value):
		"cao":
			return "K. rất tin tưởng bạn. Anh ấy nhắn tin cho bạn mỗi ngày."
		"vừa":
			return "K. bắt đầu gọi bạn là \"người nhà\"."
	return "Một đàn anh mới quen."


static func relation_band(value: int) -> String:
	for row: Array in RELATION_BANDS:
		if value >= int(row[0]):
			return str(row[1])
	return "Người lạ"
