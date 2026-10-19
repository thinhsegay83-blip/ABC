class_name DialogueParser
extends RefCounted
## Đọc kịch bản .dlg (định dạng xem docs/ARCHITECTURE.md mục "Bước 3").

const BUILTIN_COMMANDS: Array[String] = [
	"set", "add", "stat", "money", "rel", "goto", "end", "toast", "emit",
]

static var _node_regex: RegEx = RegEx.create_from_string("^==\\s*([a-z0-9_]+)\\s*$")
static var _meta_regex: RegEx = RegEx.create_from_string("^@([a-z_]+)\\s*(.*)$")
static var _line_regex: RegEx = RegEx.create_from_string(
	"^([a-z0-9_]+)(?:\\s*\\(([a-z0-9_]+)\\))?\\s*:\\s?(.*)$"
)
static var _if_tail: RegEx = RegEx.create_from_string("\\s*\\[if\\s+([^\\]]+)\\]\\s*$")
static var _need_tail: RegEx = RegEx.create_from_string("\\s*\\[need\\s+([^\\]]*)\\]\\s*$")


## extra_commands: lệnh do bước sau đăng ký (DialogueSystem.register_command).
static func parse(
	text: String, file_name: String, extra_commands: PackedStringArray = PackedStringArray(),
	into: DialogueScript = null
) -> DialogueScript:
	var parsed: DialogueScript = into if into != null else DialogueScript.new()
	var current: Dictionary = {}
	var line_index: int = 0  # chỉ số lời thoại trong node (cho line_key)
	var line_no: int = 0
	var pending_choices: Dictionary = {}
	for raw_line: String in text.split("\n"):
		line_no += 1
		var line: String = raw_line.strip_edges()
		if line.is_empty() or line.begins_with("#"):
			continue
		var where: String = "%s:%d" % [file_name, line_no]

		if not line.begins_with("*"):
			pending_choices = {}

		var node_match: RegExMatch = _node_regex.search(line)
		if node_match != null:
			var node_id: String = node_match.get_string(1)
			if parsed.nodes.has(node_id):
				var other: Dictionary = parsed.nodes[node_id]
				parsed.errors.append("%s: trùng node '%s' (đã có ở %s:%d)" % [
					where, node_id, other["file"], int(other["line"])
				])
				current = {}
				continue
			current = {"id": node_id, "meta": {}, "entries": [], "file": file_name, "line": line_no}
			parsed.nodes[node_id] = current
			parsed.order.append(node_id)
			line_index = 0
			continue
		if line.begins_with("=="):
			parsed.errors.append("%s: tên node không hợp lệ (chỉ a-z, 0-9, _)" % where)
			current = {}
			continue
		if current.is_empty():
			parsed.errors.append("%s: nội dung nằm ngoài node (thiếu dòng '== ten_node' phía trên)" % where)
			continue

		if line.begins_with("@"):
			if not (current["entries"] as Array).is_empty():
				parsed.errors.append("%s: metadata '@' phải đứng ngay sau dòng '=='" % where)
				continue
			var meta_match: RegExMatch = _meta_regex.search(line)
			if meta_match == null:
				parsed.errors.append("%s: metadata sai cú pháp" % where)
				continue
			var meta: Dictionary = current["meta"]
			var key: String = meta_match.get_string(1)
			if not meta.has(key):
				meta[key] = []
			(meta[key] as Array).append(meta_match.get_string(2).strip_edges())
			continue

		if line.begins_with("*"):
			var option: Dictionary = _parse_choice(line.substr(1).strip_edges(), where, parsed.errors)
			if option.is_empty():
				continue
			option["line"] = line_no
			if pending_choices.is_empty():
				pending_choices = {"type": "choices", "options": []}
				(current["entries"] as Array).append(pending_choices)
			(pending_choices["options"] as Array).append(option)
			continue

		if line.begins_with("~"):
			var cmd: Dictionary = _parse_command(line.substr(1).strip_edges(), where, parsed.errors, extra_commands)
			if not cmd.is_empty():
				cmd["line"] = line_no
				(current["entries"] as Array).append(cmd)
			continue

		var body: String = line
		var cond: String = _take_tail(_if_tail, body)
		if not cond.is_empty():
			body = _if_tail.sub(body, "")
			_check_condition(cond, where, parsed.errors)
		var line_match: RegExMatch = _line_regex.search(body)
		if line_match == null:
			parsed.errors.append("%s: không hiểu dòng (cần 'nguoi_noi: lời thoại')" % where)
			continue
		var expression: String = line_match.get_string(2)
		(current["entries"] as Array).append({
			"type": "line",
			"speaker": line_match.get_string(1),
			"expression": expression if not expression.is_empty() else "thuong",
			"text": line_match.get_string(3).strip_edges(),
			"cond": cond,
			"index": line_index,
			"line": line_no,
		})
		line_index += 1
	return parsed


