class_name PlayerName
extends RefCounted
## Kiểm tra tên nhân vật (J10): 1–16 ký tự; chữ (kể cả tiếng Việt có dấu), số, dấu cách, - và '.
## Cấm { } [ ] \ " : và ký tự điều khiển (tránh phá cú pháp thay biến/BBCode).

const MAX_LENGTH: int = 16
const FORBIDDEN: String = "{}[]\\\":"


static func sanitize(text: String) -> String:
	var parts: PackedStringArray = text.strip_edges().split(" ", false)
	return " ".join(parts)


## "" nếu hợp lệ, ngược lại là lý do tiếng Việt.
static func validate(text: String) -> String:
	var name: String = sanitize(text)
	if name.is_empty():
		return "Hãy nhập tên."
	if name.length() > MAX_LENGTH:
		return "Tên dài tối đa %d ký tự." % MAX_LENGTH
	for ch: String in name:
		var code: int = ch.unicode_at(0)
		if code < 32 or code == 127:
			return "Tên không được chứa ký tự điều khiển."
		if FORBIDDEN.contains(ch):
			return "Tên không được chứa ký tự %s" % ch
		if ch == " " or ch == "-" or ch == "'":
			continue
		if not (_is_letter(ch) or ch.is_valid_int()):
			return "Tên chỉ gồm chữ, số, dấu cách, - và '."
	return ""


static func _is_letter(ch: String) -> bool:
	return ch.to_upper() != ch.to_lower() or (ch.unicode_at(0) > 127 and ch.unicode_at(0) < 0x2000)
