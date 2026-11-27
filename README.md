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
  <a href="https://buymeacoffee.com/junkerderprovinz"><img src="https://raw.githubusercontent.com/junkerderprovinz/junkerderprovinz/main/donate/buttons/give.svg#svgView(viewBox(-23.082,-20.153,888.064,285.606))" alt="Buy me a coffee" width="168.773" height="54.278"></a>
  <a href="https://www.paypal.com/donate/?hosted_button_id=76FVV52TKXTUS"><img src="https://raw.githubusercontent.com/junkerderprovinz/junkerderprovinz/main/donate/buttons/give.svg#svgView(viewBox(890.818,-20.153,888.064,285.606))" alt="PayPal" width="168.773" height="54.278"></a>
  <a href="https://junkerderprovinz.github.io/junkerderprovinz/"><img src="https://raw.githubusercontent.com/junkerderprovinz/junkerderprovinz/main/donate/buttons/give.svg#svgView(viewBox(1804.718,-20.153,888.064,285.606))" alt="Donate with crypto" width="168.773" height="54.278"></a>
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

Tested on Proxmox 9.2 with unprivileged containers. Beside each name are the ways the app takes: Script from section 3, Image from section 4 and Docker from section 5.

<!-- apps:start -->
### Apps

*My own software, built and published by junkerderprovinz. Full docs live in each app's own repository.*

<a id="arrowloop"></a>
<img src=".github/readme-icons/arrowloop.png" width="84" align="left" alt="ArrowLoop">