static func _parse_choice(body: String, where: String, errors: PackedStringArray) -> Dictionary:
	var cond: String = ""
	var need: String = ""
	var need_reason: String = ""
	# Đuôi có thể theo thứ tự bất kỳ: [if …] [need … | …]
	for _i in 2:
		var if_text: String = _take_tail(_if_tail, body)
		if not if_text.is_empty():
			cond = if_text
			body = _if_tail.sub(body, "")
			_check_condition(cond, where, errors)
			continue
		var need_text: String = _take_tail(_need_tail, body)
		if not need_text.is_empty():
			body = _need_tail.sub(body, "")
			var bar: int = need_text.find("|")
			if bar < 0:
				errors.append("%s: [need …] thiếu '|' để ghi lý do" % where)
				return {}
			need = need_text.substr(0, bar).strip_edges()
			need_reason = need_text.substr(bar + 1).strip_edges()
			_check_condition(need, where, errors)
	var arrow: int = body.rfind("->")
	if arrow < 0:
		errors.append("%s: lựa chọn thiếu '-> ten_node'" % where)
		return {}
	var target: String = body.substr(arrow + 2).strip_edges()
	if not RegEx.create_from_string("^[a-z0-9_]+$").search(target):
		errors.append("%s: đích lựa chọn không hợp lệ '%s'" % [where, target])
		return {}
	return {
		"text": body.substr(0, arrow).strip_edges(),
		"target": target,
		"cond": cond,
		"need": need,
		"need_reason": need_reason,
	}


static func _parse_command(
	body: String, where: String, errors: PackedStringArray, extra_commands: PackedStringArray
) -> Dictionary:
	var cond: String = _take_tail(_if_tail, body)
	if not cond.is_empty():
		body = _if_tail.sub(body, "")
		_check_condition(cond, where, errors)
	var args: PackedStringArray = tokenize(body)
	if args.is_empty():
		errors.append("%s: lệnh rỗng" % where)
		return {}
	var name: String = args[0]
	args.remove_at(0)
	if not BUILTIN_COMMANDS.has(name) and not extra_commands.has(name):
		errors.append("%s: lệnh lạ '~ %s'" % [where, name])
		return {}
	return {"type": "cmd", "name": name, "args": args, "cond": cond}


## Tách tham số theo khoảng trắng, giữ nguyên cụm trong ngoặc kép.
static func tokenize(text: String) -> PackedStringArray:
	var result: PackedStringArray = PackedStringArray()
	var current: String = ""
	var in_quotes: bool = false
	var has_token: bool = false
	for ch: String in text:
		if ch == "\"":
			in_quotes = not in_quotes
			has_token = true
		elif ch == " " and not in_quotes:
			if has_token:
				result.append(current)
				current = ""
				has_token = false
		else:
			current += ch
			has_token = true
	if has_token:
		result.append(current)
	return result


static func _take_tail(regex: RegEx, text: String) -> String:
	var m: RegExMatch = regex.search(text)
	return m.get_string(1).strip_edges() if m != null else ""


static func _check_condition(cond: String, where: String, errors: PackedStringArray) -> void:
	var problem: String = DialogueCondition.validate(cond)
	if not problem.is_empty():
		errors.append("%s: %s" % [where, problem])
