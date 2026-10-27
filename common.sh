# export.sh·import.sh 가 함께 씁니다.

require_macos() {
  if [ "$(uname -s)" != Darwin ]; then
    echo "macOS 에서만 씁니다: $(uname -s)" >&2
    return 1
  fi
}

manifest() {
  grep -v -e '^#' -e '^[[:space:]]*$' files.txt
}

# 이 기기와 마지막으로 맞춘(import·export) config/ 의 지문을 .git 안에 둡니다. 기기마다 따로이고 커밋되지 않습니다.
sync_mark() {
  echo "$(git rev-parse --git-dir)/mac-setting-sync"
}

config_files() {
  [ -d config ] || return 0
  (cd config && find . -type f ! -name .DS_Store | sed 's|^\./||' | LC_ALL=C sort)
}

config_digest() {
  config_files | while IFS= read -r f; do shasum "config/$f"; done | shasum | cut -d ' ' -f 1
}

mark_synced() {
  config_digest > "$(sync_mark)"
}

# 공개 저장소에 올리면 안 되는 흔적을 찾습니다. 맞는 줄을 출력하고, 있으면 0 을 돌려줍니다.
scan_secrets() {
  local targets=()
  [ -d config ] && targets+=(config)
  [ -f Brewfile ] && targets+=(Brewfile)
  [ ${#targets[@]} -gt 0 ] || return 1
  grep -rnEi \
    -e '(token|secret|password|passwd|api[_-]?key)[[:space:]]*[=:]' \
    -e 'email[[:space:]]*=' \
    -e '/Users/' \
    -e '-----BEGIN' \
    -e 'gh[pousr]_[A-Za-z0-9]{20,}' \
    -e 'AKIA[0-9A-Z]{16}' \
    "${targets[@]}"
}
