# shellcheck shell=bash
# PATH and errexit/nounset/pipefail come from writeShellApplication, which also
# prepends the real shebang. Running this file directly will not work.

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

find /srv/media/movies /srv/media/shows -name "*.mkv" | while read -r mkv; do
  dir=$(dirname "$mkv")
  base=$(basename "$mkv" .mkv)

  mkvmerge -J "$mkv" |
    jq -r '
      .tracks[]
      | select(.type == "subtitles"
          and (.properties.codec_id | startswith("S_HDMV/PGS")))
      | "\(.id) \(.properties.language // "und")"
    ' |
    while read -r track_id lang; do
      srt="$dir/$base.$lang.srt"
      [ -f "$srt" ] && continue

      sup="$tmpdir/$base.$track_id.sup"
      echo "pgs-to-srt: extracting track $track_id ($lang) from $mkv"
      mkvextract "$mkv" tracks "$track_id:$sup"

      echo "pgs-to-srt: converting $sup"
      pgsrip --language "$lang" "$sup"

      # pgsrip may add a language tag to the output name, so match on the stem.
      generated=$(find "$tmpdir" -maxdepth 1 -name "$base.$track_id*.srt" -print -quit)
      [ -n "$generated" ] && mv "$generated" "$srt"
      rm -f "$sup"
    done
done
