class_name ReadLog
extends RefCounted
## Câu thoại đã đọc (cho tính năng Tua) — lưu chung mọi ván ở user://dialogue_read.cfg.

const DEFAULT_PATH: String = "user://dialogue_read.cfg"
const SECTION: String = "read"

var _read: Dictionary = {}
var _dirty: bool = false


func mark_read(key: String) -> void:
	if not _read.has(key):
		_read[key] = true
		_dirty = true


func is_read(key: String) -> bool:
	return _read.has(key)


func load_from(path: String = DEFAULT_PATH) -> void:
	_read.clear()
	var config: ConfigFile = ConfigFile.new()
	if config.load(path) != OK:
		return
	if config.has_section(SECTION):
		for key: String in config.get_section_keys(SECTION):
			_read[key] = true
	_dirty = false


func save_to(path: String = DEFAULT_PATH) -> void:
	if not _dirty:
		return
	var config: ConfigFile = ConfigFile.new()
	for key: String in _read.keys():
		config.set_value(SECTION, key, true)
	if config.save(path) == OK:
		_dirty = false
