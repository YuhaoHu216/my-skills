---
name: project-deploy
description: Use when 新建项目需要部署到服务器、或已有项目要重新部署/迁移服务器。交互式流程：先询问用户确认服务器/项目名/端口/域名等参数（不写死，仅示例），再询问是否一起部署中间件(MySQL/Redis/Milvus)及是否改其配置，最后按标准目录结构部署。适用 Vue+Vite 前端 + Spring Boot 后端。触发词：部署项目 / 上线 / 项目结构 / 换服务器。
---

# Project Deploy

## Overview

把项目部署到**用户指定的服务器**（不绑定任何固定机器）。这是一套**交互式部署流程**：每步先问清用户意图再动手，参数一律以用户为准、文档中出现的值只是示例。部署时按固定的标准目录结构落地，可挂载中间件（MySQL/Redis/Milvus）一并部署。

> 核心原则：**不清楚就问用户，别猜。** 服务器 IP、项目名、端口、域名都是示例值，实际以用户指定为准。

## 部署流程（含询问节点）

### Step 0 — 收集部署参数（先问用户）

部署任何东西之前，先向用户确认以下参数（示例值仅为展示格式）：

| 参数 | 示例（仅为示例） | 说明 |
|---|---|---|
| 服务器 | `47.108.217.78` | 用户指定的任意服务器，root 免密 |
| 项目名 | `my-blog` | 目录名 + 容器名前缀 |
| API 端口 | `8085` | 后端监听端口 |
| 前端对外端口 | `5185` | Nginx 对外端口 |
| 域名（可选） | `my-blog.example.com` | 给了走 HTTPS，不给用 IP:端口 |

有任一参数用户没明说、或与服务器现状可能冲突，**直接询问**，不要自己定。

### Step 1 — 询问是否一起部署中间件

问用户：**“这次部署需要一起部署中间件吗？（MySQL / Redis / Milvus 向量库）”**

- **不需要** → 只部署项目本体（`api` + `web`），跳 **Step 4**。
- **需要** → 进 **Step 2**。

### Step 2 — 询问中间件怎么配

按用户选择逐一确认（不擅自改默认值）：

- **MySQL / Redis**：
  - 先问：目标服务器上是否已有共享中间件（如 `infra-mysql` / `infra-redis`）？**有 → 询问是否复用**（项目直接连容器名，不新建）；**没有/要新建 → 询问是否改配置**。
  - 需改的配置项：`端口`、`root 密码`、`数据目录`（默认 `backend/mysql/data`）、`内存限制`。
  - 用户说“默认就行” → 用模板默认值，不要改动。
- **Milvus 向量库**：
  - 询问是否用默认配置，需要改：`端口(19530)`、`内存上限`、`minio 账号密码`。
  - 说明：Milvus 依赖 etcd + minio，内存占用大（建议 2G+），小内存服务器要提醒用户。

### Step 3 — 部署中间件

按确认后的配置部署中间件（模板见 `templates/docker-compose-infra.yml` / `docker-compose-milvus.yml`）：

- 数据落位：MySQL → `backend/mysql/data`、Redis → `backend/redis/data`、Milvus → named volume（`<PROJECT>_etcd_data/minio_data/milvus_data`）。
- 全部挂 `shared-infra` 网络，等 healthcheck 通过再继续。

### Step 4 — 部署项目本体（标准结构）

按 **第 5 节结构** 在服务器创建 `/root/<PROJECT>/`，放 `docker-compose.yml`、`dockerfile`、`backend/*.jar`、`frontend/nginx/*`，然后：

```bash
ssh root@<服务器IP> "docker network inspect shared-infra >/dev/null 2>&1 || docker network create shared-infra"
scp -r backend/*.jar docker-compose.yml dockerfile root@<IP>:/root/<PROJECT>/
scp -r frontend/nginx/* root@<IP>:/root/<PROJECT>/frontend/nginx/
ssh root@<IP> "cd /root/<PROJECT> && docker compose up -d --build && docker ps"
```

