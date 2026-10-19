class_name DialogueScript
extends RefCounted
## Kết quả parse một hoặc nhiều file .dlg.
## nodes: node_id -> {id, meta: {khóa: [chuỗi]}, entries: [entry], file, line}
## entry:
##   {type: "line", speaker, expression, text, cond, index, line}
##   {type: "choices", options: [{text, target, cond, need, need_reason, line}]}
##   {type: "cmd", name, args: PackedStringArray, cond, line}

var nodes: Dictionary = {}
var errors: PackedStringArray = PackedStringArray()
## Thứ tự node theo file/dòng (để sắp sự kiện ổn định).
var order: Array[String] = []