**[ArrowLoop](https://github.com/junkerderprovinz/arrowloop#readme)** · [Script](#3-install-with-a-script) · [Image](#4-run-the-image)<br>
Two-way file sync that shows you the plan before it touches a file, sends deletions to a trash and stops a run that would delete too much.

<br clear="all">

<a id="bombvault"></a>
<img src=".github/readme-icons/bombvault.png" width="84" align="left" alt="BombVault">

**[BombVault](https://github.com/junkerderprovinz/bombvault#readme)** · [Docker](#5-run-it-with-docker)<br>
Backup and full disaster recovery for containers, VMs and the flash, powered by restic, with one-click backup and cross-server restore.

<br clear="all">

<a id="cannoncommander"></a>
<img src=".github/readme-icons/cannoncommander.png" width="84" align="left" alt="CannonCommander">

**[CannonCommander](https://github.com/junkerderprovinz/cannoncommander#readme)** · [Script](#3-install-with-a-script) · [Image](#4-run-the-image)<br>
The most beautiful file manager you will ever run, and the only one you need: two panels, F5 to copy, jobs in the background and a trash for second thoughts.

<br clear="all">

<a id="castleparcel"></a>
<img src=".github/readme-icons/castleparcel.png" width="84" align="left" alt="CastleParcel">

**[CastleParcel](https://github.com/junkerderprovinz/castleparcel#readme)** · [Script](#3-install-with-a-script) · [Image](#4-run-the-image)<br>
The big-file transfer site you know, on your own server and sealed: encrypted in your browser, with an optional owner sign-in, self-expiring share links, file requests and notes.

<br clear="all">

<a id="knightloader"></a>
<img src=".github/readme-icons/knightloader.png" width="84" align="left" alt="KnightLoader">

**[KnightLoader](https://github.com/junkerderprovinz/knightloader#readme)** · [Script](#3-install-with-a-script) · [Image](#4-run-the-image)<br>
Self-hosted download manager for hosters, debrid, torrents, Usenet and video, with an Android app and a browser extension.

<br clear="all">

<a id="parleyport"></a>
<img src=".github/readme-icons/parleyport.png" width="84" align="left" alt="ParleyPort">

**[ParleyPort](https://github.com/junkerderprovinz/parleyport#readme)** · [Script](#3-install-with-a-script) · [Image](#4-run-the-image)<br>
Your own relay for apps that pair their instances: on different networks they meet there, and it passes on what it cannot read.

<br clear="all">

<a id="trickwork"></a>
<img src=".github/readme-icons/trickwork.png" width="84" align="left" alt="TrickWork">

**[TrickWork](https://github.com/junkerderprovinz/trickwork#readme)** · [Script](#3-install-with-a-script) · [Image](#4-run-the-image)<br>
Turns images into proportional-font-aware ASCII art - a rebuild of ASCII Gen 2, picking characters by real ink coverage, not brightness.

<br clear="all">


### Images

*My own custom image builds of third-party apps. Full docs in each app's own repository.*

<a id="euro-office"></a>
<img src=".github/readme-icons/euro-office.png" width="84" align="left" alt="Euro Office">

**[Euro Office](https://github.com/junkerderprovinz/euro-office#readme)** · [Image](#4-run-the-image)<br>
Sovereign, OnlyOffice-compatible document server for browser editing of Office and OpenDocument files, wired into OpenCloud over WOPI.

<br clear="all">

<a id="excalidraw"></a>
<img src=".github/readme-icons/excalidraw.png" width="84" align="left" alt="Excalidraw">

**[Excalidraw](https://github.com/junkerderprovinz/excalidraw#readme)** · [Image](#4-run-the-image)<br>
The hand-drawn whiteboard, built so it keeps to itself: shared links, live collaboration, the session scene and even the fonts all come from your own server.

<br clear="all">

<a id="filebot"></a>
<img src=".github/readme-icons/filebot.png" width="84" align="left" alt="FileBot">

**[FileBot](https://github.com/junkerderprovinz/filebot#readme)** · [Image](#4-run-the-image)<br>
The FileBot media renamer in your browser on a fast Selkies web desktop, dark from the first start. Bring your own FileBot license.

<br clear="all">

<a id="garage"></a>
<img src=".github/readme-icons/garage.png" width="84" align="left" alt="Garage">

**[Garage](https://github.com/junkerderprovinz/garage#readme)** · [Image](#4-run-the-image)<br>
Garage's S3-compatible object store and its web admin panel in one container, with the single-node layout and S3 keys created automatically.

<br clear="all">

<a id="handbrake"></a>
<img src=".github/readme-icons/handbrake.png" width="84" align="left" alt="HandBrake">

**[HandBrake](https://github.com/junkerderprovinz/handbrake#readme)** · [Image](#4-run-the-image)<br>
HandBrake's full GUI on a fast Selkies web desktop, GPU-accelerated on NVIDIA, Intel and AMD, with a watch folder that converts on its own.

<br clear="all">

<a id="jdownloader"></a>
<img src=".github/readme-icons/jdownloader.png" width="84" align="left" alt="JDownloader">

**[JDownloader](https://github.com/junkerderprovinz/jdownloader#readme)** · [Image](#4-run-the-image)<br>
JDownloader 2 with a complete, sleek dark UI out of the box, on a fast Selkies web desktop in your browser. No VNC client, no install.

<br clear="all">

<a id="juicefs"></a>
<img src=".github/readme-icons/juicefs.png" width="84" align="left" alt="JuiceFS">

**[JuiceFS](https://github.com/junkerderprovinz/juicefs#readme)** · [Image](#4-run-the-image)<br>
The JuiceFS S3 gateway, with the file system created on first boot. Metadata goes to a database, file contents to an object store.

<br clear="all">

<a id="krusader"></a>
<img src=".github/readme-icons/krusader.png" width="84" align="left" alt="Krusader">

**[Krusader](https://github.com/junkerderprovinz/krusader#readme)** · [Image](#4-run-the-image)<br>
Twin-pane KDE file manager with a native dark theme on a fast Selkies web desktop, with Kate, krename and RAR built in.

<br clear="all">

<a id="matrix"></a>
<img src=".github/readme-icons/matrix.png" width="84" align="left" alt="Matrix">

**[Matrix](https://github.com/junkerderprovinz/matrix#readme)** · [Image](#4-run-the-image)<br>
A complete Matrix homeserver in one container: Synapse, coturn, Element Web and the Ketesa admin UI, with optional TURN over TLS.

<br clear="all">

<a id="opencloud"></a>
<img src=".github/readme-icons/opencloud.png" width="84" align="left" alt="OpenCloud">

**[OpenCloud](https://github.com/junkerderprovinz/opencloud#readme)** · [Image](#4-run-the-image)<br>
One-click OpenCloud file sync &amp; share: auto-runs init, heals appdata permissions and honours PUID/PGID.

<br clear="all">

<a id="prusaslicer"></a>
<img src=".github/readme-icons/prusaslicer.png" width="84" align="left" alt="PrusaSlicer">

**[PrusaSlicer](https://github.com/junkerderprovinz/prusaslicer#readme)** · [Image](#4-run-the-image)<br>
The PrusaSlicer 3D-printing slicer in your browser on a fast Selkies web desktop: slice and export G-code, no VNC client (amd64 + arm64).

<br clear="all">

<a id="rustdesk"></a>
<img src=".github/readme-icons/rustdesk.png" width="84" align="left" alt="RustDesk">

**[RustDesk](https://github.com/junkerderprovinz/rustdesk#readme)** · [Image](#4-run-the-image)<br>
Your own RustDesk server with a web console, accounts, an address book on every client and devices that can change their ID.

<br clear="all">

<a id="seafile"></a>
<img src=".github/readme-icons/seafile.png" width="84" align="left" alt="Seafile">

**[Seafile](https://github.com/junkerderprovinz/seafile#readme)** · [Image](#4-run-the-image)<br>
The official Seafile server from one template, with its secrets generated on first start and MariaDB, Redis and the notification server built in on request.

<br clear="all">

<a id="securo"></a>
<img src=".github/readme-icons/securo.png" width="84" align="left" alt="Securo">

**[Securo](https://github.com/junkerderprovinz/securo#readme)** · [Image](#4-run-the-image)<br>
The Securo finance manager with its worker and scheduler in one container, on your own PostgreSQL and Redis or on built-in ones.

<br clear="all">

<a id="stellarium"></a>
<img src=".github/readme-icons/stellarium.png" width="84" align="left" alt="Stellarium">

**[Stellarium](https://github.com/junkerderprovinz/stellarium#readme)** · [Image](#4-run-the-image)<br>
The Stellarium planetarium in your browser on a fast Selkies web desktop: pan the sky, zoom a nebula, scrub through time, no VNC client.

<br clear="all">


### Wrappers

*Thin templates over a third-party upstream image (no custom build). Full docs in each app's folder below.*

<a id="claper"></a>
<img src=".github/readme-icons/claper.png" width="84" align="left" alt="Claper">

**[Claper](https://github.com/junkerderprovinz/unraid-apps/blob/main/claper/README.md)** · [Image](#4-run-the-image)<br>
Open-source, self-hosted Mentimeter/Slido alternative: live polls, Q&amp;A and quizzes alongside your slides, audience joins from their own device, no app install.

<br clear="all">

<a id="couchdb"></a>
<img src=".github/readme-icons/couchdb.png" width="84" align="left" alt="CouchDB">

**[CouchDB](https://github.com/junkerderprovinz/unraid-apps/blob/main/couchdb/README.md)** · [Image](#4-run-the-image)<br>
The HTTP/JSON document database behind Obsidian LiveSync, on the official 3.x image with data, config and CORS mapped so they survive a recreate or update.

<br clear="all">

<a id="n8n"></a>
<img src=".github/readme-icons/n8n.png" width="84" align="left" alt="n8n">

**[n8n](https://github.com/junkerderprovinz/unraid-apps/blob/main/n8n/README.md)** · [Image](#4-run-the-image)<br>
Workflow automation connecting 400+ apps and APIs, on PostgreSQL by default, with every option exposed in the Unraid template form.

<br clear="all">

<a id="openhands"></a>
<img src=".github/readme-icons/openhands.png" width="84" align="left" alt="OpenHands">

**[OpenHands](https://github.com/junkerderprovinz/unraid-apps/blob/main/openhands/README.md)** · [Docker](#5-run-it-with-docker)<br>
Open-source AI software-development agent, pre-wired for a local Ollama model, so it reads, writes and runs code with no cloud account.

<br clear="all">

<a id="pocket-id"></a>
<img src=".github/readme-icons/pocket-id.png" width="84" align="left" alt="Pocket ID">

**[Pocket ID](https://github.com/junkerderprovinz/unraid-apps/blob/main/pocket-id/README.md)** · [Image](#4-run-the-image)<br>
Passkey login for every app on your server that speaks OpenID Connect, with users, groups and an audit log, on SQLite or PostgreSQL.

<br clear="all">

<a id="rustfs"></a>
<img src=".github/readme-icons/rustfs.png" width="84" align="left" alt="RustFS">

**[RustFS](https://github.com/junkerderprovinz/unraid-apps/blob/main/rustfs/README.md)** · [Image](#4-run-the-image)<br>
An S3 object store in Rust, with the two fixes it needs to run on Unraid at all. Pre-release: every version so far is a release candidate.

<br clear="all">

<a id="seaweedfs"></a>
<img src=".github/readme-icons/seaweedfs.png" width="84" align="left" alt="SeaweedFS">

**[SeaweedFS](https://github.com/junkerderprovinz/unraid-apps/blob/main/seaweedfs/README.md)** · [Image](#4-run-the-image)<br>
Fast, S3-API-compatible object store on the official image, the actively-maintained alternative now that MinIO's open edition is done.

<br clear="all">

<a id="silo"></a>
<img src=".github/readme-icons/silo.png" width="84" align="left" alt="Silo">

**[Silo](https://github.com/junkerderprovinz/unraid-apps/blob/main/silo/README.md)** · [Image](#4-run-the-image)<br>
MinIO, still maintained: PGSTY's fork of the open-source server, with the full web console. It reads an existing MinIO data folder as it is.

<br clear="all">

<a id="standardnotes-webui"></a>
<img src=".github/readme-icons/standardnotes-webui.png" width="84" align="left" alt="Standard Notes Web UI">

**[Standard Notes Web UI](https://github.com/junkerderprovinz/unraid-apps/blob/main/standardnotes-webui/README.md)** · [Image](#4-run-the-image)<br>
The official Standard Notes web client, self-hosted next to your own sync server for end-to-end encrypted notes in the browser.

<br clear="all">

<a id="versitygw"></a>
<img src=".github/readme-icons/versitygw.png" width="84" align="left" alt="VersityGW">

**[VersityGW](https://github.com/junkerderprovinz/unraid-apps/blob/main/versitygw/README.md)** · [Image](#4-run-the-image)<br>
An S3 API in front of a share you already have: top-level folders become buckets, and every file stays readable over SMB and NFS at the same time.

<br clear="all">
<!-- apps:end -->

<br>

<p><a id="7-how-ai-is-used-here" href="#7-how-ai-is-used-here"><picture><source media="(prefers-color-scheme: dark)" srcset=".github/assets/sections/7-how-ai-is-used-here-dark.svg"><img src=".github/assets/sections/7-how-ai-is-used-here.svg" alt="7. How AI is used here" width="100%"></picture></a></p>

One knight builds this, and AI is one of the tools I work with, the same way I work with an editor or a compiler. It helps me write code and documentation and it checks my work, and that saves me a good many evenings. It does not make the decisions, though. I read and understand everything before it ships, and if something here breaks, that is on me and not on the tool.

You do not have to take my word for it. The code is open and every release note is written by hand. The issue tracker shows how problems actually get handled, including the ones I got wrong the first time. If you find something that is not right, open an issue and I will look at it.

<br>

Questions, bugs, ideas or feature requests? Please [open a GitHub issue](https://github.com/junkerderprovinz/proxmox-apps/issues).

<sub>Proxmox® is a registered trademark of Proxmox Server Solutions GmbH. This repository is not affiliated with it.</sub>
