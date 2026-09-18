#!/usr/bin/env bash
# Isolated behavioral checks; never install packages or modify the real home.
# Zsh snippets expand variables in the child shell, not this Bash test runner.
# shellcheck disable=SC2016
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_DIR=$(mktemp -d)
trap 'rm -rf -- "$TEST_DIR"' EXIT
TEST_HOME="$TEST_DIR/home with spaces"
mkdir -p "$TEST_HOME"
ZSH_BIN=$(command -v zsh)

fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
fail_interactive_shell() {
    printf 'FAIL: %s\n' "$*" >&2
    printf '%s\n' '--- interactive shell stdout ---' >&2
    cat "$TEST_DIR/shell.out" >&2
    printf '\n%s\n' '--- interactive shell stderr ---' >&2
    cat "$TEST_DIR/shell.err" >&2
    exit 1
}
sync_sbc() { HOME="$TEST_HOME" bash "$REPO_DIR/linux-edge/sbc/sync.sh" "$@"; }
run_zsh() {
    env -i HOME="$TEST_HOME" ZDOTDIR="$TEST_HOME" PATH=/usr/bin:/bin TERM=xterm-256color \
        "$ZSH_BIN" "$@"
}

# Dry runs and invalid arguments must not create files.
sync_sbc --dry-run >"$TEST_DIR/dry.out" 2>&1
[[ ! -e "$TEST_HOME/.zshrc" && ! -e "$TEST_HOME/.dotfiles.backups" ]] || fail 'dry run changed home'
if sync_sbc --unknown >"$TEST_DIR/error.out" 2>&1; then
    fail 'unknown sync option accepted'
fi
[[ $(<"$TEST_DIR/error.out") == *'Unknown option'* ]] || fail 'missing argument diagnostic'
bash "$REPO_DIR/linux-edge/sbc/bootstrap.sh" --help >"$TEST_DIR/help.out"
if bash "$REPO_DIR/linux-edge/sbc/bootstrap.sh" --unknown >"$TEST_DIR/error.out" 2>&1; then
    fail 'unknown bootstrap option accepted'
fi

sync_sbc
cmp "$REPO_DIR/linux-edge/sbc/.zshrc" "$TEST_HOME/.zshrc"
cmp "$REPO_DIR/linux-edge/sbc/.zshenv" "$TEST_HOME/.zshenv"
sync_sbc --all
[[ ! -e "$TEST_HOME/.dotfiles.backups" ]] || fail 'unchanged files were backed up'

# Legacy modules, caches, and overrides must not run even when present.
mkdir -p "$TEST_HOME/.zsh" "$TEST_HOME/.cache" "$TEST_HOME/.cargo" "$TEST_HOME/.local/bin"
for file in .zsh/theme.zsh .zsh/plugins.zsh .zsh/languages.zsh .zsh/editors.zsh .zshrc.local .cargo/env; do
    printf 'print -u2 "legacy config loaded"; exit 99\n' >"$TEST_HOME/$file"
done
run_zsh -c 'print -r -- ${(%):-%n}' >"$TEST_DIR/username"
printf 'print -u2 "legacy prompt loaded"; exit 99\n' >"$TEST_HOME/.cache/p10k-instant-prompt-$(<"$TEST_DIR/username").zsh"

