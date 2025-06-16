#!/usr/bin/env bash

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

# Function: message "message" $COLOR indent_level
message() {
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

message_lines() {
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
    message "$message" "$TITLE" 0
}

detect_desktop_environment() {
  local de=""

  # First try environment variables
  if [[ -n "$XDG_CURRENT_DESKTOP" ]]; then
    de="$XDG_CURRENT_DESKTOP"
  elif [[ -n "$DESKTOP_SESSION" ]]; then
    de="$DESKTOP_SESSION"
  else
    # Fallback: check for known session processes by command name
    if ps -eo comm | grep -q '^gnome-session'; then
      de="GNOME"
    elif ps -eo comm | grep -q '^plasmashell$'; then
      de="KDE"
    elif ps -eo comm | grep -q '^xfce4-session$'; then
      de="XFCE"
    elif ps -eo comm | grep -q '^mate-session$'; then
      de="MATE"
    elif ps -eo comm | grep -q '^cinnamon$'; then
      de="CINNAMON"
    elif ps -eo comm | grep -q '^budgie-wm$'; then
      de="BUDGIE"
    elif ps -eo comm | grep -q '^lxqt-session$'; then
      de="LXQT"
    elif ps -eo comm | grep -q '^sway$'; then
      de="SWAY"
    elif ps -eo comm | grep -q '^i3$'; then
      de="i3"
    else
      de="UNKNOWN"
    fi
  fi

  # Normalize some common cases
  case "$de" in
    ubuntu:GNOME) echo "GNOME" ;;
    KDE|kde*) echo "KDE" ;;
    XFCE|xfce*) echo "XFCE" ;;
    MATE|mate*) echo "MATE" ;;
    Cinnamon|cinnamon*) echo "CINNAMON" ;;
    Budgie|budgie*) echo "BUDGIE" ;;
    LXQt|lxqt*) echo "LXQT" ;;
    GNOME|gnome*) echo "GNOME" ;;
    LXDE*|lxde*) echo "LXDE" ;;
    i3) echo "i3" ;;
    Sway|sway) echo "SWAY" ;;
    *) echo "$de" ;;
  esac
}

show_explanation() {
    cat <<EOF

lecheck.sh - Linux Environment Check

This script performs a series of checks to ensure the testing environment is
secure and transparent for remote proctoring.
Below is a list of what it checks and why:

  1. **Virtualization/Emulation Detection**
     - Verifies that the system is not running inside a virtual machine
       or emulator.
     - Reason: A user could share only the guest VM screen, hiding unauthorized
       material in the host operating system.

  2. **Multiple Window Systems**
     - Checks for multiple concurrent Window systems (e.g. two instances of
       X, wayland, or a combination).
     - Reason: Prevents switching to another user account or hidden desktop
       that may contain prohibited material.

  3. **Terminal Multiplexers (tmux/screen)**
     - Detects backgrounded terminal multiplexers.
     - Reason: These tools can maintain hidden terminal sessions that
       survive window closures.

  4. **Multiple Active User Sessions**
     - Identifies whether multiple users are logged in.
     - Reason: Prevents hidden collaboration.

  5. **Processes Associated with Remote Access or Recording**
     - Scans for tools like 'vnc', 'teamviewer', 'obs', and other
       screen recorders or streamers.
     - Reason: Detects potential screen broadcasting, recording, or
       unauthorized monitoring.

EOF
}

if [[ "$1" == "-?" ]]; then
    show_explanation
    exit 0
fi

DE=$(detect_desktop_environment)

# Detect Distro
if [ -f /etc/os-release ]; then
  . /etc/os-release
  DISTRO="$PRETTY_NAME"
else
  DISTRO="Unknown Linux Distribution"
fi

# Display Distro and DE
message "Detected distribution: $DISTRO" "$GOOD" 0
message "Detected desktop environment: $DE" "$GOOD" 0

# Suggest workspace keybindings
if [[ "$DE" != "UNKNOWN" ]]; then
  section "Please manually check for multiple desktops as described below."
  message "There may be a desktop grid in the taskbar." "$TITLE" 1
  message "Look for a tiny grid of desktops - may just be 1." "$TITLE" 1
