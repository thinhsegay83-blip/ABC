class_name StairPhysics
extends RefCounted
## Vật lý câu đố cầu thang (mô hình đơn giản hóa cho game):
## giếng cầu thang trong vòng lặp ≈ ống kín một đầu dài L (chiều cao một tầng).
## f_n = n·v/(4L), n lẻ; v ≈ 331 + 0,6·t (m/s, t °C) → 20 °C: 343 m/s.

const STAIR_TEMPERATURE_C: float = 20.0
const FLOOR_HEIGHT_M: float = 3.43
## Lệch khỏi tần số gốc từ mức này trở lên = chiếu nghỉ đã bị "méo".
const DEVIATION_HZ: float = 1.0


static func sound_speed(temperature_c: float = STAIR_TEMPERATURE_C) -> float:
	return 331.0 + 0.6 * temperature_c


## Tần số cơ bản ống kín một đầu, làm tròn 0,1 Hz.
static func closed_pipe_hz(length_m: float, speed: float = sound_speed()) -> float:
	return snappedf(speed / (4.0 * length_m), 0.1)


static func base_hz() -> float:
	return closed_pipe_hz(FLOOR_HEIGHT_M)


static func is_distorted(hz: float) -> bool:
	return absf(hz - base_hz()) >= DEVIATION_HZ


## Hiển thị kiểu Việt Nam: "25,0 Hz".
static func format_hz(hz: float) -> String:
	return ("%.1f Hz" % hz).replace(".", ",")
