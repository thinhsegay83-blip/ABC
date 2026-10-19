extends "res://tests/test_case.gd"


func test_single_source() -> void:
	var src: Array[Dictionary] = [{"position": Vector2.ZERO, "strength": 0.5, "radius": 100.0}]
	assert_almost_eq(RadarMath.signal_at(Vector2.ZERO, src), 0.5)
	assert_almost_eq(RadarMath.signal_at(Vector2(50, 0), src), 0.25)
	assert_almost_eq(RadarMath.signal_at(Vector2(100, 0), src), 0.0, 0.0001, "tại biên")
	assert_almost_eq(RadarMath.signal_at(Vector2(150, 0), src), 0.0, 0.0001, "ngoài biên")


func test_max_of_sources() -> void:
	var src: Array[Dictionary] = [
		{"position": Vector2.ZERO, "strength": 0.3, "radius": 100.0},
		{"position": Vector2(10, 0), "strength": 0.9, "radius": 20.0},
	]
	assert_almost_eq(RadarMath.signal_at(Vector2(10, 0), src), 0.9)


func test_bar_thresholds() -> void:
	assert_eq(RadarMath.bars(0.09), 0)
	assert_eq(RadarMath.bars(0.10), 1)
	assert_eq(RadarMath.bars(0.29), 1)
	assert_eq(RadarMath.bars(0.30), 2)
	assert_eq(RadarMath.bars(0.55), 3)
	assert_eq(RadarMath.bars(0.79), 3)
	assert_eq(RadarMath.bars(0.80), 4)