# Real interactive startup exercises completion, bindings, navigation, and prompt.
run_zsh -i -c '
    [[ -o interactive && -o sharehistory && ! -o promptsubst ]] || exit 1
    [[ $HISTSIZE == 5000 && $SAVEHIST == 5000 && $HISTFILE == "$HOME/.zsh_history" ]] || exit 2
    (( $+functions[compdef] )) || exit 3
    [[ $(bindkey "^?") == *backward-delete-char* ]] || exit 4
    [[ $(bindkey "^H") == *backward-delete-char* ]] || exit 5
    [[ $(bindkey "^R") == *history-incremental-search-backward* ]] || exit 6
    [[ $(whence -w cd) == "cd: builtin" ]] || exit 7
    (( ${#precmd_functions} == 0 && ${#chpwd_functions} == 0 && ${#preexec_functions} == 0 )) || exit 8
    (( ! $+functions[precmd] && ! $+functions[chpwd] && ! $+functions[preexec] )) || exit 9
    [[ -z $RPROMPT && $path[1] == "$HOME/.local/bin" ]] || exit 10
    cd "$HOME"
    for i in {1..100}; do cd /; cd "$HOME"; print -P -- "$PROMPT" >/dev/null; done
    [[ $PWD == "$HOME" && ${(%):-%~} == "~" ]] || exit 11
    false
    rendered=$(print -P -- "$PROMPT")
    [[ $rendered == *"1"* ]] || exit 12
    print -s -- "sbc-history-marker"
    print -r -- OK
' >"$TEST_DIR/shell.out" 2>"$TEST_DIR/shell.err" || fail_interactive_shell "interactive shell failed (exit $?)"
[[ $(<"$TEST_DIR/shell.out") == OK && ! -s "$TEST_DIR/shell.err" ]] || fail_interactive_shell 'noisy shell startup'
[[ -f "$TEST_HOME/.zcompdump" ]] || fail 'completion cache missing'
[[ $(<"$TEST_HOME/.zsh_history") == *sbc-history-marker* ]] || fail 'history was not saved'
run_zsh -i -c 'exit' >"$TEST_DIR/warm.out" 2>&1
[[ ! -s "$TEST_DIR/warm.out" ]] || fail 'noisy cached startup'
run_zsh -c '[[ $path[1] == "$HOME/.local/bin" ]]' >"$TEST_DIR/noninteractive.out" 2>&1
[[ ! -s "$TEST_DIR/noninteractive.out" ]] || fail 'noisy non-interactive startup'

printf 'export SBC_OVERRIDE=loaded\n' >"$TEST_HOME/.zshrc.sbc.local"
run_zsh -i -c '[[ $SBC_OVERRIDE == loaded ]]' || fail 'SBC override was not loaded'

# Migrating symlinks must preserve their targets, including dangling old links.
printf 'original config\n' >"$TEST_DIR/old.zshrc"
rm "$TEST_HOME/.zshrc" "$TEST_HOME/.zshenv"
ln -s "$TEST_DIR/old.zshrc" "$TEST_HOME/.zshrc"
ln -s "$TEST_DIR/missing.zshenv" "$TEST_HOME/.zshenv"
sync_sbc
[[ $(<"$TEST_DIR/old.zshrc") == 'original config' ]] || fail 'sync overwrote symlink target'
[[ ! -L "$TEST_HOME/.zshrc" && ! -L "$TEST_HOME/.zshenv" ]] || fail 'symlinks were not replaced'
backups=("$TEST_HOME"/.dotfiles.backups/sbc-*)
[[ ${#backups[@]} == 1 && -L "${backups[0]}/.zshrc" && -L "${backups[0]}/.zshenv" ]] || fail 'symlink backups missing'
cmp "$REPO_DIR/linux-edge/sbc/.zshrc" "$TEST_HOME/.zshrc"

# Ordinary files are backed up too, and repeat syncs are idempotent.
printf 'custom config\n' >"$TEST_HOME/.zshrc"
sync_sbc
sync_sbc
backups=("$TEST_HOME"/.dotfiles.backups/sbc-*)
[[ ${#backups[@]} == 2 ]] || fail 'incorrect backup count'
saved_custom=false
for backup in "${backups[@]}"; do
    if [[ $(<"$backup/.zshrc") == 'custom config' ]]; then saved_custom=true; fi
done
[[ "$saved_custom" == true ]] || fail 'original file backup missing'

# Reject directory destinations before modifying either config.
rm "$TEST_HOME/.zshrc"
mkdir "$TEST_HOME/.zshrc"
printf 'keep this\n' >"$TEST_HOME/.zshenv"
if sync_sbc >"$TEST_DIR/error.out" 2>&1; then fail 'directory destination accepted'; fi
[[ $(<"$TEST_HOME/.zshenv") == 'keep this' ]] || fail 'validation partially modified home'
[[ $(<"$TEST_DIR/error.out") == *'destination is a directory'* ]] || fail 'missing validation diagnostic'

# Bootstrap package operations are stubbed; only its sync writes to a fake home.
MOCK_BIN="$TEST_DIR/mock-bin"
mkdir -p "$MOCK_BIN"
cat >"$MOCK_BIN/uname" <<'EOF'
#!/usr/bin/env bash
printf 'Linux\n'
EOF
cat >"$MOCK_BIN/sudo" <<'EOF'
#!/usr/bin/env bash
[[ $1 == -n ]] || exit 1
shift
exec "$@"
EOF
cat >"$MOCK_BIN/apt-get" <<'EOF'
#!/usr/bin/env bash
[[ $DEBIAN_FRONTEND == noninteractive ]] || exit 1
printf '%s\n' "$*" >>"$PACKAGE_LOG"
exit "${PACKAGE_EXIT:-0}"
EOF
chmod +x "$MOCK_BIN/uname" "$MOCK_BIN/sudo" "$MOCK_BIN/apt-get"
BOOTSTRAP_HOME="$TEST_DIR/bootstrap-home"
mkdir -p "$BOOTSTRAP_HOME"
env HOME="$BOOTSTRAP_HOME" PATH="$MOCK_BIN:$PATH" PACKAGE_LOG="$TEST_DIR/packages.log" \
    bash "$REPO_DIR/linux-edge/sbc/bootstrap.sh"
cmp "$REPO_DIR/linux-edge/sbc/.zshrc" "$BOOTSTRAP_HOME/.zshrc"
[[ $(<"$TEST_DIR/packages.log") == $'update\ninstall -y --no-install-recommends zsh git curl ca-certificates vim-tiny less tmux htop ripgrep' ]] || fail 'unexpected packages'
printf 'preserve on failure\n' >"$BOOTSTRAP_HOME/.zshrc"
if env HOME="$BOOTSTRAP_HOME" PATH="$MOCK_BIN:$PATH" PACKAGE_LOG="$TEST_DIR/packages.log" PACKAGE_EXIT=42 \
    bash "$REPO_DIR/linux-edge/sbc/bootstrap.sh" >"$TEST_DIR/error.out" 2>&1; then
    fail 'bootstrap ignored package failure'
fi
[[ $(<"$BOOTSTRAP_HOME/.zshrc") == 'preserve on failure' ]] || fail 'bootstrap synced after package failure'
[[ $(<"$TEST_DIR/error.out") == *'exit 42'* ]] || fail 'missing bootstrap failure diagnostic'

printf 'PASS: SBC shell and sync checks\n'
