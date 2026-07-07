#!/usr/bin/env bash
# Claude Code statusline: model | context % | 5h & 7d rate-limit bars with reset countdowns.
# Reads session JSON from stdin (see https://code.claude.com/docs/en/statusline).

input=$(cat)

# --- ANSI colors ---
RESET=$'\033[0m'
DIM=$'\033[2m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
CYAN=$'\033[36m'

# Pick a color based on a 0-100 utilization value.
color_for() {
  local pct=${1%.*}        # strip decimals
  pct=${pct:-0}
  if   (( pct >= 80 )); then printf '%s' "$RED"
  elif (( pct >= 50 )); then printf '%s' "$YELLOW"
  else                       printf '%s' "$GREEN"
  fi
}

# Build a 10-char progress bar for a 0-100 value.
make_bar() {
  local pct=${1%.*}; pct=${pct:-0}
  local width=10 i filled bar=""
  (( pct < 0 ))   && pct=0
  (( pct > 100 )) && pct=100
  filled=$(( (pct * width + 50) / 100 ))   # rounded
  for ((i = 0; i < width; i++)); do
    if (( i < filled )); then bar+="█"; else bar+="░"; fi
  done
  printf '%s' "$bar"
}

# Format seconds-until-reset as a compact countdown (e.g. 6d22h, 3h12m, 4m, <1m).
fmt_reset() {
  local resets_at=$1 now diff d h m
  now=$(date +%s)
  diff=$(( resets_at - now ))
  (( diff <= 0 )) && { printf 'now'; return; }
  d=$(( diff / 86400 ))
  h=$(( (diff % 86400) / 3600 ))
  m=$(( (diff % 3600) / 60 ))
  if   (( d > 0 )); then printf '%dd%dh' "$d" "$h"
  elif (( h > 0 )); then printf '%dh%dm' "$h" "$m"
  elif (( m > 0 )); then printf '%dm' "$m"
  else                   printf '<1m'
  fi
}

# --- path + git branch (first line) ---
CUR_DIR=$(printf '%s' "$input" | jq -r '.workspace.current_dir // empty')
[[ -z $CUR_DIR ]] && CUR_DIR=$PWD
DISP_DIR=${CUR_DIR/#$HOME/\~}        # abbreviate home as ~

line1="${DIM}${DISP_DIR}${RESET}"

BRANCH=$(git -C "$CUR_DIR" symbolic-ref --quiet --short HEAD 2>/dev/null \
         || git -C "$CUR_DIR" rev-parse --short HEAD 2>/dev/null)
if [[ -n $BRANCH ]]; then
  dirty=""
  [[ -n $(git -C "$CUR_DIR" status --porcelain 2>/dev/null) ]] && dirty="${YELLOW}*${RESET}"
  line1+="  ${DIM}git:${RESET}${BRANCH}${dirty}"
fi

# --- model + effort + context ---
MODEL=$(printf '%s' "$input" | jq -r '.model.display_name // "Claude"')
EFFORT=$(printf '%s' "$input" | jq -r '.effort.level // empty')
CTX=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)

out="${CYAN}${MODEL}${RESET}"
# Effort level (reasoning) right after the model name; absent for models without it.
[[ -n $EFFORT ]] && out+=" ${DIM}·${RESET} ${YELLOW}${EFFORT}${RESET}"
out+="  ${DIM}ctx:${RESET}${CTX}%"

# --- 5h window (present only for Pro/Max after first API response) ---
H5_PCT=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
if [[ -n $H5_PCT ]]; then
  H5_RESET=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
  c=$(color_for "$H5_PCT"); bar=$(make_bar "$H5_PCT")
  out+="  ${DIM}5h:${RESET}[${c}${bar}${RESET}] ${H5_PCT%.*}%"
  [[ -n $H5_RESET ]] && out+=" ${DIM}$(fmt_reset "$H5_RESET")${RESET}"
fi

# --- 7d window ---
D7_PCT=$(printf '%s' "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
if [[ -n $D7_PCT ]]; then
  D7_RESET=$(printf '%s' "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')
  c=$(color_for "$D7_PCT"); bar=$(make_bar "$D7_PCT")
  out+="  ${DIM}7d:${RESET}[${c}${bar}${RESET}] ${D7_PCT%.*}%"
  [[ -n $D7_RESET ]] && out+=" ${DIM}$(fmt_reset "$D7_RESET")${RESET}"
fi

printf '%s\n%s' "$line1" "$out"
