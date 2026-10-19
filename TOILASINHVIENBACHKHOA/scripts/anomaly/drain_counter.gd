class_name DrainCounter
extends RefCounted
## G2: vùng "tần số lạ" trừ Sanity từ từ, có trần mỗi lần vào vùng. Logic thuần.
## Chỉ cộng thời gian khi người chơi điều khiển được (không tính lúc pause/hội thoại/điện thoại).

var per_tick: int = 1
var tick_seconds: float = 5.0
var max_per_visit: int = 10

var _elapsed: float = 0.0
var _drained: int = 0
var _inside: bool = false


func _init(sanity_per_tick: int = 1, seconds: float = 5.0, cap: int = 10) -> void:
	per_tick = sanity_per_tick
	tick_seconds = seconds
	max_per_visit = cap


## Trả số Sanity cần trừ ở khung hình này (0 nếu chưa đủ một nhịp hoặc đã chạm trần).
func update(delta: float, inside: bool, controllable: bool) -> int:
	if not inside:
		_inside = false
		_elapsed = 0.0
		_drained = 0
		return 0
	_inside = true
	if not controllable or _drained >= max_per_visit:
		return 0
	_elapsed += delta
	var amount: int = 0
	while _elapsed >= tick_seconds and _drained < max_per_visit:
		_elapsed -= tick_seconds
		var step: int = mini(per_tick, max_per_visit - _drained)
		_drained += step
		amount += step
	return amount


func drained_this_visit() -> int:
	return _drained
