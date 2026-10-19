#!/usr/bin/env python3
"""Tạo âm thanh dị tượng (bước 6) bằng thư viện chuẩn, tất định.

44.100 Hz, 16 bit, mono, đỉnh ≤ −6 dBFS.
- hum_25hz_tuong_trung.wav: s(t) = (1 + 0,6·sin 2π·25t)·sin 2π·200t, đúng 1,00 s
  (200 chu kỳ sóng mang + 25 chu kỳ điều biên → nối vòng không vấp). Phổ: 175, 200, 225 Hz.
- radar_tick.wav: tiếng tách ngắn ~30 ms.
- nhieu_nhe.wav: nhiễu trắng lọc thấp, 1,00 s, rất nhỏ.
Chạy: python3 tools/gen_audio.py
"""
import math
import random
import struct
import wave
from pathlib import Path

RATE = 44100
PEAK = 10 ** (-6 / 20)  # −6 dBFS
OUT = Path(__file__).resolve().parent.parent / "audio" / "sfx"


def write(name, samples):
    OUT.mkdir(parents=True, exist_ok=True)
    biggest = max(abs(x) for x in samples) or 1.0
    scale = PEAK / biggest
    with wave.open(str(OUT / name), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b"".join(struct.pack("<h", int(round(x * scale * 32767))) for x in samples))


def hum():
    fc, fm, m = 200.0, 25.0, 0.6
    return [(1 + m * math.sin(2 * math.pi * fm * i / RATE)) * math.sin(2 * math.pi * fc * i / RATE)
            for i in range(RATE)]


def tick():
    n = int(RATE * 0.03)
    rng = random.Random(7)
    return [rng.uniform(-1, 1) * math.exp(-i / (n / 6)) for i in range(n)]


def noise():
    rng = random.Random(11)
    out, prev = [], 0.0
    for _ in range(RATE):
        prev = prev * 0.95 + rng.uniform(-1, 1) * 0.05  # lọc thấp một cực
        out.append(prev)
    # Làm mềm 2 đầu để nối vòng êm.
    fade = int(RATE * 0.02)
    for i in range(fade):
        k = i / fade
        out[i] *= k
        out[-1 - i] *= k
    return [x * 0.25 for x in out]


if __name__ == "__main__":
    write("hum_25hz_tuong_trung.wav", hum())
    write("radar_tick.wav", tick())
    write("nhieu_nhe.wav", noise())
    for name in ("hum_25hz_tuong_trung.wav", "radar_tick.wav", "nhieu_nhe.wav"):
        with wave.open(str(OUT / name)) as w:
            frames = w.getnframes()
            data = w.readframes(frames)
            peak = max(abs(v) for v in struct.unpack("<%dh" % frames, data)) / 32767
            print(f"{name}: {w.getframerate()} Hz, {w.getnchannels()} kênh, {8 * w.getsampwidth()} bit, "
                  f"{frames / w.getframerate():.2f} s, đỉnh {20 * math.log10(peak):.1f} dBFS")
