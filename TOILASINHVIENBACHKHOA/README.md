# Tôi Là Sinh Viên Bách Khoa

Game 2D nhập vai + mô phỏng đời sinh viên + bí ẩn đô thị nhẹ. Godot 4.4+, GDScript.

- Tài liệu: `FEATURES.md`, `STORY_MVP.md`, `BALANCE.md`, `docs/ARCHITECTURE.md`, `docs/TASKS.md`, `docs/prompts/`
- Chạy game: mở thư mục TOILASINHVIENBACHKHOA bằng Godot 4.4+ → F5.
- Chạy test: `godot --headless --path . --import` (lần đầu) rồi `godot --headless --path . -s res://tests/run_tests.gd` (138 test)
- Mô phỏng dòng tiền: `python3 tools/sim_cashflow.py`
- Font tiếng Việt: xem `fonts/README.md`.
- Âm thanh dị tượng: `python3 tools/gen_audio.py`
