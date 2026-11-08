#!/usr/bin/env bash
# Add profile pictures for the sidebar's random photo, and refresh the list in index.html.
#
#   - every photo becomes the same size: a 2:3 portrait, 800x1200, cropped to that shape
#     (so the sidebar doesn't change height between visits), all metadata (incl. GPS) stripped
#   - saved as asset/media/profile/pfp-<name>.jpg
#   - then the data-photos list on the sidebar <img id="profile-pic"> in index.html is
#     rewritten from every pfp-*.jpg in that folder (and the <noscript> fallback uses the first)
#
# Usage:
#   tools/profile-pic.sh [-g center|north] [-n NAME] PHOTO [PHOTO ...]
#   tools/profile-pic.sh            # no photos: just refresh the list (e.g. after deleting one)
#
#   -g  which part to keep when cropping to 2:3: center (default) or north (top)
#   -n  output name (only with a single photo); default is the input's file name
#
# Needs: ImageMagick 7 (magick)
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
dir="$root/asset/media/profile"
index="$root/index.html"

gravity="center"
name=""
while getopts "g:n:h" opt; do
  case "$opt" in
    g) gravity="$OPTARG" ;;
    n) name="$OPTARG" ;;
    *) sed -n '2,18p' "$0" | sed 's/^# \{0,1\}//'; exit 1 ;;
  esac
done
shift $((OPTIND - 1))
case "$gravity" in north | center) ;; *) echo "error: -g must be center or north" >&2; exit 1 ;; esac
[ -z "$name" ] || [ $# -le 1 ] || { echo "error: -n works with a single photo" >&2; exit 1; }

command -v magick >/dev/null || { echo "error: magick (ImageMagick 7) not found" >&2; exit 1; }

for f in "$@"; do
  [ -f "$f" ] || { echo "skip: $f (not a file)" >&2; continue; }
  base=${name:-$(basename "$f")}; base=${base%.*}; base=${base#pfp-}
  out="$dir/pfp-$base.jpg"

  # Crop to the largest 2:3 area (keeping the centre or the top), then resize to 800x1200.
  magick "$f[0]" -auto-orient -gravity "$gravity" \
    -crop "%[fx:min(w,h*2/3)]x%[fx:min(h,w*3/2)]+0+0" +repage \
    -resize '800x1200!' -strip -quality 85 -interlace JPEG "$out"
  echo "$f -> $out ($(du -h "$out" | cut -f1))"
done

# Rewrite data-photos="..." on the profile <img> from the folder's pfp-*.jpg files.
# Each URL gets ?v=<content hash>, so a replaced photo gets a new URL and no browser or
# CDN cache can serve the old one (an old photo in the new 2:3 box would look squished).
list=$(cd "$dir" && for p in pfp-*.jpg; do [ -f "$p" ] && echo "asset/media/profile/$p?v=$(md5sum "$p" | cut -c1-8)"; done | paste -sd, -)
[ -n "$list" ] || { echo "error: no pfp-*.jpg files in $dir" >&2; exit 1; }
grep -q 'id="profile-pic"' "$index" || { echo "error: no <img id=\"profile-pic\"> in index.html" >&2; exit 1; }
# (id and data-photos must stay on the same line of the <img> tag)
sed -i -E "/id=\"profile-pic\"/ s#data-photos=\"[^\"]*\"#data-photos=\"$list\"#" "$index"
grep -qF "id=\"profile-pic\" data-photos=\"$list\"" "$index" || {
  echo "error: couldn't update data-photos in index.html; keep it right after id=\"profile-pic\" on one line" >&2
  exit 1
}
# No-JS fallback: the first photo in the list.
first=${list%%,*}
sed -i -E "s#src=\"asset/media/profile/[^\"]*\"></noscript>#src=\"$first\"></noscript>#" "$index"
echo "index.html now rotates: $(echo "$list" | tr ',' ' ')"
