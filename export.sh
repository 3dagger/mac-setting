#!/usr/bin/env bash
# 이 Mac 의 설정 중 files.txt 에 적힌 것만 config/ 로 내보내고, Homebrew 설치 목록을 Brewfile 로 뽑습니다.
# 사용: ./export.sh
set -euo pipefail
cd "$(dirname "$0")"
source ./common.sh
require_macos

# 이 기기에 아직 넣지 않은 변경(다른 기기에서 받은 것)이 config/ 에 있으면, 내보내기가 그것을 되돌립니다.
# config/ 가 비어 있으면(처음 만드는 저장소) 되돌릴 것이 없으니 그냥 내보냅니다.
if [ -n "$(config_files)" ] && [ "$(cat "$(sync_mark)" 2> /dev/null)" != "$(config_digest)" ]; then
  echo "config/ 가 이 기기에서 마지막으로 맞춘 뒤 바뀌었습니다(다른 기기의 변경을 받았거나 이 기기에서 처음 씁니다)." >&2
  echo "./import.sh --dry-run 으로 차이를 보고 ./import.sh 로 넣은 뒤 내보내세요." >&2
  exit 1
fi

echo "내보내는 곳: $HOME"

# 지운 설정도 반영되도록 매번 새로 담습니다. 심볼릭 링크는 가리키는 내용을 담습니다.
rm -rf config
mkdir -p config
while IFS= read -r path; do
  if [ ! -e "$HOME/$path" ]; then
    echo "  없음(건너뜀): $path"
    continue
  fi
  mkdir -p "config/$(dirname "$path")"
  cp -RL "$HOME/$path" "config/$path"
done < <(manifest)
find config -name .DS_Store -delete

if command -v brew > /dev/null; then
  brew bundle dump --force --file=Brewfile
  echo "Brewfile: $(grep -cE '^(brew|cask|mas|tap|vscode) ' Brewfile) 줄"
else
  echo "  Homebrew 가 없어 Brewfile 을 건너뜁니다."
fi

mark_synced

if found=$(scan_secrets); then
  echo
  echo "⚠ 공개 저장소에 올리면 안 될 수 있는 줄입니다. 커밋 전에 확인하세요:"
  echo "$found" | sed 's/^/  /'
fi

echo "완료. git status·git diff 로 바뀐 것을 확인한 뒤 커밋하세요."
