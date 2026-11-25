<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset=".github/assets/banner-dark.png">
    <img src=".github/assets/banner.png" alt="Proxmox: one line, one container" width="100%">
  </picture>
</p>

<p align="center">
  <a href="https://github.com/junkerderprovinz/proxmox-apps/actions/workflows/style.yml"><img src="https://img.shields.io/github/actions/workflow/status/junkerderprovinz/proxmox-apps/style.yml?branch=main&label=Style&style=for-the-badge&logo=githubactions&logoColor=white" alt="Style" height="36"></a>&nbsp;
  <a href="#6-apps"><img src="https://img.shields.io/badge/Apps-32-2496ED?style=for-the-badge&logo=linuxcontainers&logoColor=white" alt="Apps" height="36"></a>&nbsp;
  <a href="https://www.proxmox.com/en/proxmox-virtual-environment"><img src="https://img.shields.io/badge/Proxmox%20VE-9.2-E57000?style=for-the-badge&logo=proxmox&logoColor=white" alt="Proxmox VE 9.2" height="36"></a>&nbsp;
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge&logo=opensourceinitiative&logoColor=white" alt="License" height="36"></a>
</p>

<p align="center">
junkerderprovinz's apps on <b>Proxmox VE 9.2</b>, each with one line on the host shell: installed directly in a container, from the app's image, or with Docker. Every route in the table below was tested on Proxmox 9.2.
</p>

<br>

<p><a id="table-of-contents" href="#table-of-contents"><picture><source media="(prefers-color-scheme: dark)" srcset=".github/assets/sections/table-of-contents-dark.svg"><img src=".github/assets/sections/table-of-contents.svg" alt="Table of Contents" width="100%"></picture></a></p>

