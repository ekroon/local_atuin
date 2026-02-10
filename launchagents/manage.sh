#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
NOTIFIER="/opt/homebrew/bin/terminal-notifier"
PLIST_FILES=(
	com.local.postgresql14.plist
	com.local.atuin.plist
	com.local.cloudflared.plist
)

# Resolve template placeholders in a plist file
render_plist() {
	local src="$1"
	local dst="$2"
	sed -e "s|__HOME__|$HOME|g" -e "s|__REPO__|$REPO_DIR|g" "$src" > "$dst"
}

notify_error() {
	local msg="$1"
	echo "ERROR: $msg" >&2
	if [ -x "$NOTIFIER" ]; then
		"$NOTIFIER" -title "LaunchAgent Error" -message "$msg" -group "launchagent.manage" -sound default
	fi
}

install() {
	mkdir -p "$LAUNCH_AGENTS_DIR"

	if ! command -v terminal-notifier &>/dev/null && [ ! -x "$NOTIFIER" ]; then
		echo "WARNING: terminal-notifier not found. Install with: brew install terminal-notifier"
	fi

	local errors=0
	for plist in "${PLIST_FILES[@]}"; do
		local src="$SCRIPT_DIR/$plist"
		local dst="$LAUNCH_AGENTS_DIR/$plist"
		local label="${plist%.plist}"

		# Generate resolved plist from template
		if [ -e "$dst" ]; then
			# Re-render in case template changed
			render_plist "$src" "$dst"
			echo "Updated: $plist"
		else
			render_plist "$src" "$dst"
			echo "Installed: $plist"
		fi

		# Load service
		if launchctl list "$label" &>/dev/null; then
			echo "Already loaded: $plist"
		elif launchctl load "$dst" 2>&1; then
			echo "Loaded: $plist"
		else
			notify_error "Failed to load $plist"
			errors=1
		fi
	done

	if [ "$errors" -eq 0 ]; then
		echo "Done. All services installed and loaded."
	else
		echo "Done with errors. Check messages above."
		exit 1
	fi
}

uninstall() {
	for plist in "${PLIST_FILES[@]}"; do
		local dst="$LAUNCH_AGENTS_DIR/$plist"
		local label="${plist%.plist}"
		if [ -e "$dst" ]; then
			if launchctl list "$label" &>/dev/null; then
				launchctl unload "$dst" 2>&1 && echo "Unloaded: $plist" || echo "WARNING: failed to unload $plist"
			else
				echo "Not loaded: $plist"
			fi
			rm "$dst"
			echo "Removed: $plist"
		else
			echo "Not installed: $plist (skipping)"
		fi
	done
	echo "Done. Services uninstalled."
}

case "${1:-}" in
	install)   install ;;
	uninstall) uninstall ;;
	*)
		echo "Usage: $0 {install|uninstall}"
		exit 1
		;;
esac
