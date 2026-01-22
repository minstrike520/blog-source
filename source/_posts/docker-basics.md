---
title: Docker Basics
tags:
  - IT-Basics
categories:
  - IT筆記
date: 2025-12-30 16:04:00
---
## 更新
官網有對個別系統的安裝方式做出解釋。
比如 Debian 要看: https://docs.docker.com/engine/install/debian/

## 啟用

啟動 docker.service（使用 systemd 的場合）。這邊也可以執行一次 `enable` 或 `enable --now`，就會開機自動啟動。不過我個人習慣手動開啟。（應該多少能加快一點開機速度吧？）

```bash
systemctl start docker
```

## 映像檔管理

從官方「<ruby>映像檔倉庫<rt>registry</rt></ruby>」下載現成的 image。

```bash
docker pull <IMAGE_NAME>
```

根據 `./Dockerfile` 來建置 image。

```bash
docker build -t <IMAGE_NAME> .
```

產生一次性的容器，並在其中執行指令（此處為 `/bin/sh`）。

```bash
docker run --rm -it --entrypoint /bin/sh <IMAGE_NAME>
```

## 容器管理

啟動非活躍狀態的 container。

```bash
docker start <CONTAINER_NAME>
```

中止活躍狀態的 container。

```bash
docker stop <CONTAINER_NAME>
```

產生一個新的 container 並執行。相當於 `docker create` 跟 `docker start`。

```bash
docker run --name <CONTAINER_NAME> <IMAGE_NAME> 
```

執行 container 內的指令。

```bash
docker exec -it <CONTAINER_NAME> <COMMAND ...>
```

