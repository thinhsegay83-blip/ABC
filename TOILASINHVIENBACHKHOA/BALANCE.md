# Cân bằng kinh tế — MVP (tuần 1–4)

Đơn vị: VND. Mọi con số đặt trong file Resource .tres (J13), không viết cứng trong code.

## Giá cố định (đã chốt)
| Khoản | Giá |
|---|---|
| Học phí mỗi học kỳ (1 năm có 2 học kỳ: HK1, HK2) | 16.000.000 / học kỳ → 32.000.000 / năm |
| Bánh mì | 20.000 |
| Phở / cơm | 30.000 |
| Cà phê / nước tăng lực | 15.000 |
| Trà sữa | 25.000 [ĐX] |
| Tiền KTX | 300.000 / tháng [ĐX] |
| Góp quỹ phòng | 200.000 / tháng [ĐX] |

## Thu nhập (1 ca = 1 khung giờ) [ĐX]
| Việc | Lương |
|---|---|
| Phụ quán cơm | 120.000 / ca |
| Bưng cà phê | 100.000 / ca + tip ngẫu nhiên 0–30.000 |
| Phát tờ rơi cho K. (từ tuần 3) | 350.000 / ca, Mức dính líu (A8) +10 |

## Hạn học phí
- HK1: hạn chính cuối tuần 2 (trong MVP).
- HK2: đóng đầu HK2, cũng 16.000.000 — thuộc Chapter 2. Học bổng HK1 (kết Chapter 1) là nguồn bù chính. Ngày hạn cụ thể [CẦN QUYẾT ĐỊNH].
- Luật gia hạn/phạt bên dưới áp dụng cho cả 2 học kỳ.
- Trễ hạn → tự gia hạn tới cuối tuần 4, phạt 500.000, Sanity giảm. (Đã chốt)
- Trễ cả hạn gia hạn → bản đầy đủ: Bad Ending "nghỉ học"; trong MVP chỉ hiện cảnh báo. (Đã chốt)

## Chế độ chơi (đã chốt: có 3 chế độ)
| Chế độ | Tiền ban đầu | Tốc độ tụt Đói/Thể lực/Sanity | Lương |
|---|---|---|---|
| Dễ | 15.000.000 | ×0,75 | ×1,0 |
| Khó | 14.000.000 | ×1,0 | ×1,0 |
| Cực khó | 12.000.000 | ×1,25 | ×0,9 |

## Kiểm tra dòng tiền 14 ngày (tới hạn chính)
Cần có = 16.000.000 + 300.000 (KTX) + 200.000 (quỹ) + 980.000 (ăn 70k/ngày) = **17.480.000**
Làm tối đa 2 ca/ngày ≈ 14 × 2 × 110.000 = **3.080.000** (lương ×1,0)

| Chế độ | Thiếu so với cần có | Kết quả nếu làm 2 ca/ngày |
|---|---|---|
| Dễ | 2.480.000 | Dư ~600.000 → kịp hạn thoải mái |
| Khó | 3.480.000 | Hụt ~400.000 → kịp nếu ăn tiết kiệm hoặc thêm ca cuối tuần |
| Cực khó | 5.480.000 | Hụt ~2.400.000 (lương ×0,9 còn hụt hơn) → gần như chắc phải gia hạn, áp lực dồn vào tuần 3 khi K. mời phát tờ rơi |

Ghi chú: phép tính chưa trừ khung giờ đi học bắt buộc theo thời khóa biểu; khi có TKB thật cần tính lại số ca tối đa. [CẦN KIỂM TRA ở bước 4]

## Đề xuất bước 4 [ĐX] — số liệu trong `data/*.tres`

| Khoản | Giá trị |
|---|---|
| Mì gói | 8.000 đ (Đói +12) |
| Giáo trình bản photo | 80.000 đ/môn — tự học môn đó +5 thay vì +3 |
| Phụ quán cơm | Sáng/Chiều, Thể lực −15, Đói −5 |
| Bưng cà phê | Tối, Thể lực −12, Đói −5 |
| Tối đa ca làm/ngày | 2 (QĐ-4.7) |
| 1 tháng (thu KTX) | 28 ngày (QĐ-4.6) |
| Phạt trễ học phí | cộng vào khoản phải đóng → 16.500.000 (QĐ-4.2); Sanity −10 |
| Cafein (cà phê, nước tăng lực) | +20 Thể lực ngay, hết sau 2 khung giờ thì −10 (QĐ-4.3) |
| Đói < 20 | học ×0,5; Thể lực −3 thêm mỗi khung; ngủ hồi một nửa |
| Đói = 0 | Thể lực −6 thêm mỗi khung |
| Thể lực = 0 | ngất: mất 1 khung, Thể lực = 30, Sanity −5 |
| Sanity = 0 | ngủ li bì tới sáng ngày kia, Sanity = 30, Thể lực = 60 (QĐ-4.4) |
| Lương | (lương + tip) × hệ số chế độ, làm tròn 1.000 đ (hệ số áp cả cho tip) |

## Kiểm tra dòng tiền 14 ngày — tính lại ở bước 4 (có TKB)

Chạy `python3 tools/sim_cashflow.py` (20 seed TKB, chiến lược chăm chỉ: đi học đủ, tối đa 2 ca/ngày, ăn món rẻ nhất giữ Đói ≥ 40):

