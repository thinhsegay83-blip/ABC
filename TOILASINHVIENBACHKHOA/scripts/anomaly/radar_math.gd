class_name RadarMath
extends RefCounted
## G1: tín hiệu dị tượng tại một điểm. Logic thuần.
## Mỗi nguồn: {position: Vector2, strength: float (0–1), radius: float}.
## signal = max theo các nguồn của strength × clamp(1 − d/radius, 0, 1).

const BAR_THRESHOLDS: Array[float] = [0.10, 0.30, 0.55, 0.80]


static func signal_at(pos: Vector2, sources: Array[Dictionary]) -> float:
	var best: float = 0.0
	for source: Dictionary in sources:
		var radius: float = float(source.get("radius", 1.0))
		var distance: float = pos.distance_to(source.get("position", Vector2.ZERO))
		var falloff: float = clampf(1.0 - distance / radius, 0.0, 1.0) if radius > 0.0 else 0.0
		best = maxf(best, float(source.get("strength", 0.0)) * falloff)
	return best


## Số vạch 0–4 [ĐX]: < 0,10 → 0; < 0,30 → 1; < 0,55 → 2; < 0,80 → 3; còn lại → 4.
static func bars(signal_value: float) -> int:
	var count: int = 0
	for threshold: float in BAR_THRESHOLDS:
		if signal_value >= threshold:
			count += 1
	return count


static func describe(bar_count: int) -> String:
	match bar_count:
		0:
			return "Không phát hiện tín hiệu lạ."
		1:
			return "Tín hiệu lạ: yếu"
		2, 3:
			return "Tín hiệu lạ: vừa"
	return "Tín hiệu lạ: mạnh"
