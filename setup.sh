#!/usr/bin/env bash
# =============================================================================
#  my-setup — one-shot machine bootstrap for a fresh Ubuntu install.
#
#  Usage:
#     git clone <this-repo> ~/github/my-setup
#     cd ~/github/my-setup
#     ./setup.sh                 # install packages + symlink every config
#
#  Flags:
#     --links-only     only create the config symlinks (no sudo / no apt)
#     --skip-packages  skip apt package installation
#     --skip-neovim    skip the Neovim install step
#     --skip-claude    skip installing the Claude Code CLI
#     --skip-shell     do not change the default shell to fish
#     -h | --help      show this help
#
#  The repo becomes the single source of truth: configs are symlinked into
#  ~/.config and ~/.claude, so editing a file here updates the live config.
# =============================================================================
set -euo pipefail

# --- paths -------------------------------------------------------------------
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
TS="$(date +%Y%m%d-%H%M%S)"
OLD_HOME="/home/arammatosyan"   # home path the configs were originally captured under

# --- flags -------------------------------------------------------------------
DO_PACKAGES=1 DO_NEOVIM=1 DO_CLAUDE=1 DO_SHELL=1 DO_LINKS=1
for arg in "$@"; do
  case "$arg" in
    --links-only)    DO_PACKAGES=0; DO_NEOVIM=0; DO_CLAUDE=0; DO_SHELL=0 ;;
    --skip-packages) DO_PACKAGES=0 ;;
    --skip-neovim)   DO_NEOVIM=0 ;;
    --skip-claude)   DO_CLAUDE=0 ;;
    --skip-shell)    DO_SHELL=0 ;;
    -h|--help)       sed -n '2,30p' "$0"; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

# --- pretty output -----------------------------------------------------------
info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m  ✓\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }

# Symlink $1 (path inside the repo) to $2 (target in $HOME).
# An existing real file/dir is backed up to <dest>.bak-<timestamp>.
link() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ -L "$dest" ]; then
    rm -f "$dest"                                   # stale symlink -> repoint
  elif [ -e "$dest" ]; then
    warn "backing up $dest -> ${dest}.bak-${TS}"
    mv "$dest" "${dest}.bak-${TS}"
  fi
  ln -s "$src" "$dest"
  ok "$dest -> $src"
}

# =============================================================================
#  1. Portability: rewrite hardcoded home paths if the username differs
# =============================================================================
patch_paths() {
  [ "$HOME" = "$OLD_HOME" ] && return
  warn "Configs were captured under $OLD_HOME but your home is $HOME."
  warn "Rewriting hardcoded paths inside the repo to use $HOME…"
  local files=(
    "$DOTFILES/terminator/config"
    "$DOTFILES/claude/settings.json"
    "$DOTFILES/claude/run-claude"
    "$DOTFILES/fish/config.fish"
  )
  for f in "${files[@]}"; do
    [ -f "$f" ] && sed -i "s#${OLD_HOME}#${HOME}#g" "$f"
  done
  ok "paths rewritten"
}

# =============================================================================
#  2. apt packages
# =============================================================================
install_packages() {
  info "Installing apt packages…"
  sudo apt-get update -y
  sudo apt-get install -y \
    software-properties-common \
    fish terminator \
    git curl wget unzip \
    build-essential clang \
    jq tree ripgrep fd-find \
    python3 python3-pip python3-venv \
    nodejs npm \
    xclip wl-clipboard

  # Debian/Ubuntu ship fd as `fdfind`; expose it as `fd` for Telescope/Oil.
  if command -v fdfind >/dev/null && ! command -v fd >/dev/null; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
    ok "linked fd -> fdfind"
  fi
}

# =============================================================================
#  3. Neovim (recent release — the config needs 0.10+)
# =============================================================================
install_neovim() {
  if command -v nvim >/dev/null 2>&1; then
    info "Neovim already present: $(nvim --version | head -1)"
    return
  fi
  info "Installing Neovim from the stable PPA…"
  sudo add-apt-repository -y ppa:neovim-ppa/stable
  sudo apt-get update -y
  sudo apt-get install -y neovim
}

