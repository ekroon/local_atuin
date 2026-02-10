# Usage

## Prerequisites

- **[mise](https://mise.jdx.dev)** — `brew install mise` (used to manage the Atuin server binary)
- **PostgreSQL 14** — `brew install postgresql@14`
- **Atuin server** — installed via mise:
  ```bash
  mise install "github:atuinsh/atuin[asset_pattern=atuin-server-aarch64-apple-darwin.*]"
  mise reshim
  ```
- **Cloudflared** — `brew install cloudflared`, then create and configure the tunnel:
  ```bash
  cloudflared tunnel create macbook
  # Configure ~/.cloudflared/config.yml with your tunnel settings
  ```
- **terminal-notifier** — `brew install terminal-notifier` (for crash notifications)

## LaunchAgents (recommended)

Run as macOS LaunchAgents that start automatically on login:

```bash
# Install and start all services
./launchagents/manage.sh install

# Stop and remove all services
./launchagents/manage.sh uninstall
```

Logs are written to `~/Library/Logs/` (`postgresql14.log`, `atuin.log`, `cloudflared.log`).

If a service crashes, a macOS notification is sent via `terminal-notifier`. Services are automatically restarted by launchd.

## Overmind (alternative)

Install [Overmind](https://github.com/DarthSim/overmind) and run:

```bash
overmind s
```
