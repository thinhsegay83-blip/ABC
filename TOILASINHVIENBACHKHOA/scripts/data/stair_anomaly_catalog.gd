class_name StairAnomalyCatalog
extends Resource
## Chiếu nghỉ gốc + các chỗ lệch của cầu thang vô tận (G3).
## base_lines: element_id → câu mô tả ở chiếu nghỉ gốc (thứ tự hiển thị theo base_order).
## anomalies: [{id, element, text, hum_length_m, mo_ta}] — text thay cho câu của element.
## Tần số hiện trên điện thoại TÍNH từ hum_length_m (StairPhysics), không gõ tay.

@export var base_order: Array[String] = []
@export var base_lines: Dictionary = {}
@export var tech_plate: String = "Biển kỹ thuật: Chiều cao tầng 3,43 m."
@export var anomalies: Array[Dictionary] = []


func get_anomaly(anomaly_id: String) -> Dictionary:
	for anomaly: Dictionary in anomalies:
		if anomaly["id"] == anomaly_id:
			return anomaly
	return {}


func ids() -> Array[String]:
	var result: Array[String] = []
	for anomaly: Dictionary in anomalies:
		result.append(str(anomaly["id"]))
	return result


## Các câu mô tả chiếu nghỉ (có chỗ lệch nếu anomaly_id khác rỗng).
func landing_lines(anomaly_id: String) -> Array[String]:
	var anomaly: Dictionary = get_anomaly(anomaly_id)
	var lines: Array[String] = []
	for element: String in base_order:
		if not anomaly.is_empty() and anomaly["element"] == element:
			lines.append(str(anomaly["text"]))
		else:
			lines.append(str(base_lines.get(element, "")))
	return lines


func landing_hz(anomaly_id: String) -> float:
	var anomaly: Dictionary = get_anomaly(anomaly_id)
	if anomaly.is_empty():
		return StairPhysics.base_hz()
	return StairPhysics.closed_pipe_hz(float(anomaly["hum_length_m"]))
