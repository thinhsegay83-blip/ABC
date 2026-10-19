extends "res://tests/test_case.gd"
## Số Vật lý của câu đố cầu thang (đã tính lại: f = v/(4L), v = 331 + 0,6·20 = 343 m/s).

const TABLE: Dictionary = {
	"bien_tang_phay": 23.6, "dep_doi_mau": 26.5, "binh_chua_chay_mat": 23.0, "ao_quay_vao": 27.4,
	"dong_ho_nguoc": 22.4, "noi_quy_dong_la": 28.3, "mi_tom_mat_mui": 21.8, "muoi_ba_bac": 29.3,
}


func test_base_frequency() -> void:
	assert_almost_eq(StairPhysics.sound_speed(), 343.0)
	assert_almost_eq(StairPhysics.closed_pipe_hz(3.43), 25.0)
	assert_eq(StairPhysics.format_hz(25.0), "25,0 Hz")


func test_catalog_frequencies() -> void:
	var catalog: StairAnomalyCatalog = load("res://data/anomalies/stair_anomalies.tres") as StairAnomalyCatalog
	assert_eq(catalog.anomalies.size(), TABLE.size())
	for anomaly: Dictionary in catalog.anomalies:
		var hz: float = catalog.landing_hz(str(anomaly["id"]))
		assert_almost_eq(hz, float(TABLE[anomaly["id"]]), 0.001, str(anomaly["id"]))
		assert_true(StairPhysics.is_distorted(hz), "%s lệch ≥ 1 Hz" % anomaly["id"])
	assert_almost_eq(catalog.landing_hz(""), 25.0)
	assert_eq(catalog.landing_lines("").size(), catalog.base_order.size())


func test_question_answers() -> void:
	var v: float = 343.0
	var f: float = 25.0
	assert_almost_eq(v / (4.0 * f), 3.43, 0.0001, "đáp án đúng")
	assert_almost_eq(v / (2.0 * f), 6.86, 0.0001, "ống hở hai đầu")
	assert_almost_eq(v / f, 13.72, 0.0001, "bước sóng")
	assert_almost_eq(snappedf(v / (8.0 * f), 0.01), 1.72, 0.0001, "chia nhầm 8")
