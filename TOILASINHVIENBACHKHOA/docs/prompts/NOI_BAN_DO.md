# Nối cơ chế (bước 3–7) vào bản đồ (bước 2)

Dán cho Claude đang làm bản đồ. Pull nhánh `buoc-1-nen-tang` trước. Đọc `docs/ARCHITECTURE.md` mục Bước 3–7.

Cơ chế đã chạy được bằng menu chữ (phím Q). Việc của bạn: gọi đúng API từ bản đồ. **Không sửa logic** trong `scripts/life/`, `scripts/dialogue/`, `scripts/story/`, `scripts/anomaly/`.

1. **Khu vực:** id khu phải trùng `ktx_room`, `ktx_hallway`, `lecture_hall`, `library`, `food_shop`. Sau khi chuyển khu xong (fade xong) gọi `EventDirector.enter_area(area_id)`.
2. **Đồ vật (Interactable):** nhấn E → `get_tree().call_group(&"life_ui", &"open_place", "<area_id>")`. Ví dụ giường/bàn học → `ktx_room`, máy bán nước → `ktx_hallway`, chỗ ngồi/máy đóng học phí → `lecture_hall`, bàn tự học/quầy photo → `library`, quầy quán/góc cà phê → `food_shop`.
3. **NPC:** sinh NPC theo `EventDirector.npcs_at(area_id)` (trả `{npc, info: {anchor, behavior}}`), đặt ở Marker2D tên = `anchor`. Tính lại khi `Game.time_changed`, khi chuyển khu, khi cờ đổi. Nhấn E vào NPC → `EventDirector.interact(npc.id)`. `behavior = "face_wall"` → quay lưng, bong bóng lấy ngẫu nhiên từ `npc.murmurs`. Sprite theo `NpcSchedule.state_value(npc, Game.state)` (Minh: 1 bình thường, 2 thâm quầng).
4. **Khóa di chuyển** khi: `DialogueSystem.is_active()`, điện thoại mở, LifeUI mở, `AnomalyDirector.loop.active`. Sau hội thoại, bỏ qua phím E trong 0,2 s kể từ `DialogueSystem.last_finished_msec`.
5. **Ngất/kiệt sức:** nghe `StudentLife.collapsed(kind)` → đưa nhân vật về giường ở `ktx_room`.
6. **Sự kiện đêm:** nghe `AnomalyDirector.night_scene(active)`, `npc_moved(npc_id, anchor_id, giây)`, `npc_hidden(npc_id)` để diễn cảnh; cần thêm anchor `minh_dem_1`, `cua_cau_thang` ở hành lang.
   Kịch bản tự đổi khu (cảnh đêm, cao trào, thoát cầu thang, ngủ tiếp) → nghe `AnomalyDirector.area_change_requested(area_id, spawn_id)` và dịch chuyển nhân vật (spawn rỗng = điểm vào mặc định; hiện có `corridor_from_room`). **Không** gọi lại `enter_area` cho lần đổi khu này.
7. **Radar (tùy chọn):** có vị trí thật thì dùng `RadarMath.signal_at(vị_trí_người_chơi, nguồn)` thay cho cách tính theo khu.
8. **Cầu thang vô tận:** trước mắt giữ bản chữ (`StairLoopUI`). Muốn làm cảnh thật thì dùng `AnomalyDirector.loop.current_anomaly` + `catalog.get_anomaly(id)["element"]` để đổi đúng một chi tiết, và gọi `AnomalyDirector.stair_choose("up"/"down")` khi người chơi ra mép trên/dưới.

9. **KTX Khu A/B (bước 7):** `Game.state.flags.get_flag("ktx_khu")` (1 = A, 2 = B) → đổi màu tường/biển tên phòng. QĐ-7.1 hiện = A (chỉ trang trí).
10. **Hướng dẫn chơi:** khi đi lại bằng bản đồ, sửa chữ gợi ý `hanh_dong`, `di_hoc`, `ngu` trong `data/tutorial_hints.tres` (WASD/E thay cho Q). Không cần đụng `tutorial_hints.gd`.
11. **Màn "Còn tiếp…"** (`EndingScreen`, lớp 95) tự hiện — không cần làm gì.

Kiểm tra: `godot --headless --path . -s res://tests/run_tests.gd` → vẫn 171 test PASS (gồm bot chơi thử trọn MVP).