```
Mô phỏng tới hết ngày 14 — chiến lược chăm chỉ (đi học đủ, tối đa 2 ca/ngày, ăn rẻ nhất giữ Đói ≥ 40)
Học phí cần: 16.000.000 đ · 20 seed TKB

Chế độ   Quỹ phòng    Tiền ngày 15 (TB)   So với học phí  Ca/14 ngày  Thể lực min  Ngất
Dễ       không               17.385.850       +1.385.850        25.0           49   0.0
Dễ       có                  17.185.850       +1.185.850        25.0           49   0.0
Khó      không               16.313.850         +313.850        25.0           45   0.0
Khó      có                  16.113.850         +113.850        25.0           45   0.0
Cực khó  không               13.945.900       -2.054.100        25.0           41   0.0
Cực khó  có                  13.745.900       -2.254.100        25.0           41   0.0
```

Mô phỏng bằng logic game thật (`tests/test_cashflow_sim.gd`, 1 seed, ăn cơm tấm): Dễ 17.086.000 · Khó 15.994.000 · Cực khó 13.550.000.

Nhận xét: khớp ý đồ — **Dễ** dư; **Khó** sát nút, chỉ kịp nếu ăn tiết kiệm (mì gói) hoặc làm đủ ca; **Cực khó** hụt ~2 triệu → gần như chắc phải gia hạn. Không đổi giá đã chốt.

## Kiểm tra tới hạn gia hạn (ngày 28) — bước 5 (có việc phát tờ rơi cho K.)

```

Tới hết ngày 28 (hạn gia hạn, phải đóng 16.500.000 đ) — có/không nhận việc phát tờ rơi cho K. từ ngày 15
Chế độ   Việc của K.    Tiền ngày 29 (TB)   So với cần đóng  Dính líu K.
Dễ       không                 19.692.150        +3.192.150            0
Dễ       có                    25.471.850        +8.971.850          100
Khó      không                 18.547.750        +2.047.750            0
Khó      có                    24.327.450        +7.827.450          100
Cực khó  không                 15.813.200          -686.800            0
Cực khó  có                    21.021.700        +4.521.700          100
```

Nhận xét: ở **Cực khó**, không nhận việc của K. thì tới ngày 28 vẫn **thiếu ~690.000 đ** — người chơi gần như bị ép vào việc của K. (đúng chủ đề cám dỗ, nhưng có thể thấy bất công). Nhận việc K. 2 ca/ngày thì Mức dính líu chạm 100 chỉ sau ~5 ngày. **Đã chốt: giữ nguyên** — Cực khó cố ý đẩy người chơi đối mặt lời dụ của K. (ghi rõ trong mô tả chế độ).

## Dòng tiền 28 ngày (MVP) — bot chơi thử bằng logic game thật (bước 7)

Thay cho việc mở rộng `tools/sim_cashflow.py`: bot `tests/mvp_bot.gd` chơi trọn ván bằng chính code game (TKB thật, Thể lực, đói, ngất, nội dung thoại thật), seed cố định. In ra khi chạy `tests/run_tests.gd`.

Chiến lược: **Chăm học** = đủ tiết, tự học, 1 ca Tối/ngày tới khi đóng học phí, từ chối K., cảnh báo Minh. **Chăm làm** = đủ tiết, 2 ca/ngày, ăn mì gói, từ chối K. **Theo K.** = như Chăm làm nhưng nhận việc tờ rơi từ tuần 3 (ưu tiên tờ rơi), không cảnh báo Minh. Mọi chiến lược góp quỹ phòng 200.000 và đóng học phí khi đủ tiền + 100.000 dự phòng.

| Chiến lược | Chế độ | Tiền cuối ngày 28 | Học phí | Trí tuệ | Dính líu K. |
|---|---|---:|---|---:|---:|
| Chăm học | Dễ | 101.000 | trễ hạn (gia hạn) | 100 | 0 |
| Chăm học | Khó | 15.820.000 | CHƯA đóng | 100 | 0 |
| Chăm học | Cực khó | 13.405.000 | CHƯA đóng | 100 | 0 |
| Chăm làm | Dễ | 2.914.000 | đúng hạn | 67 | 0 |
| Chăm làm | Khó | 1.926.000 | trễ hạn (gia hạn) | 62 | 0 |
| Chăm làm | Cực khó | 15.396.000 | CHƯA đóng | 64 | 0 |
| Theo K. | Dễ | 8.563.000 | đúng hạn | 67 | 100 |
| Theo K. | Khó | 7.997.000 | trễ hạn (gia hạn) | 62 | 100 |
| Theo K. | Cực khó | 3.885.000 | trễ hạn (gia hạn) | 64 | 100 |

Không ván nào ngất hay kiệt sức tinh thần. Cả 9 ván tới màn "Còn tiếp…" ở Đêm ngày 28.

Nhận xét — **khớp ý đồ**, test `test_playthrough_mvp.gd` khóa lại 4 điểm: Dễ + Chăm làm đóng kịp hạn chính; Khó + Chăm làm hụt hạn chính nhưng đóng được khi gia hạn; Cực khó + Chăm làm không đóng nổi tới ngày 28 (thiếu ~1,1 triệu, bot kém tối ưu hơn mô phỏng Python ~690.000); Cực khó + Theo K. đóng được trong gia hạn. Chăm học chỉ đóng nổi ở Dễ (trong gia hạn) — học nhiều thì thiếu tiền, đúng chủ đề. Không đổi giá.