fi
case "$DE" in
  GNOME)
    message "Press Super to open the workspace overview." "$WARNING" 1
    message "Press Super + Page Up / Page Down to switch between desktops." "$WARNING" 1
    message "Super is often the Windows key or Command key" "$WARNING" 1
    ;;
  KDE)
    message "Try Ctrl+F8 for Desktop Grid, or Ctrl + Alt + ↑ ." "$WARNING" 1
    message "Use Ctrl+Alt+←/→/↑/↓ to switch desktops." "$WARNING" 1
    ;;
  XFCE|MATE|LXQT)
    message "Use Panel to show desktops." "$WARNING" 1
    message "Use Ctrl+Alt+←/→ to switch desktops." "$WARNING" 1
    ;;
  LXDE)
    message "Use Super+Alt+←/→/↑/↓ to navigate a desktop grid." "$WARNING" 1
    message "Super is often the Windows key or Command key" "$WARNING" 1
    ;;
  CINNAMON)
    message "Use Ctrl+Alt+↑ to show all desktops, Ctrl+Alt+←/→ to switch." "$WARNING" 1
    message "Use Ctrl+Alt+←/→ to switch desktops." "$WARNING" 1
    ;;
  *)
    message "We don't have recommended keystokes. Try checking manually." "$WARNING" 1
    ;;
esac

read -p "Press ENTER to continue..."

section "=== Exam Environment Check ===" 

# Patterns of potentially disallowed tools (regular-expression OR list)
SUSPECT_PROCS='vnc|teamviewer|anydesk|rdesktop|xrdp|remmina|obs|ffmpeg|recordmydesktop'

notices=0

# 1. Check for VM
section "Checking for virtual environments..."
if systemd-detect-virt --quiet; then
    message "System appears to be running in a virtual machine:" "$WARNING" 1
    systemd-detect-virt | message_lines "$ERROR" 1
    message "Please do not run your test session in a virtual machine." "$TITLE" 2
    ((notices++))
else
    message "No virtualization detected" "$GREEN" 1
fi

# 2. Check for multiple users
section "Checking for multiple users..."
users=$(who | awk '{print $1}' | sort | uniq | wc -l)
if [ "$users" -gt 1 ]; then
    message "Multiple users are currently logged in:" "$WARNING" 1
    who | awk '{print $1}' | sort | uniq | message_lines "$ERROR" 1
    message "Please ask other users to log out of your system during the test." "$TITLE" 2
    ((notices++))
else
    message "No additional users detected" "$GOOD" 1
fi

# 3. Check for multiple graphical sessions
section "Checking for multiple GUI sessions..."
gui_sessions=$(loginctl list-sessions --no-legend | awk '{print $1}' | while read s; do
    loginctl show-session "$s" -p Type --value
done | grep -E 'x11|wayland' | wc -l)

if [ "$gui_sessions" -gt 1 ]; then
    message "Multiple desktop sessions detected:" "$WARNING" 1
    loginctl list-sessions | message_lines "$ERROR" 1
    message "Please use only one GUI session. There are multiple." "$TITLE" 2
    ((notices++))
else
    message "Only one GUI session detected" "$GOOD" 1
fi

# 4. Check for remote control or screen share tools (excluding Zoom)
section "Checking for screen-casting tools..."
if bad_procs=$(ps aux | grep -E "$SUSPECT_PROCS" | grep -v grep); then
    if [ -n "$bad_procs" ]; then
        message "Please review for potential screen-casting tools such as:" "$WARNING" 1
        message "$SUSPECT_PROCS" "$WARNING" 1
        echo "$bad_procs" | message_lines "$ERROR" 2
        message "Please quit any screen-casting tools." "$TITLE" 2
        ((notices++))
    fi
else
    message "No remote control processes detected" "$GOOD" 1
fi

# 5. Check for terminal multiplexers (e.g., tmux, screen)
section "Checking for terminal multiplexers..."
if ps -eo comm | grep -q '^tmux:' || ps -eo comm | grep -q '^screen'; then
    message "Terminal multiplexer (tmux/screen) running:" "$WARNING" 1
    ps -eo comm | grep '^tmux:' | message_lines "$ERROR" 1
    pgrep -ax screen | message_lines "$ERROR" 1
    message "Please stop any multiplexers, even detached ones." "$TITLE" 2
    ((notices++))
else
    message "No terminal multiplexers" "$GOOD" 1
fi

# Summary
section "Summary"
if [ "$notices" -eq 0 ]; then
    message "Good to go!" "$GOOD" 1
    exit 0
else
    if [ "$notices" -eq 1 ]; then
        message "There was 1 notice produced. Please review." "$WARNING" 1
    else
        message "There were $notices notices produced. Please review." "$WARNING" 1
    fi
    exit 1
fi

