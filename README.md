# mac-setting

어느 Mac 에서나 같은 개인 설정(셸·git·ssh·Claude Code·앱 설정·Homebrew 목록·macOS 시스템 설정)을 쓰기 위한 저장소입니다.
홈 폴더를 통째로 올리지 않고 `files.txt` 에 적은 것만 담습니다. [android-studio-setting](https://github.com/3dagger/android-studio-setting) 과 같은 방식입니다.

Android Studio 설정은 여기가 아니라 `android-studio-setting` 이 맡습니다.

## 담긴 설정

원본은 `config/` 입니다. `./export.sh` 로 설정이 바뀌면 이 목록도 함께 고칩니다.

| 분류 | 요약 | 파일 |
|---|---|---|
| 셸 | zsh 설정. 기기마다 다른 값은 `~/.zshrc.local` | `config/.zshrc`, `.zprofile`, `.zshenv` |
| git | 별칭·전역 ignore. 이름·이메일은 `~/.gitconfig.local` | `config/.gitconfig`, `.gitignore_global` |
| ssh | 호스트 별칭만. 키는 담지 않음 | `config/.ssh/config` |
| Claude Code | 전역 설정·지시문 | `config/.claude/settings.json`, `.claude/CLAUDE.md` |
| 앱 | Karabiner 키 매핑 | `config/.config/karabiner/karabiner.json` |
| Homebrew | 설치된 포뮬러·cask·App Store 앱 목록 | `Brewfile` |
| macOS | 키 반복·Finder·Dock·스크린샷 | `macos.sh` |

### 기기마다 다른 값은 `.local` 로

저장소 쪽 파일은 끝에서 기기별 파일을 읽고, 기기별 파일은 저장소에 넣지 않습니다.

```zsh
# ~/.zshrc 맨 끝
[ -f ~/.zshrc.local ] && source ~/.zshrc.local   # 회사 프록시·토큰·사내 경로
```

```ini
# ~/.gitconfig
[include]
    path = ~/.gitconfig.local   # [user] name·email, 회사 credential helper
```

### macOS 시스템 설정 — `macos.sh`

`~/Library/Preferences` 의 plist 는 파일로 복사하면 `cfprefsd` 캐시에 되돌아가므로 담지 않고, `defaults write` 명령을 `macos.sh` 에 모읍니다. 몇 번 돌려도 결과가 같습니다. `./macos.sh --dry-run` 으로 명령만 볼 수 있습니다.
설정을 바꿨으면 `defaults read <도메인> <키>` 로 값을 확인해 스크립트에 한 줄 더합니다. `export.sh` 는 이 파일을 만들지 않습니다.

## 새 Mac 에서

1. Xcode Command Line Tools 와 [Homebrew](https://brew.sh) 를 설치합니다.
2. 받아서 바뀔 것을 보고 넣습니다.
   ```bash
   git clone https://github.com/3dagger/mac-setting.git ~/mac-setting
   cd ~/mac-setting
   ./import.sh --dry-run
   ./import.sh
   ```
3. `~/.zshrc.local`·`~/.gitconfig.local` 을 만들어 이 기기의 값을 넣습니다.
4. 앱과 시스템 설정을 넣습니다.
   ```bash
   brew bundle --file=Brewfile
   ./macos.sh --dry-run && ./macos.sh
   ```

덮이거나 지운 파일은 `backup/<시각>/` 에 남습니다(커밋하지 않습니다).

## 기기 사이 동기화

집 Mac·회사 Mac 어디서든 바꾸고 올릴 수 있습니다. 순서만 지킵니다.

**받기** — 다른 기기에서 올린 설정을 이 기기에 넣습니다.

```bash
git pull --rebase
./import.sh --dry-run   # 바뀔 것: + 새로, ~ 바뀜, - 지움
./import.sh
```

**올리기** — 이 기기에서 바꾼 설정을 올립니다. **pull 보다 export 가 먼저**입니다.

```bash
./export.sh             # config/ 와 Brewfile 을 새로 채우고, 올리면 안 될 줄을 찾아 알립니다
git diff
git add -A && git commit -m "..."
git pull --rebase       # 다른 기기의 변경과 합칩니다
./import.sh             # pull 로 받은 변경이 있으면
git push
```

- pull 만 하고 import 하지 않은 채 export 하면 받은 변경을 되돌리게 됩니다. 기기마다 마지막으로 맞춘 `config/` 의 지문을 `.git/mac-setting-sync` 에 두고, `export.sh` 가 이를 보고 멈춥니다. 처음 쓰는 기기도 import 를 한 번 한 뒤에 export 할 수 있습니다. `config/` 가 비어 있는 새 저장소에서만 바로 export 합니다.
- Claude Code 에게 맡기면 이 저장소의 `CLAUDE.md` 순서(차이를 먼저 보여 주고 확인받기)를 따릅니다.

## 동작

- `export.sh` 는 `config/` 를 매번 새로 채웁니다. 지운 설정도 diff 에 나옵니다. 심볼릭 링크는 가리키는 내용을 담습니다. `Brewfile` 은 `brew bundle dump` 로 통째로 다시 씁니다.
- `import.sh` 는 홈 폴더를 `config/` 에 맞춥니다. `files.txt` 범위 안에서 저장소에 없는 파일은 홈에서도 지웁니다(다른 기기에서 지운 설정이 살아나지 않게). 범위 밖 파일은 건드리지 않습니다. `.ssh/` 아래는 권한을 600 으로 맞춥니다. Homebrew 설치와 `macos.sh` 는 돌리지 않고 안내만 합니다.
- `export.sh` 가 끝나며 `config/`·`Brewfile` 에서 토큰·비밀번호·이메일·`/Users/…` 경로·개인 키 같은 줄을 찾아 보여 줍니다. 막지는 않으니 커밋 전에 봅니다.
- 심볼릭 링크를 쓰지 않습니다. 홈 폴더에 일반 파일로 둡니다.

## 담는 것 / 뺀 것

담는 것은 `files.txt` 가 전부입니다. 새 설정을 담으려면 한 줄 추가하고 `./export.sh` 합니다.

**공개 저장소입니다.** 아래는 일부러 뺐고, 새로 추가할 파일도 먼저 열어 키·토큰·계정·`/Users/…` 경로·회사 이름이 없는지 확인합니다.

| 뺀 것 | 이유 |
|---|---|
| `~/.ssh/id_*`, `known_hosts`, `~/.gnupg/`, `~/.aws/`, `~/.netrc`, `~/.config/gh/hosts.yml` | 키·토큰 |
| `~/.zsh_history`, `~/.gitconfig` 의 `[user]`, `~/.zshrc.local`, `~/.gitconfig.local` | 계정·기기별 값 |
| `~/Library/Preferences/*.plist` | `cfprefsd` 캐시 때문에 파일 복사가 듣지 않음 — `macos.sh` 의 `defaults write` 로 대신 |
| iTerm2 설정 | plist — iTerm2 의 Settings > General > Preferences 에서 "Load preferences from a custom folder" 로 이 저장소 폴더를 가리키는 쪽이 맞음(담으려면 그때 `files.txt` 에 추가) |
| `~/.claude/` 의 `projects/`, `todos/`, `statsig/`, `*.jsonl` | 세션 기록·캐시 |
| `~/.oh-my-zsh/`, `~/.zsh/plugins/` | 플러그인 본체 — `.zshrc` 가 설치 명령을 들고 있거나 `Brewfile` 로 설치 |
| Homebrew 가 설치한 것 자체 | `Brewfile` 목록만 담고 설치는 `brew bundle` |
