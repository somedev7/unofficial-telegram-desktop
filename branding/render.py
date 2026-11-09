#!/usr/bin/env python3
"""Render branding/src/*.svg into the files tdesktop expects.

Output mirrors the tdesktop tree under branding/out/Telegram/Resources/,
so apply.sh can copy it over the upstream checkout as is.

    pip install cairosvg
    python3 branding/render.py
"""
import shutil
from pathlib import Path

import cairosvg

ROOT = Path(__file__).resolve().parent
SRC = ROOT / "src"
OUT = ROOT / "out" / "Telegram" / "Resources"
ICON_SIZES = (16, 32, 48, 64, 128, 256, 512)


def render(svg: str, target: Path, size: int) -> None:
    target.parent.mkdir(parents=True, exist_ok=True)
    cairosvg.svg2png(
        url=str(SRC / svg),
        write_to=str(target),
        output_width=size,
        output_height=size,
    )


def main() -> None:
    if OUT.exists():
        shutil.rmtree(OUT)
    art = OUT / "art"
    render("logo.svg", art / "logo_256.png", 256)
    render("logo_no_margin.svg", art / "logo_256_no_margin.png", 256)
    for size in ICON_SIZES:
        render("logo.svg", art / f"icon{size}.png", size)
        render("logo.svg", art / f"icon{size}@2x.png", size * 2)
    icons = OUT / "icons"
    icons.mkdir(parents=True, exist_ok=True)
    for name in ("tray_monochrome", "tray_monochrome_attention",
                 "tray_monochrome_mute"):
        shutil.copyfile(SRC / f"{name}.svg", icons / f"{name}.svg")
    for path in sorted(OUT.rglob("*")):
        if path.is_file():
            print(path.relative_to(ROOT))


if __name__ == "__main__":
    main()
