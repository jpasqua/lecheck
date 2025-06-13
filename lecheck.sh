#!/bin/bash

# ANSI Color Constants
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BOLD_WHITE='\033[1;37m'
BOLD_CYAN='\033[1;36m'
BOLD_RED='\033[1;31m'
BOLD_YELLOW='\033[1;33m'
BOLD_GREEN='\033[1;32m'
NC='\033[0m' # No Color

TITLE=$BOLD_WHITE
GOOD=$BOLD_GREEN
WARNING=$BOLD_YELLOW
ERROR=$BOLD_RED

# Function: color_print "message" $COLOR indent_level
color_print() {
    local message="$1"
    local color="$2"
    local indent="${3:-0}"

    # Create indentation string
    local indent_str=""
    for ((i = 0; i < indent; i++)); do
        indent_str+="    "  # 4 spaces per indent level
    done

    # Print with color and indentation
    printf "%b%s%b\n" "$color" "${indent_str}${message}" "$NC"
}

color_print_lines() {
    local color="$1"
    local indent="${2:-0}"
    local line
    local indent_str=""

    for ((i = 0; i < indent; i++)); do
        indent_str+="    "  # 4 spaces per level
    done

    while IFS= read -r line; do
        printf "%b%s%s%b\n" "$color" "$indent_str" "$line" "$NC"
    done
}

section() {
    local message="$1"

    # Emit two blank lines before the section title
    printf "\n\n"

    # Print the message in the TITLE color with no indent
    color_print "$message" "$TITLE" 0
}

# Detect Desktop Environment
DE="${XDG_CURRENT_DESKTOP:-$DESKTOP_SESSION}"

if [[ -z "$DE" ]]; then
  if pgrep -x gnome-session >/dev/null; then
    DE="GNOME"
  elif pgrep -x plasmashell >/dev/null; then
    DE="KDE"
  elif pgrep -x xfce4-session >/dev/null; then
    DE="XFCE"
  elif pgrep -x mate-session >/dev/null; then
    DE="MATE"
  elif pgrep -x cinnamon >/dev/null; then
    DE="CINNAMON"
  elif pgrep -x budgie-wm >/dev/null; then
    DE="BUDGIE"
  elif pgrep -x lxqt-session >/dev/null; then
    DE="LXQT"
  else
    DE="UNKNOWN"
  fi
fi

# Detect Distro
if [ -f /etc/os-release ]; then
  . /etc/os-release
  DISTRO="$PRETTY_NAME"
else
  DISTRO="Unknown Linux Distribution"
fi

# Display Distro and DE
color_print "Detected distribution: $DISTRO" "$GOOD" 0
color_print "Detected desktop environment: $DE" "$GOOD" 0

# Suggest workspace keybindings
case "$DE" in
  GNOME)
    color_print "Tip: Press Super to open the workspace overview." "$WARNING" 1
    color_print "Tip: Press Super + Page Up / Page Down to switch between desktops." "$WARNING" 1
    ;;
  KDE)
    color_print "Tip: Try Ctrl+F8 for Desktop Grid, or Ctrl + Alt + ↑ ." "$WARNING" 1
    color_print "Tip: Use Ctrl+Alt+←/→ to switch desktops." "$WARNING" 1
    ;;
  XFCE|MATE|LXQT)
    color_print "Tip: Use Panel to show desktops." "$WARNING" 1
    color_print "Tip: Use Ctrl+Alt+←/→ to switch desktops." "$WARNING" 1
    ;;
  CINNAMON)
    color_print "Tip: Use Ctrl+Alt+↑ to show all desktops, Ctrl+Alt+←/→ to switch." "$WARNING" 1
    color_print "Tip: Use Ctrl+Alt+←/→ to switch desktops." "$WARNING" 1
    ;;
  *)
    color_print "Desktop environment not recognized. Try checking manually." "$WARNING" 1
    ;;
esac

echo "Press ENTER to continue..."
read dummy


section "=== Exam Environment Check ===" 

# Patterns of potentially disallowed tools (regular-expression OR list)
SUSPECT_PROCS='vnc|teamviewer|anydesk|rdesktop|xrdp|remmina|obs|ffmpeg|recordmydesktop'

notices=0

# 1. Check for VM
section "Checking for virtual environments..."
if systemd-detect-virt --quiet; then
    color_print "System appears to be running in a virtual machine:" "$WARNING" 1
    systemd-detect-virt | color_print_lines "$ERROR" 1
    ((notices++))
else
    color_print "No virtualization detected" "$GREEN" 1
fi

# 2. Check for multiple users
section "Checking for multiple users..."
users=$(who | awk '{print $1}' | sort | uniq | wc -l)
if [ "$users" -gt 1 ]; then
    color_print "Multiple users are currently logged in:" "$WARNING" 1
    who | awk '{print $1}' | sort | uniq | color_print_lines "$ERROR" 1
    ((notices++))
else
    color_print "No additional users detected" "$GOOD" 1
fi

# 3. Check for multiple graphical sessions
section "Checking for multiple GUI sessions..."
gui_sessions=$(loginctl list-sessions --no-legend | awk '{print $1}' | while read s; do
    loginctl show-session "$s" -p Type --value
done | grep -E 'x11|wayland' | wc -l)

if [ "$gui_sessions" -gt 1 ]; then
    color_print "Multiple desktop sessions detected:" "$WARNING" 1
    loginctl list-sessions | color_print_lines "$ERROR" 1
    ((notices++))
else
    color_print "Only one GUI session detected" "$GOOD" 1
fi

# 4. Check for remote control or screen share tools (excluding Zoom)
section "Checking for remote access tools..."
if bad_procs=$(ps aux | grep -E "$SUSPECT_PROCS" | grep -v grep); then
    if [ -n "$bad_procs" ]; then
        color_print "Please review for potential remote access tools such as:" "$WARNING" 1
        color_print "$SUSPECT_PROCS" "$WARNING" 1
        echo "$bad_procs" | color_print_lines "$ERROR" 2
        ((notices++))
    fi
else
    color_print "No remote control processes detected" "$GOOD" 1
fi

# 5. Check for terminal multiplexers (e.g., tmux, screen)
section "Checking for terminal multiplexers..."
if ps -eo comm | grep -q '^tmux:' || ps -eo comm | grep -q '^screen'; then
    color_print "Terminal multiplexer (tmux/screen) running:" "$WARNING" 1
    ps aux | grep '[t]mux' | color_print_lines "$ERROR" 2
    pgrep -ax screen | color_print_lines "$ERROR" 2
    ((notices++))
else
    color_print "No terminal multiplexers" "$GOOD" 1
fi

# Summary
section "Summary"
if [ "$notices" -eq 0 ]; then
    color_print "Good to go!" "$GOOD" 1
    exit 0
else
    if [ "$notices" -eq 1 ]; then
        color_print "There was 1 notice produced. Please review." "$WARNING" 1
    else
        color_print "There were $notices notices produced. Please review." "$WARNING" 1
    fi
    exit 1
fi

