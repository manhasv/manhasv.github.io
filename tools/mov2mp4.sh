#!/usr/bin/env bash
# Convert iPhone MOV clips (HEVC) to web-friendly MP4s.
#   - H.264 at 720p / 30fps, which every browser can play
#   - audio removed by default (use -a to keep it)
#   - metadata stripped, "faststart" so playback starts before the download finishes
#   - also writes a poster frame: <name>-poster.jpg
#   - named <capture date>-<number>.mp4, e.g. IMG_3638.MOV -> 2026-10-08-3638.mp4
#
# Usage: tools/mov2mp4.sh [-o OUTDIR] [-a] FILE.MOV [FILE.MOV ...]
# Needs: ffmpeg, ffprobe
set -euo pipefail

usage() { echo "Usage: $0 [-o OUTDIR] [-a] FILE.MOV [...]" >&2; exit 1; }

outdir="."
audio=(-an)
while getopts "o:ah" opt; do
  case "$opt" in
    o) outdir="$OPTARG" ;;
    a) audio=(-map "0:a:0?" -c:a aac -b:a 128k) ;;
    *) usage ;;
  esac
done
shift $((OPTIND - 1))
[ $# -gt 0 ] || usage

for cmd in ffmpeg ffprobe; do
  command -v "$cmd" >/dev/null || { echo "error: $cmd not found" >&2; exit 1; }
done
mkdir -p "$outdir"

for f in "$@"; do
  [ -f "$f" ] || { echo "skip: $f (not a file)" >&2; continue; }

  base=$(basename "$f"); base=${base%.*}; base=${base#IMG_}

  # Capture date, e.g. creation_time=2026-10-08T15:35:02.000000Z -> 2026-10-08
  date=$(ffprobe -v error -show_entries format_tags=creation_time -of default=nw=1:nk=1 "$f" | cut -c1-10 || true)
  name=${date:+$date-}$base
  out="$outdir/$name.mp4"
  poster="$outdir/$name-poster.jpg"

  ffmpeg -v error -y -i "$f" -map 0:v:0 "${audio[@]}" \
    -vf "scale=-2:720,fps=30,format=yuv420p" \
    -c:v libx264 -preset slow -crf 26 -profile:v high \
    -movflags +faststart -map_metadata -1 "$out"

  ffmpeg -v error -y -ss 0.2 -i "$out" -frames:v 1 -q:v 4 "$poster"

  echo "$f -> $out ($(du -h "$out" | cut -f1)), $poster"
done
