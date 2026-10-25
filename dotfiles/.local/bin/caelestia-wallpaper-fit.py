#!/usr/bin/env python3

"""Prepare wallpapers with a blurred backdrop and a fully visible foreground."""

from __future__ import annotations

import hashlib
import json
import os
import subprocess
import sys
from pathlib import Path

from PIL import Image, ImageEnhance, ImageFilter, ImageOps


def active_monitors() -> list[tuple[str, int, int]]:
    try:
        result = subprocess.run(
            ["hyprctl", "-j", "monitors"],
            check=True,
            capture_output=True,
            text=True,
            timeout=0.5,
        )
        raw = json.loads(result.stdout)
    except (OSError, subprocess.SubprocessError, json.JSONDecodeError):
        return []

    monitors = []
    for monitor in raw:
        try:
            name = str(monitor["name"])
            width = int(monitor["width"])
            height = int(monitor["height"])
        except (KeyError, TypeError, ValueError):
            continue
        if name and width > 0 and height > 0:
            monitors.append((name, width, height))
    return monitors


def fitted_image(source: Path, width: int, height: int, cache: Path) -> Path:
    stat = source.stat()
    key = hashlib.sha256(
        f"{source}\0{stat.st_mtime_ns}\0{stat.st_size}\0{width}x{height}\0blur-fit-v1".encode()
    ).hexdigest()[:24]
    target = cache / f"{key}.jpg"
    if target.is_file():
        return target

    size = (width, height)
    with Image.open(source) as image:
        # Keep animated wallpapers animated; Awww will fit their frames itself.
        if getattr(image, "is_animated", False):
            return source

        foreground = ImageOps.exif_transpose(image).convert("RGBA")

    backdrop = ImageOps.fit(foreground.convert("RGB"), size, method=Image.Resampling.LANCZOS)
    blur_radius = max(18, round(min(width, height) * 0.03))
    backdrop = backdrop.filter(ImageFilter.GaussianBlur(blur_radius))
    backdrop = ImageEnhance.Color(backdrop).enhance(0.72)
    backdrop = ImageEnhance.Brightness(backdrop).enhance(0.66)

    canvas = backdrop.convert("RGBA")
    foreground = ImageOps.contain(foreground, size, method=Image.Resampling.LANCZOS)
    x = (width - foreground.width) // 2
    y = (height - foreground.height) // 2
    canvas.alpha_composite(foreground, (x, y))

    cache.mkdir(parents=True, exist_ok=True)
    canvas.convert("RGB").save(target, "JPEG", quality=92, optimize=True)
    return target


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: caelestia-wallpaper-fit.py IMAGE", file=sys.stderr)
        return 2

    source = Path(sys.argv[1]).expanduser()
    if not source.is_file():
        print(f"wallpaper not found: {source}", file=sys.stderr)
        return 1

    cache_root = Path(
        os.environ.get("XDG_CACHE_HOME", str(Path.home() / ".cache"))
    ) / "caelestia" / "awww-fit"

    monitors = active_monitors()
    if not monitors:
        # Native Awww fit still keeps the complete source image visible.
        print(f"*\t{source}")
        return 0

    for name, width, height in monitors:
        try:
            fitted = fitted_image(source, width, height, cache_root)
        except Exception as error:
            print(f"{name}\t{source}", file=sys.stdout)
            print(f"could not prepare {source} for {name}: {error}", file=sys.stderr)
            continue
        print(f"{name}\t{fitted}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
