extends "res://tests/test_case.gd"


func test_drain_cap_reset_and_lock() -> void:
	var counter: DrainCounter = DrainCounter.new(1, 5.0, 10)
	assert_eq(counter.update(4.9, true, true), 0)
	assert_eq(counter.update(0.2, true, true), 1, "trừ 1 mỗi 5 giây")
	assert_eq(counter.update(100.0, true, false), 0, "khóa điều khiển → không đếm")
	assert_eq(counter.update(100.0, true, true), 9, "dừng ở trần 10")
	assert_eq(counter.update(10.0, true, true), 0)
	assert_eq(counter.update(0.1, false, true), 0, "ra vùng")
	assert_eq(counter.update(5.0, true, true), 1, "vào lại → đếm lại từ đầu")
