#!/usr/bin/env python3
"""Mô phỏng dòng tiền 14 ngày đầu (tới hạn học phí HK1) cho 3 chế độ chơi.

Đọc số liệu trực tiếp từ data/*.tres, chạy cùng luật với scripts/life/life_sim.gd
(bản rút gọn bằng Python để chạy được khi không có Godot).
Chạy: python3 tools/sim_cashflow.py
"""
import random
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MORNING, AFTERNOON, EVENING, NIGHT = range(4)


def read_tres(path):
    values = {}
    for line in (ROOT / path).read_text(encoding="utf-8").splitlines():
        m = re.match(r"^(\w+) = (.+)$", line)
        if not m or m.group(1) == "script":
            continue
        raw = m.group(2)
        if raw.startswith('"'):
            values[m.group(1)] = raw.strip('"')
        elif raw.startswith("Array["):
            inner = raw[raw.index("([") + 2: raw.rindex("])")]
            values[m.group(1)] = [int(x) if x.strip().lstrip("-").isdigit() else x.strip().strip('"')
                                  for x in inner.split(",") if x.strip()]
        elif raw in ("true", "false"):
            values[m.group(1)] = raw == "true"
        else:
            values[m.group(1)] = float(raw) if "." in raw else int(raw)
    return values


ECO = read_tres("data/economy.tres")
DECAY = read_tres("data/time_decay.tres")
ACT = {p.stem: read_tres(f"data/actions/{p.name}") for p in (ROOT / "data/actions").glob("*.tres")}
ITEM = {p.stem: read_tres(f"data/items/{p.name}") for p in (ROOT / "data/items").glob("*.tres")}
SUBJ = [read_tres(f"data/subjects/{p.name}") for p in sorted((ROOT / "data/subjects").glob("*.tres"))]
DIFF = {d: read_tres(f"data/difficulty_{d}.tres") for d in ("easy", "hard", "extreme")}


def make_schedule(seed):
    """Xếp TKB thỏa ràng buộc (cùng ràng buộc với ScheduleGenerator, khác thuật toán ngẫu nhiên)."""
    rng = random.Random(seed)
    sessions = [s["id"] for s in SUBJ for _ in range(s.get("sessions_per_week", 1))]
    cells = [(d, s) for d in range(5) for s in (0, 1)]

    def place(i, res):
        if i == len(sessions):
            return True
        order = cells[:]
        rng.shuffle(order)
        for d, s in order:
            if any(r[0] == d and r[1] == s for r in res):
                continue
            if sum(1 for r in res if r[0] == d) >= 2:
                continue
            if any(r[2] == sessions[i] and abs(r[0] - d) < 2 for r in res):
                continue
            res.append((d, s, sessions[i]))
            if place(i + 1, res):
                return True
            res.pop()
        return False

    res = []
    place(0, res)
    return {(d, s): subj for d, s, subj in res}


