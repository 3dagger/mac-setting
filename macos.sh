#!/usr/bin/env bash
# macOS 시스템 설정입니다. 파일을 복사하지 않고 defaults 명령으로 넣습니다
# (~/Library/Preferences 의 plist 는 cfprefsd 가 캐시하고 있어 파일을 덮어써도 돌아갑니다).
# 몇 번 돌려도 결과가 같습니다. 손으로 관리하며, export.sh 가 만들지 않습니다.
# 사용: ./macos.sh [--dry-run]   (--dry-run: 명령만 보여 주고 바꾸지 않습니다)
# 지금 값 보기: defaults read <도메인> <키>   예) defaults read NSGlobalDomain KeyRepeat
set -euo pipefail

dry_run=false
[ "${1:-}" = --dry-run ] && dry_run=true

run() {
  echo "  $*"
  $dry_run || "$@"
}

echo "키보드"
run defaults write NSGlobalDomain KeyRepeat -int 2                        # 키 반복 속도(작을수록 빠름, UI 최소 2)
run defaults write NSGlobalDomain InitialKeyRepeat -int 15                # 반복 시작까지(작을수록 짧음, UI 최소 15)
run defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false    # 길게 눌러도 악센트 창 대신 반복
run defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false   # 따옴표 자동 변환 끔(코드 붙여넣기)
run defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false    # 대시 자동 변환 끔
run defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false  # 스페이스 두 번 → 마침표 끔
run defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false  # 자동 교정 끔

echo "트랙패드"
run defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true                    # 탭해서 클릭
run defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

echo "Finder"
run defaults write NSGlobalDomain AppleShowAllExtensions -bool true               # 확장자 항상 표시
run defaults write com.apple.finder ShowPathbar -bool true                        # 경로 막대
run defaults write com.apple.finder ShowStatusBar -bool true                      # 상태 막대
run defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false    # 확장자 바꿀 때 확인 창 끔
run defaults write com.apple.finder FXDefaultSearchScope -string SCcf             # 검색 범위: 지금 폴더
run defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true  # 네트워크 드라이브에 .DS_Store 안 만듦

echo "Dock"
run defaults write com.apple.dock autohide -bool true        # 자동 숨김
run defaults write com.apple.dock show-recents -bool false   # 최근 앱 영역 끔

echo "스크린샷"
run mkdir -p "$HOME/Screenshots"
run defaults write com.apple.screencapture location -string "$HOME/Screenshots"   # 바탕화면 대신 ~/Screenshots
run defaults write com.apple.screencapture type -string png

echo "적용"
run killall Dock Finder SystemUIServer
$dry_run || echo "키보드·트랙패드 설정은 로그아웃하면 모두 반영됩니다."
