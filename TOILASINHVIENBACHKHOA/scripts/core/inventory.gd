class_name Inventory
extends RefCounted
## Túi đồ (mô hình dữ liệu). Giao diện túi đồ (I1) làm ở bước 5.

var _items: Dictionary = {}  # item_id (String) -> số lượng (int > 0)


func add(item_id: String, amount: int = 1) -> void:
	if amount <= 0:
		return
	_items[item_id] = count(item_id) + amount


## false nếu không đủ (không trừ gì).
func remove(item_id: String, amount: int = 1) -> bool:
	var have: int = count(item_id)
	if amount <= 0 or have < amount:
		return false
	if have == amount:
		_items.erase(item_id)
	else:
		_items[item_id] = have - amount
	return true


func count(item_id: String) -> int:
	return int(_items.get(item_id, 0))


func to_dict() -> Dictionary:
	return _items.duplicate()


func from_dict(data: Dictionary) -> void:
	_items.clear()
	for key: Variant in data.keys():
		var amount: int = int(data[key])
		if amount > 0:
			_items[str(key)] = amount