# =============================================================================
#  4. Claude Code CLI  (installs to ~/.local/bin/claude — matches run-claude)
# =============================================================================
install_claude() {
  if command -v claude >/dev/null 2>&1 || [ -x "$HOME/.local/bin/claude" ]; then
    info "Claude Code already installed — skipping."
    return
  fi
  info "Installing Claude Code…"
  curl -fsSL https://claude.ai/install.sh | bash
}

# =============================================================================
#  5. Symlink every config into place
# =============================================================================
link_configs() {
  info "Linking configs…"

  # --- terminator ---
  link "$DOTFILES/terminator/config" "$CONFIG/terminator/config"

  # --- fish ---
  link "$DOTFILES/fish/config.fish"                "$CONFIG/fish/config.fish"
  link "$DOTFILES/fish/conf.d/colors.fish"         "$CONFIG/fish/conf.d/colors.fish"
  link "$DOTFILES/fish/functions/fish_prompt.fish" "$CONFIG/fish/functions/fish_prompt.fish"
  # fish_variables is rewritten by fish at runtime, so seed it once (don't symlink).
  if [ ! -e "$CONFIG/fish/fish_variables" ]; then
    mkdir -p "$CONFIG/fish"
    cp "$DOTFILES/fish/fish_variables" "$CONFIG/fish/fish_variables"
    ok "seeded $CONFIG/fish/fish_variables"
  fi

  # --- neovim (whole config tree) ---
  link "$DOTFILES/nvim" "$CONFIG/nvim"

  # --- claude (only config files; ~/.claude runtime files stay untouched) ---
  chmod +x "$DOTFILES/claude/statusline.sh" "$DOTFILES/claude/run-claude"
  link "$DOTFILES/claude/CLAUDE.md"        "$HOME/.claude/CLAUDE.md"
  link "$DOTFILES/claude/settings.json"    "$HOME/.claude/settings.json"
  link "$DOTFILES/claude/keybindings.json" "$HOME/.claude/keybindings.json"
  link "$DOTFILES/claude/statusline.sh"    "$HOME/.claude/statusline.sh"
  link "$DOTFILES/claude/run-claude"       "$HOME/.claude/run-claude"

  # Default working dir used by the fish `claude` function.
  mkdir -p "$HOME/workspace/claude"
}

# =============================================================================
#  6. Make fish the default shell
# =============================================================================
set_default_shell() {
  local fish_path
  fish_path="$(command -v fish || true)"
  [ -z "$fish_path" ] && { warn "fish not found — cannot set default shell."; return; }
  if ! grep -qx "$fish_path" /etc/shells 2>/dev/null; then
    echo "$fish_path" | sudo tee -a /etc/shells >/dev/null
  fi
  if [ "${SHELL:-}" != "$fish_path" ]; then
    info "Setting fish as the default shell…"
    chsh -s "$fish_path" || warn "chsh failed — run 'chsh -s $fish_path' manually."
  else
    info "fish is already the default shell."
  fi
}

# =============================================================================
#  main
# =============================================================================
info "my-setup bootstrap — repo: $DOTFILES"
patch_paths
[ "$DO_PACKAGES" = 1 ] && install_packages
[ "$DO_NEOVIM"   = 1 ] && install_neovim
[ "$DO_CLAUDE"   = 1 ] && install_claude
[ "$DO_LINKS"    = 1 ] && link_configs
[ "$DO_SHELL"    = 1 ] && set_default_shell

cat <<'EOF'

──────────────────────────────────────────────
  Done. Next steps:
    1. Log out and back in (so fish becomes your shell).
    2. Launch nvim once — lazy.nvim + Mason will auto-install
       every plugin and LSP server on first start.
    3. Run `claude` and sign in when prompted.
──────────────────────────────────────────────
EOF
