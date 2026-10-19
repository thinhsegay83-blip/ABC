extends "res://tests/test_case.gd"

const PlayerStatsScript: GDScript = preload("res://scripts/core/player_stats.gd")

var stats: PlayerStats


func before_each() -> void:
	stats = PlayerStatsScript.new()


func test_stat_clamps_to_range() -> void:
	stats.set_stat(PlayerStats.Stat.STAMINA, 150)
	assert_eq(stats.get_stat(PlayerStats.Stat.STAMINA), 100, "vượt trần")
	stats.set_stat(PlayerStats.Stat.HUNGER, -20)
	assert_eq(stats.get_stat(PlayerStats.Stat.HUNGER), 0, "dưới sàn")
	stats.set_stat(PlayerStats.Stat.SANITY, 50)
	stats.change_stat(PlayerStats.Stat.SANITY, -70)
	assert_eq(stats.get_stat(PlayerStats.Stat.SANITY), 0, "change_stat dưới sàn")
	stats.change_stat(PlayerStats.Stat.KNOWLEDGE, 250)
	assert_eq(stats.get_stat(PlayerStats.Stat.KNOWLEDGE), 100, "change_stat vượt trần")


func test_money_can_go_negative() -> void:
	stats.set_money(100000)
	stats.change_money(-350000)
	assert_eq(stats.get_money(), -250000)


func test_relationship_default_and_clamp() -> void:
	assert_eq(stats.get_relationship("minh"), 0, "mặc định")
	stats.change_relationship("minh", 130)
	assert_eq(stats.get_relationship("minh"), 100)
	stats.set_relationship("k", -5)
	assert_eq(stats.get_relationship("k"), 0)


func test_signal_only_when_value_changes() -> void:
	var counter: Array[int] = [0]
	stats.stats_changed.connect(func() -> void: counter[0] += 1)
	stats.set_stat(PlayerStats.Stat.STAMINA, 40)
	stats.set_stat(PlayerStats.Stat.STAMINA, 40)
	assert_eq(counter[0], 1)


func test_dict_round_trip_through_json() -> void:
	stats.set_stat(PlayerStats.Stat.STAMINA, 33)
	stats.set_stat(PlayerStats.Stat.KNOWLEDGE, 77)
	stats.set_money(-12000)
	stats.set_relationship("minh", 45)
	var copy: PlayerStats = PlayerStatsScript.new()
	copy.from_dict(json_round_trip(stats.to_dict()))
	assert_eq(copy.get_stat(PlayerStats.Stat.STAMINA), 33)
	assert_eq(copy.get_stat(PlayerStats.Stat.KNOWLEDGE), 77)
	assert_eq(copy.get_money(), -12000)
	assert_eq(copy.get_relationship("minh"), 45)


func test_display_names() -> void:
	assert_eq(PlayerStats.stat_display_name(PlayerStats.Stat.STAMINA), "Thể lực")
	assert_eq(PlayerStats.stat_display_name(PlayerStats.Stat.HUNGER), "Đói")
	assert_eq(PlayerStats.stat_display_name(PlayerStats.Stat.KNOWLEDGE), "Trí tuệ")
