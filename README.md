# Minecraft BaseControl & Label System

A CC:Tweaked toolkit with:
- **BaseControl** (Pocket UI) — labels manager, server controls, updates & distributor pages.
- **Mainframe** — mirrors this repo via HTTP and serves files to your LAN over `rednet`.
- **labelClient** — draws labels on Advanced Monitors and auto-updates from Mainframe.

## Repo Layout
See `manifest.yml` workflow and `manifest.json`. Key paths:
- `clients/labelClient.lua` — client (auto-update + word-wrap)
- `mainframe/repo_server.lua` — LAN package server (`pkg_repo`)
- `dist/dist_agent.lua` — tiny receiver for remote installs
- `basectl/*` — (optional) BaseControl app files for Pocket self-update

## Getting Started
1. Create this repo and push.
2. Check **Actions** → `manifest.json` should be built.
3. On a CC computer (Mainframe), paste and run `/mainframe/repo_server.lua`.
4. On clients, run `/labelClient.lua` (or `/dist_agent.lua` and use the Distributor page on Pocket).
5. On Pocket, install BaseControl and (optionally) add the Updates/Distributor pages.

## Updates Flow
- Commit changes to this repo → GitHub Action rebuilds `manifest.json`.
- Mainframe polls `manifest.json`, caches files, and broadcasts `update`.
- Clients detect update → download → verify checksum → auto-reboot into new version.

## Versioning
- `clients/labelClient.lua` — set `CLIENT_VER = "vMAJOR.MINOR.PATCH"`.
- `basectl/main.lua` — set `APP_VER = "vMAJOR.MINOR.PATCH"` for Pocket app.
- Workflow extracts versions into `manifest.json`.

## License
MIT (or your choice).