class Sim:
    def __init__(self, diff, seed, room_fund):
        cfg = DIFF[diff]
        self.mult = cfg.get("decay_multiplier", 1.0)
        self.wage_mult = cfg.get("wage_multiplier", 1.0)
        self.money = cfg["starting_money"]
        self.st = {"stamina": 100, "hunger": 80, "sanity": 80}
        self.day, self.slot = 1, MORNING
        self.schedule = make_schedule(seed)
        self.rng = random.Random(seed * 7 + 1)
        self.shifts = 0
        self.total_shifts = 0
        self.min_stamina = 100
        self.faints = 0
        self.room_fund = room_fund
        self.charge_day(1)

    def clamp(self):
        for k in self.st:
            self.st[k] = max(0, min(100, self.st[k]))
        self.min_stamina = min(self.min_stamina, self.st["stamina"])

    def charge_day(self, day):
        if (day - 1) % ECO["month_length_days"] == 0:
            self.money -= ECO["ktx_fee"]
            if self.room_fund:
                self.money -= ECO["room_fund_fee"]

    def advance(self):
        self.st["hunger"] -= round(DECAY["hunger_per_slot"] * self.mult)
        self.st["stamina"] -= round(DECAY["stamina_per_slot"] * self.mult)
        self.clamp()
        if self.st["hunger"] <= 0:
            self.st["stamina"] -= ECO["starving_stamina_per_slot"]
        elif self.st["hunger"] < ECO["hungry_threshold"]:
            self.st["stamina"] -= ECO["hungry_stamina_per_slot"]
        self.clamp()
        self.slot += 1
        if self.slot == 4:
            self.slot = MORNING
            self.day += 1
            self.shifts = 0
            self.charge_day(self.day)

    def class_now(self):
        if self.day < ECO["classes_start_day"]:
            return None
        return self.schedule.get(((self.day - 1) % 7, self.slot))

    def eat_cheapest(self):
        # Giữ Đói >= 40 bằng món rẻ nhất tính theo đồng/điểm no.
        foods = sorted((i for i in ITEM.values() if i.get("hunger", 0) >= 12),
                       key=lambda i: i["price"] / i["hunger"])
        while self.st["hunger"] < 40:
            item = foods[0]
            self.money -= item["price"]
            self.st["hunger"] += item["hunger"]
            self.clamp()

    def act(self, name):
        a = ACT[name]
        self.st["stamina"] += a.get("stamina", 0)
        self.st["hunger"] += a.get("hunger", 0)
        self.st["sanity"] += a.get("sanity", 0)
        self.clamp()
        if a.get("counts_as_shift"):
            wage = a.get("base_wage", 0) + self.rng.randint(0, a.get("tip_max", 0))
            self.money += round(wage * self.wage_mult / 1000) * 1000
            self.shifts += 1
            self.total_shifts += 1
        self.advance()
        if self.st["stamina"] <= 0:
            self.faints += 1
            self.advance()
            self.st["stamina"] = ECO["faint_stamina"]

    def sleep(self):
        bonus = ECO["early_sleep_bonus_stamina"] if self.slot == EVENING else 0
        start_day = self.day
        while not (self.day == start_day + 1 and self.slot == MORNING):
            self.advance()
        rec = ACT["ngu"]["stamina"] + bonus
        if self.st["hunger"] < ECO["hungry_threshold"]:
            rec //= 2
        self.st["stamina"] += rec
        self.st["sanity"] += ACT["ngu"]["sanity"]
        self.clamp()

    def run(self, last_day):
        while self.day <= last_day:
            self.eat_cheapest()
            if self.class_now():
                self.act("di_hoc")
            elif self.slot == NIGHT:
                self.sleep()
            elif self.shifts < ECO["max_shifts_per_day"] and self.st["stamina"] > 25:
                if self.slot == EVENING:
                    self.act("bung_ca_phe")
                else:
                    self.act("lam_quan_com")
            elif self.slot == EVENING:
                self.sleep()
            else:
                self.act("nghi")
        return self


def fmt(n):
    return f"{n:,}".replace(",", ".")


def main():
    due = ECO["tuition_amount"]
    print("Mô phỏng tới hết ngày 14 — chiến lược chăm chỉ (đi học đủ, tối đa 2 ca/ngày, ăn rẻ nhất giữ Đói ≥ 40)")
    print(f"Học phí cần: {fmt(due)} đ · 20 seed TKB\n")
    print(f"{'Chế độ':<9}{'Quỹ phòng':<11}{'Tiền ngày 15 (TB)':>19}{'So với học phí':>17}{'Ca/14 ngày':>12}{'Thể lực min':>13}{'Ngất':>6}")
    for diff, label in (("easy", "Dễ"), ("hard", "Khó"), ("extreme", "Cực khó")):
        for fund in (False, True):
            runs = [Sim(diff, seed, fund).run(14) for seed in range(20)]
            avg = sum(r.money for r in runs) // len(runs)
            gap = avg - due
            print(f"{label:<9}{'có' if fund else 'không':<11}{fmt(avg):>19}{('+' if gap >= 0 else '') + fmt(gap):>17}"
                  f"{sum(r.total_shifts for r in runs) / len(runs):>12.1f}{min(r.min_stamina for r in runs):>13}"
                  f"{sum(r.faints for r in runs) / len(runs):>6.1f}")


if __name__ == "__main__":
    main()
