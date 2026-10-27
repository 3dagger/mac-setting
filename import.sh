#!/usr/bin/env bash
# config/ 의 설정을 이 Mac 의 홈 폴더에 맞춥니다. files.txt 범위에서 저장소에 없는 파일은 지웁니다.
# 덮이거나 지워지는 파일은 backup/ 에 먼저 둡니다.
# 사용: ./import.sh [--dry-run]
#   --dry-run: 아무것도 바꾸지 않고 바뀔 파일과 차이만 보여 줍니다.
# Homebrew 설치(Brewfile)와 macOS 시스템 설정(macos.sh)은 따로 돌립니다. 끝에 안내합니다.
set -euo pipefail
cd "$(dirname "$0")"
source ./common.sh
require_macos

dry_run=false
if [ "${1:-}" = --dry-run ]; then
  dry_run=true
fi

if [ -z "$(config_files)" ]; then
  echo "config/ 가 비어 있습니다. 먼저 설정이 있는 Mac 에서 ./export.sh 로 채워 올리세요." >&2
  exit 1
fi
echo "넣는 곳: $HOME"

# 한 줄에 하나씩 "+ 경로"(새로 넣음), "~ 경로"(바뀜), "- 경로"(지움)입니다.
changes() {
  config_files | while IFS= read -r f; do
    if [ ! -e "$HOME/$f" ]; then
      echo "+ $f"
    elif ! cmp -s "$HOME/$f" "config/$f"; then
      echo "~ $f"
    fi
  done
  manifest | while IFS= read -r path; do
    [ -e "$HOME/$path" ] || continue
    (cd "$HOME" && find -L "$path" -type f ! -name .DS_Store)
  done | LC_ALL=C sort | while IFS= read -r f; do
    [ -e "config/$f" ] || echo "- $f"
  done
}

list=$(changes)
if [ -z "$list" ]; then
  echo "차이 없음"
  $dry_run || mark_synced
else
  echo "$list"
  if $dry_run; then
    echo "$list" | while read -r op f; do
      [ "$op" = "~" ] || continue
      diff -u -L "이 Mac: $f" -L "저장소: $f" "$HOME/$f" "config/$f" || true
    done
  else
    backup="$PWD/backup/$(date +%Y%m%d-%H%M%S)"
    echo "$list" | while read -r op f; do
      if [ -e "$HOME/$f" ]; then
        mkdir -p "$backup/$(dirname "$f")"
        cp -p "$HOME/$f" "$backup/$f"
      fi
      if [ "$op" = - ]; then
        rm "$HOME/$f"
      else
        mkdir -p "$HOME/$(dirname "$f")"
        cp "config/$f" "$HOME/$f.tmp"
        mv "$HOME/$f.tmp" "$HOME/$f"
        # ssh 는 권한이 넓으면 읽지 않습니다.
        case "$f" in .ssh/*) chmod 600 "$HOME/$f" ;; esac
      fi
    done
    mark_synced
    [ -d "$backup" ] && echo "덮이거나 지운 파일 백업: $backup"
    echo "완료. 셸 설정은 새 터미널을 열거나 'exec zsh' 로 다시 읽습니다."
  fi
fi

echo
if [ -f Brewfile ] && command -v brew > /dev/null; then
  echo "Homebrew — 빠진 것:"
  brew bundle check --file=Brewfile --verbose 2>&1 | sed 's/^/  /' || true
  echo "  설치: brew bundle --file=Brewfile"
fi
echo "macOS 시스템 설정: ./macos.sh --dry-run 으로 보고 ./macos.sh 로 적용"
