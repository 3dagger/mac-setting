# mac-setting 작업 규칙

여러 Mac(집·회사)의 개인 설정을 이 저장소로 주고받는다. **공개 저장소다.**
담는 범위는 `files.txt`, 동작은 README 의 "기기 사이 동기화"·"동작". Android Studio 설정은 `android-studio-setting` 저장소가 맡는다.

## 원칙
- 한국어로 답한다. 커밋 메시지에 AI 서명(Co-Authored-By 등)을 넣지 않는다.
- 설정은 스크립트로만 주고받는다(`export.sh`·`import.sh`·`macos.sh`). 홈 폴더의 설정 파일을 손으로 고치지 않는다.
- 쓰기 전에 보여 주고 확인받는다: import 전에는 `./import.sh --dry-run`, `macos.sh` 전에는 `./macos.sh --dry-run`, 커밋 전에는 `git diff` 요약. 푸시도 확인받는다.
- `brew bundle` 은 설치가 오래 걸리고 cask 는 관리자 암호를 물을 수 있다. 돌리기 전에 빠진 목록을 보여 주고 확인받는다.

## 받기 (저장소 → 이 기기)
1. `git pull --rebase`
2. `./import.sh --dry-run` — 바뀔 것(`+` 새로, `~` 바뀜, `-` 지움)을 요약해 보여 주고 확인받는다.
3. `./import.sh` → 끝에 나오는 Homebrew 빠진 목록을 알려 준다. 설치는 확인받고 `brew bundle --file=Brewfile`.
4. `macos.sh` 가 바뀌었으면 `./macos.sh --dry-run` 을 보여 주고 확인받은 뒤 돌린다.

pull 하고 import 하지 않은 채로 두지 않는다. 그 상태에서 export 하면 받은 변경을 되돌린다(`export.sh` 가 막는다).

## 올리기 (이 기기 → 저장소)
1. `./export.sh` — **pull 보다 먼저.** 끝에 나오는 ⚠ 줄을 그대로 보여 준다.
2. `git diff` 를 검토한다.
   - 공개 저장소 기준: 키·토큰·비밀번호·계정·이메일·`/Users/…` 경로·회사나 사내 프로젝트 이름·사내 서버 주소가 없어야 한다. 있으면 멈추고 묻는다. 기기별 값은 `~/.zshrc.local`·`~/.gitconfig.local` 로 빼자고 제안한다.
   - `Brewfile` 은 이 기기의 설치 목록으로 통째로 바뀐다. 빠지는 항목이 있으면 지운 것인지, 이 기기에 없을 뿐인지 묻는다.
   - README 의 "담긴 설정"이 바뀐 설정과 맞도록 함께 고친다.
3. 확인받고 커밋(`git add -A`).
4. `git pull --rebase` — 다른 기기의 변경과 합친다. 충돌은 사용자와 정한다.
5. pull 로 받은 `config/` 변경이 있으면 받기 2~3단계(dry-run → import).
6. 확인받고 `git push`.

## export.sh 가 막힐 때
"config/ 가 이 기기에서 마지막으로 맞춘 뒤 바뀌었습니다" = `config/` 에 이 기기 홈에 아직 들어가지 않은 변경이 있다(다른 기기에서 받았거나, 이 기기에서 처음 쓴다).
- `./import.sh --dry-run` 결과를 보여 준다. 그 차이에는 받은 변경과, 이 기기에서 바꾸고 아직 올리지 않은 변경이 섞여 있을 수 있다.
- 이 기기의 변경을 지켜야 하면 무엇을 남길지 사용자와 정한다. 그냥 import 하면 그 파일은 저장소 쪽으로 덮인다(`backup/` 에 남는다).
- `.git/mac-setting-sync` 를 지워 막힘을 넘기지 않는다. 사용자가 "이 기기 설정으로 저장소를 덮겠다"고 한 경우만.

## 담는 설정 바꾸기
- 파일: `files.txt` 한 줄 → `./export.sh` → README 의 "담긴 설정"·"담는 것 / 뺀 것" 갱신. 새 파일은 먼저 열어 공개 저장소 기준을 확인한다.
- macOS 시스템 설정: `defaults read` 로 지금 값을 확인한 뒤 `macos.sh` 에 한 줄(주석 포함) 더한다. plist 파일을 `files.txt` 에 넣지 않는다.