（示例命令，IP/项目名替换为用户确认的值。）

### Step 5 — 配置网关

- **有域名**：Caddy（项目内或共享）Caddyfile 加 `域名 → reverse_proxy <PROJECT>-web:5173`，自动签发证书。
- **无域名**：用 `http://<IP>:<前端端口>` 访问，跳过网关。

### Step 6 — 验证

`docker ps` 确认 Up、`curl -I localhost:<WEB_PORT>`、`docker logs --tail 50 <PROJECT>-api`；有中间件时 `docker ps` 确认其 healthy。**验证后把访问地址回给用户。**

## 询问话术（可直接用）

```
1) 目标服务器 IP 是？（示例：47.108.217.78 —— 仅为示例，以你为准）
2) 项目名叫什么？（示例：my-blog）
3) API 端口和前端对外端口？（示例：8085 / 5185）
4) 需要域名吗？（给了配 HTTPS，不给用 IP:端口访问）
5) 需要一起部署中间件吗？（MySQL / Redis / Milvus 向量库）
   - 需要的话：服务器上已有共享的 MySQL/Redis 吗？复用还是新建？
   - 配置（端口/密码/数据目录/内存）要改默认值吗？
```

## 5. 项目目录结构（部署时按此创建）

```
/root/<PROJECT>/
├── docker-compose.yml                # api + web (+ caddy)
├── docker-compose-infra.yml          # MySQL + Redis（中间件）
├── docker-compose-milvus.yml         # etcd + minio + milvus + attu（向量库）
├── dockerfile                        # COPY jar + exec java
├── backend/
│   ├── <app>.jar                     # Maven 产物
│   ├── application-prod.yml          # 生产配置（挂载覆盖，可选）
│   ├── mysql/{data,conf,init}/       # MySQL 数据/配置/初始化
│   └── redis/{data,redis.conf}       # Redis 数据/配置
├── frontend/nginx/
│   ├── nginx.conf                    # /api 分流 + 静态 + SPA fallback
│   └── html/                         # Vite dist
├── uploads/                          # 上传文件（bind mount）
├── caddy/                            # 网关（给域名时）
│   ├── Caddyfile
│   ├── data/                         # TLS 证书
│   └── config/
└── backup/                           # 备份脚本 + 数据（可选）
```

**中间件只建一处**：服务器上已有共享中间件就复用（容器名 `infra-mysql:3306` / `infra-redis:6379`），避免重复占端口。**端口约定**：Nginx 内部固定 5173，对外每项目不同；API 每项目一端口；中间件端口全服务器唯一。

## 常见坑

| 症状 | 原因与对策 |
|---|---|
| 容器重建后 502 | nginx 直接 `proxy_pass http://容器名` → 用 `resolver 127.0.0.11` + 变量动态解析 |
| 改后端还是旧代码 | 忘 `--build`；`docker compose up -d --build` |
| 容器 OOMKilled | 内存不够 → `docker stats` 看用量，调 `mem_limit`/`JAVA_OPTS`；小内存服务器别上 Milvus |
| 端口起不来 | 对外端口被占 → 换端口（先问用户或告知冲突） |
| 中间件连不上 | 确认同挂 `shared-infra` 网络；共享的只建一处 |
| 证书不生效 | `caddy/data` 卷被清 → 自动重签，等待 |
| 密钥明文 | 用 `.env`/外部配置挂载，勿写 compose |

## 服务器接入

- 已管理服务器：`remote-connection` 的 `rc -s <别名|IP>`。
- 新服务器：先 `ssh-copy-id root@<IP>`；建议加进 `remote-connection` 的 `SERVERS` 表。
- 部署前探测：`ssh root@<IP> "cat /etc/os-release|head -1; free -h; docker --version"`（CentOS 用 yum、Ubuntu 用 apt）。