1. [Support](#1-support)
2. [Three ways in](#2-three-ways-in)
3. [Install with a script](#3-install-with-a-script)
4. [Run the image](#4-run-the-image)
5. [Run it with Docker](#5-run-it-with-docker)
6. [Apps](#6-apps)
7. [How AI is used here](#7-how-ai-is-used-here)

<br>

<p><a id="1-support" href="#1-support"><picture><source media="(prefers-color-scheme: dark)" srcset=".github/assets/sections/1-support-dark.svg"><img src=".github/assets/sections/1-support.svg" alt="1. Support" width="100%"></picture></a></p>

<p align="center">
A one-knight job: I build these, keep them running, work through the issues and add what people ask for, until nothing is missing. They are free, with no accounts, no telemetry, no ads and no paid tier. No asterisk anywhere. Nothing readable ever leaves your own walls. Forged on evenings and weekends, with heart and stubbornness.
</p>

<p align="center">
If one of these has earned a place on your server, toss a coin to your knight: it helps cover the costs and keeps the project alive. It also makes this knight's heart beat a little faster. Three ways below, whichever suits you.
</p>

<p align="center">
  <a href="https://buymeacoffee.com/junkerderprovinz"><img src="https://raw.githubusercontent.com/junkerderprovinz/junkerderprovinz/main/donate/buttons/give.svg#svgView(viewBox(0,0,841.9,245.3))" alt="Buy me a coffee" width="160" height="46.62"></a>
  &nbsp;
  <a href="https://www.paypal.com/donate/?hosted_button_id=76FVV52TKXTUS"><img src="https://raw.githubusercontent.com/junkerderprovinz/junkerderprovinz/main/donate/buttons/give.svg#svgView(viewBox(841.9,0,841.9,245.3))" alt="PayPal" width="160" height="46.62"></a>
  &nbsp;
  <a href="https://junkerderprovinz.github.io/junkerderprovinz/"><img src="https://raw.githubusercontent.com/junkerderprovinz/junkerderprovinz/main/donate/buttons/give.svg#svgView(viewBox(1683.8,0,841.9,245.3))" alt="Donate with crypto" width="160" height="46.62"></a>
</p>

<br>

<p><a id="2-three-ways-in" href="#2-three-ways-in"><picture><source media="(prefers-color-scheme: dark)" srcset=".github/assets/sections/2-three-ways-in-dark.svg"><img src=".github/assets/sections/2-three-ways-in.svg" alt="2. Three ways in" width="100%"></picture></a></p>

For the apps written in Go, a script in the format of the [Proxmox VE Community Scripts](https://github.com/community-scripts/ProxmoxVE) creates a Debian 13 container and builds the app right in it. Updates run inside the container with the `update` command, and settings stay where they are.

The second way is the app's image. Proxmox 9.1 and newer can turn a container image into a container of its own. `image.sh` pulls the image, keeps the app's data in folders under `/srv/<app>` on the host and creates the container. To update, it pulls the image again and replaces the container, with the same folders and the same address. Proxmox still calls this feature a technology preview.

Both ways leave out the Docker layer, so an app needs less memory and disk, and Proxmox backs it up together with its container. Nothing is wrong with Docker, though. For apps that need it, such as BombVault and OpenHands, `compose.sh` creates a container with Docker and starts the app's compose file in it.

<br>

<p><a id="3-install-with-a-script" href="#3-install-with-a-script"><picture><source media="(prefers-color-scheme: dark)" srcset=".github/assets/sections/3-install-with-a-script-dark.svg"><img src=".github/assets/sections/3-install-with-a-script.svg" alt="3. Install with a script" width="100%"></picture></a></p>

Run it in the shell of the Proxmox host and answer the questions, or press Enter for the defaults:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/junkerderprovinz/proxmox-apps/main/ct/knightloader.sh)"
```

Replace `knightloader` with `arrowloop`, `cannoncommander`, `castleparcel`, `parleyport` or `trickwork`. The scripts use the engine of the Community Scripts, so the questions, the defaults and the advanced settings work as there. To update an app later, open its container's console and run `update`.

KnightLoader built this way cannot open DLC files, because the key for them only goes into the official image.

<br>

<p><a id="4-run-the-image" href="#4-run-the-image"><picture><source media="(prefers-color-scheme: dark)" srcset=".github/assets/sections/4-run-the-image-dark.svg"><img src=".github/assets/sections/4-run-the-image.svg" alt="4. Run the image" width="100%"></picture></a></p>

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/junkerderprovinz/proxmox-apps/main/image.sh) install arrowloop
```

The container gets its address by DHCP. To pick the ID, the address or the size, set them in front of the command:

```bash
CTID=120 NET="ip=192.168.1.50/24,gw=192.168.1.1" MEMORY=1024 bash <(curl -fsSL https://raw.githubusercontent.com/junkerderprovinz/proxmox-apps/main/image.sh) install arrowloop
```

Some apps need values before their first start, such as an admin password. The script names the missing ones and stops, and they go in front of the command the same way:

```bash
IDM_ADMIN_PASSWORD='choose-one' OC_URL='https://192.168.1.51:9200' NET="ip=192.168.1.51/24,gw=192.168.1.1" bash <(curl -fsSL https://raw.githubusercontent.com/junkerderprovinz/proxmox-apps/main/image.sh) install opencloud
```

The script keeps them in `/srv/<app>/.env`, readable by root only, so an update needs nothing but:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/junkerderprovinz/proxmox-apps/main/image.sh) update arrowloop
```

The new container only replaces the old one once it answers. If it does not, the old one starts again. `image.sh list` shows every app the script knows.

<br>

<p><a id="5-run-it-with-docker" href="#5-run-it-with-docker"><picture><source media="(prefers-color-scheme: dark)" srcset=".github/assets/sections/5-run-it-with-docker-dark.svg"><img src=".github/assets/sections/5-run-it-with-docker.svg" alt="5. Run it with Docker" width="100%"></picture></a></p>

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/junkerderprovinz/proxmox-apps/main/compose.sh) install bombvault
```

This creates a Debian 13 container with Docker, puts the app's compose file in `/opt/<app>` inside it and starts it. The data stays in the container, so Proxmox backs it up with it. `CTID`, `NET`, `MEMORY` and `DISK` work as with `image.sh`, and so do values the compose file marks as required. For BombVault, the script makes an `APP_KEY` if you do not pass one and shows it at the end. Keep a copy somewhere other than the server, because without it nobody can read the backups.

To update the app and the Docker inside the container:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/junkerderprovinz/proxmox-apps/main/compose.sh) update bombvault
```

The same works for `openhands`.

<br>

<p><a id="6-apps" href="#6-apps"><picture><source media="(prefers-color-scheme: dark)" srcset=".github/assets/sections/6-apps-dark.svg"><img src=".github/assets/sections/6-apps.svg" alt="6. Apps" width="100%"></picture></a></p>

Tested on Proxmox 9.2 with unprivileged containers. "Script" is the route from section 3, "Image" the one from section 4 and "Docker" the one from section 5.

| App | Script | Image | Docker | Needs |
| --- | :---: | :---: | :---: | --- |
| [ArrowLoop](https://github.com/junkerderprovinz/arrowloop) | ✓ | ✓ | | |
| [CannonCommander](https://github.com/junkerderprovinz/cannoncommander) | ✓ | ✓ | | |
| [CastleParcel](https://github.com/junkerderprovinz/castleparcel) | ✓ | ✓ | | HTTPS in front, browsers only encrypt on a secure page |
| [KnightLoader](https://github.com/junkerderprovinz/knightloader) | ✓ | ✓ | | |
| [ParleyPort](https://github.com/junkerderprovinz/parleyport) | ✓ | ✓ | | |
| [TrickWork](https://github.com/junkerderprovinz/trickwork) | ✓ | ✓ | | |
| [BombVault](https://github.com/junkerderprovinz/bombvault) | | | ✓ | |
| [OpenHands](https://github.com/junkerderprovinz/unraid-apps/tree/main/openhands) | | | ✓ | |
| [Euro-Office](https://github.com/junkerderprovinz/euro-office) | | ✓ | | `JWT_SECRET` |
| [Excalidraw](https://github.com/junkerderprovinz/excalidraw) | | ✓ | | |
| [FileBot](https://github.com/junkerderprovinz/filebot) | | ✓ | | |
| [Garage](https://github.com/junkerderprovinz/garage) | | ✓ | | |
| [HandBrake](https://github.com/junkerderprovinz/handbrake) | | ✓ | | |
| [JDownloader](https://github.com/junkerderprovinz/jdownloader) | | ✓ | | |
| [JuiceFS](https://github.com/junkerderprovinz/juicefs) | | ✓ | | |
| [Krusader](https://github.com/junkerderprovinz/krusader) | | ✓ | | |
| [Matrix](https://github.com/junkerderprovinz/matrix) | | ✓ | | a PostgreSQL server, `SERVER_NAME`, `POSTGRES_HOST`, `POSTGRES_PASSWORD` |
| [OpenCloud](https://github.com/junkerderprovinz/opencloud) | | ✓ | | `IDM_ADMIN_PASSWORD`, `OC_URL` |
| [PrusaSlicer](https://github.com/junkerderprovinz/prusaslicer) | | ✓ | | |
| [RustDesk](https://github.com/junkerderprovinz/rustdesk) | | ✓ | | `RELAY` and the three `RUSTDESK_API_RUSTDESK_*` addresses |
| [Seafile](https://github.com/junkerderprovinz/seafile) | | ✓ | | `SEAFILE_SERVER_HOSTNAME`, `INIT_SEAFILE_ADMIN_EMAIL` |
| [Securo](https://github.com/junkerderprovinz/securo) | | ✓ | | |
| [Stellarium](https://github.com/junkerderprovinz/stellarium) | | ✓ | | |
| [Claper](https://github.com/junkerderprovinz/unraid-apps/tree/main/claper) | | ✓ | | a PostgreSQL server, `DATABASE_URL`, `SECRET_KEY_BASE`, `BASE_URL` |
| [CouchDB](https://github.com/junkerderprovinz/unraid-apps/tree/main/couchdb) | | ✓ | | `COUCHDB_PASSWORD` |
| [n8n](https://github.com/junkerderprovinz/unraid-apps/tree/main/n8n) | | ✓ | | a PostgreSQL server, `DB_POSTGRESDB_HOST`, `DB_POSTGRESDB_PASSWORD`, `N8N_HOST`, `WEBHOOK_URL` |
| [Pocket ID](https://github.com/junkerderprovinz/unraid-apps/tree/main/pocket-id) | | ✓ | | `APP_URL` as a domain name, `ENCRYPTION_KEY` |
| [RustFS](https://github.com/junkerderprovinz/unraid-apps/tree/main/rustfs) | | ✓ | | `RUSTFS_ACCESS_KEY`, `RUSTFS_SECRET_KEY` |
| [SeaweedFS](https://github.com/junkerderprovinz/unraid-apps/tree/main/seaweedfs) | | ✓ | | |
| [Silo](https://github.com/junkerderprovinz/unraid-apps/tree/main/silo) | | ✓ | | `MINIO_ROOT_USER`, `MINIO_ROOT_PASSWORD` |
| [Standard Notes WebUI](https://github.com/junkerderprovinz/unraid-apps/tree/main/standardnotes-webui) | | ✓ | | |
| [VersityGW](https://github.com/junkerderprovinz/unraid-apps/tree/main/versitygw) | | ✓ | | `ROOT_ACCESS_KEY`, `ROOT_SECRET_KEY` |

<br>

<p><a id="7-how-ai-is-used-here" href="#7-how-ai-is-used-here"><picture><source media="(prefers-color-scheme: dark)" srcset=".github/assets/sections/7-how-ai-is-used-here-dark.svg"><img src=".github/assets/sections/7-how-ai-is-used-here.svg" alt="7. How AI is used here" width="100%"></picture></a></p>

One knight builds this, and AI is one of the tools I work with, the same way I work with an editor or a compiler. It helps me write code and documentation and it checks my work, and that saves me a good many evenings. It does not make the decisions, though. I read and understand everything before it ships, and if something here breaks, that is on me and not on the tool.

You do not have to take my word for it. The code is open and every release note is written by hand. The issue tracker shows how problems actually get handled, including the ones I got wrong the first time. If you find something that is not right, open an issue and I will look at it.

<br>

Questions, bugs, ideas or feature requests? Please [open a GitHub issue](https://github.com/junkerderprovinz/proxmox-apps/issues).

<sub>Proxmox® is a registered trademark of Proxmox Server Solutions GmbH. This repository is not affiliated with it.</sub>
