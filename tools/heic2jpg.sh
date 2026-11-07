#!/usr/bin/env bash
# Convert iPhone HEIC photos to web-friendly JPGs.
#   - resized to fit 1600x1600 (never upscaled), quality 82, progressive
#   - all metadata stripped (including GPS location)
#   - named <capture date>-<number>.jpg, e.g. IMG_3580.HEIC -> 2026-09-24-3580.jpg
#
# Usage: tools/heic2jpg.sh [-o OUTDIR] FILE.HEIC [FILE.HEIC ...]
# Needs: ffmpeg (decodes HEIC), ImageMagick 7 (magick)
set -euo pipefail

usage() { echo "Usage: $0 [-o OUTDIR] FILE.HEIC [...]" >&2; exit 1; }

outdir="."
while getopts "o:h" opt; do
  case "$opt" in
    o) outdir="$OPTARG" ;;
    *) usage ;;
  esac
done
shift $((OPTIND - 1))
[ $# -gt 0 ] || usage

for cmd in ffmpeg magick; do
  command -v "$cmd" >/dev/null || { echo "error: $cmd not found" >&2; exit 1; }
done
mkdir -p "$outdir"

for f in "$@"; do
  [ -f "$f" ] || { echo "skip: $f (not a file)" >&2; continue; }

  base=$(basename "$f"); base=${base%.*}; base=${base#IMG_}

  # Capture date from EXIF (DateTimeOriginal is stored as "YYYY:MM:DD HH:MM:SS")
  date=$(grep -a -o -m1 '[0-9]\{4\}:[0-9][0-9]:[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9]' "$f" | head -n1 | cut -c1-10 | tr ':' '-' || true)
  name=${date:+$date-}$base
  out="$outdir/$name.jpg"

  ffmpeg -v error -i "$f" -frames:v 1 -f image2pipe -c:v png - |
    magick png:- -resize '1600x1600>' -strip -quality 82 -sampling-factor 4:2:0 -interlace JPEG "$out"

  echo "$f -> $out ($(du -h "$out" | cut -f1))"
done
