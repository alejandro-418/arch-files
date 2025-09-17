#!/usr/bin/env bash

set -euo pipefail
shopt -s extglob                # enables nicer pattern matching

FILE="${1:-pkgs.txt}"           # default is pkgs.txt
AUR_HELPER="${AUR_HELPER:-paru}" 

cmd_exists() { command -v "$1" &>/dev/null; }

# --- bootstrap paru/yay if missing ---

if ! cmd_exists "$AUR_HELPER"; then
  echo ">>> $AUR_HELPER not found — cloning & building it first…"
  tmp=$(mktemp -d)
  git -C "$tmp" clone "https://aur.archlinux.org/${AUR_HELPER}.git"
  (cd "$tmp/${AUR_HELPER}" && makepkg -si --noconfirm)
  rm -rf "$tmp"
fi

# --- read & de-duplicate the list ---

readarray -t ALL < <(grep -vE '^\s*(#|$)' "$FILE" | sort -u)

REPO_PKGS=()  AUR_PKGS=()  INSTALLED=()  UNKNOWN=()

echo ">>> Scanning ${#ALL[@]} package names from $FILE …"
for pkg in "${ALL[@]}"; do
  if   pacman -Qi "$pkg" &>/dev/null;       then INSTALLED+=("$pkg")
  elif pacman -Si "$pkg" &>/dev/null;       then REPO_PKGS+=("$pkg")
  elif "$AUR_HELPER" -Si "$pkg" &>/dev/null;then AUR_PKGS+=("$pkg")
  else UNKNOWN+=("$pkg")
  fi
done

# --- summary ---

printf '\n%-22s %d\n' "Already installed :" "${#INSTALLED[@]}"
printf '%-22s %d\n'   "Repo packages     :" "${#REPO_PKGS[@]}"
printf '%-22s %d\n'   "AUR packages      :" "${#AUR_PKGS[@]}"
printf '%-22s %d\n\n' "Unknown / typo    :" "${#UNKNOWN[@]}"
(( ${#UNKNOWN[@]} )) && printf '⚠️  Not found: %s\n\n' "${UNKNOWN[*]}"

# --- install passes ---

(( ${#REPO_PKGS[@]} )) && sudo pacman -S --needed --noconfirm "${REPO_PKGS[@]}"
(( ${#AUR_PKGS[@]}  )) && "$AUR_HELPER" -S --needed --noconfirm --batchinstall "${AUR_PKGS[@]}"

echo -e "\n✓ Bulk install finished."
