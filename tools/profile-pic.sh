#!/usr/bin/env bash
# Add profile pictures for the sidebar's random photo, and refresh the list in index.html.
#
#   - each input keeps its original shape, resized to 800px wide (never upscaled),
#     with all metadata (incl. GPS) stripped; taller photos push the sidebar links down
#   - saved as asset/media/profile/pfp-<name>.jpg
#   - then the data-photos list on the sidebar <img id="profile-pic"> in index.html is
#     rewritten from every pfp-*.jpg in that folder
#
# Usage:
#   tools/profile-pic.sh [-n NAME] PHOTO [PHOTO ...]
#   tools/profile-pic.sh            # no photos: just refresh the list (e.g. after deleting one)
#
#   -n  output name (only with a single photo); default is the input's file name
#
# Needs: ImageMagick 7 (magick)
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
dir="$root/asset/media/profile"
index="$root/index.html"

name=""
while getopts "n:h" opt; do
  case "$opt" in
    n) name="$OPTARG" ;;
    *) sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//'; exit 1 ;;
  esac
done
shift $((OPTIND - 1))
[ -z "$name" ] || [ $# -le 1 ] || { echo "error: -n works with a single photo" >&2; exit 1; }

command -v magick >/dev/null || { echo "error: magick (ImageMagick 7) not found" >&2; exit 1; }

for f in "$@"; do
  [ -f "$f" ] || { echo "skip: $f (not a file)" >&2; continue; }
  base=${name:-$(basename "$f")}; base=${base%.*}; base=${base#pfp-}
  out="$dir/pfp-$base.jpg"

  # Keep the original aspect ratio; 800px wide is plenty for the ~230px sidebar on 2x screens.
  magick "$f[0]" -auto-orient -resize '800x>' -strip -quality 85 -interlace JPEG "$out"
  echo "$f -> $out ($(du -h "$out" | cut -f1))"
done

# Rewrite data-photos="..." on the profile <img> from the folder's pfp-*.jpg files.
list=$(cd "$dir" && ls pfp-*.jpg 2>/dev/null | sed 's#^#asset/media/profile/#' | paste -sd, -)
[ -n "$list" ] || { echo "error: no pfp-*.jpg files in $dir" >&2; exit 1; }
grep -q 'id="profile-pic"' "$index" || { echo "error: no <img id=\"profile-pic\"> in index.html" >&2; exit 1; }
# (id and data-photos must stay on the same line of the <img> tag)
sed -i -E "/id=\"profile-pic\"/ s#data-photos=\"[^\"]*\"#data-photos=\"$list\"#" "$index"
grep -q "id=\"profile-pic\" data-photos=\"$list\"" "$index" || {
  echo "error: couldn't update data-photos in index.html; keep it right after id=\"profile-pic\" on one line" >&2
  exit 1
}
echo "index.html now rotates: $(echo "$list" | tr ',' ' ')"
