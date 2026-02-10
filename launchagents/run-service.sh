#!/usr/bin/env bash
# Wrapper that runs a service and sends a macOS notification if it crashes.
# Usage: run-service.sh <service-name> <command> [args...]
set -uo pipefail

SERVICE_NAME="$1"
shift

"$@"
EXIT_CODE=$?

if [ "$EXIT_CODE" -ne 0 ]; then
	/opt/homebrew/bin/terminal-notifier \
		-title "Service Crashed: $SERVICE_NAME" \
		-message "Exited with code $EXIT_CODE. Check ~/Library/Logs/${SERVICE_NAME}.error.log" \
		-group "launchagent.$SERVICE_NAME" \
		-sound default
fi

exit "$EXIT_CODE"
