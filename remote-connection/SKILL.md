---
name: remote-connection
description: Use when needing to operate a remote server over SSH — running commands, checking status/logs/processes/disk, transferring files, or deploying projects. Triggers: 远程服务器 / 服务器运维 / 查看服务器状态日志 / 上传下载文件 / Docker 部署 / 在服务器上执行命令或脚本。Managed servers: 8.156.66.24 (CentOS 7) and 47.108.217.78 (Ubuntu 22.04), both root@22 key auth. Always connect through this skill's SSH helper for consistent params and timeouts.
---

# remote-connection

## 概述

统一封装到远程服务器的连接方式，覆盖运维、部署、远程开发三类场景。核心是辅助脚本 `scripts/rc`，把 SSH 参数集中在服务器配置表中，支持多台服务器，避免每次连接重复书写并保证超时/免密处理一致。新增服务器只需在脚本的 `SERVERS` 表里加一行。

**已管理服务器速查：**

| 选择键 | IP | 系统 | 用户/端口 | 资源 |
|---|---|---|---|---|
| `main`（默认） | `8.156.66.24` | CentOS 7 | root@22 免密 | 1.7G 内存（紧张）· 磁盘 40G/已用14G · 已装 docker、python3 |
| （用 IP 选择） | `47.108.217.78` | Ubuntu 22.04 | root@22 免密 | 2核·1.6G 内存（可用200M）· 磁盘 40G/已用7.4G |

两机系统不同：**CentOS 装包用 `yum`，Ubuntu 用 `apt`**，其余运维命令（systemctl/docker）通用。

## 使用方式

### 方式一：辅助脚本（推荐）

脚本路径：`C:\Users\HYH\.claude\skills\remote-connection\scripts\rc`

默认连接 `main`（8.156.66.24）。切换服务器用 `-s <别名|IP>`（放在子命令之前）。

| 子命令 | 说明 |
|---|---|
| `rc run "<命令>"` | 远程执行命令，非交互式，直接输出结果 |
| `rc push <本地> <远程>` | 上传文件/目录（scp -r） |
| `rc pull <远程> <本地>` | 下载文件/目录（scp -r） |
| `rc sftp put <本地> <远程>` | sftp 上传（适合大文件/断点） |
| `rc sftp get <远程> <本地>` | sftp 下载 |
| `rc shell` | 进入交互式 shell |
| `rc info` | 服务器状态速览（负载/内存/磁盘/系统） |
| `rc ping` | 连通性快速检查 |
| `rc list` | 列出已配置的服务器 |

切换服务器示例：

```bash
rc -s 47.108.217.78 run "free -h"     # 在 Ubuntu 机上执行
rc -s 47.108.217.78 info              # 查看新服务器状态
rc -s 47.108.217.78 push ./a.txt /opt/  # 上传到新服务器
```

脚本内置 `BatchMode=yes`（绝不进密码交互，防止卡死）和 `ConnectTimeout=10`。改服务器只需编辑脚本顶部 `SERVERS` 表。

### 方式二：直接 ssh

```bash
ssh root@8.156.66.24 "free -h"
ssh root@47.108.217.78 "free -h"
```

## 常用命令模板

### 运维 · 状态与资源

```bash
rc run "free -h && df -h / && uptime"    # 内存+磁盘+负载（默认机）
rc -s 47.108.217.78 run "free -h"        # 查新服务器内存
rc run "top -bn1 | head -15"             # 进程占用排行
rc run "ss -tlnp"                        # 监听端口与服务
rc run "tail -n 50 /var/log/messages"    # 系统日志（CentOS）
```

### 运维 · 服务与 Docker

```bash
rc run "systemctl status docker --no-pager"   # 服务状态
rc run "systemctl restart <service>"          # 重启服务
rc run "docker ps -a"                          # 容器列表
rc run "docker logs --tail 50 <container>"     # 容器日志
rc run "docker system df"                      # docker 磁盘占用
```

### 部署 · 上传 + 执行

```bash
rc push ./dist /opt/app/dist                 # 1. 上传构建产物
rc run "cd /opt/app && docker compose up -d --build"  # 2. 构建并启动
rc run "docker ps"                           # 3. 验证
```

### 远程开发 · 快速改文件

```bash
rc run "sed -i 's/8080/9090/' /opt/app/config.yml"   # 精确替换
rc pull /etc/nginx/nginx.conf ./nginx.conf.bak        # 拉到本地改完再 push 回去
```

## 常见错误

| 症状 | 原因与对策 |
|---|---|
| `Batch mode is disabled` / 卡在密码 | 目标机没有本机公钥 → 本机 `ssh-copy-id root@<IP>` 一次（用对应 IP） |
| 命令含引号/管道被本地解析 | 用 `rc run "整条命令"` 包一层双引号，外层再包就转义 |
| `Connection timed out` | 服务器网络或防火墙；先 `rc ping` 定位 |
| push/pull 目录没递归 | `rc` 已带 `-r`；直接 scp 需手动加 `-r` |
| 传中文文件乱码 | 目标路径避免中文；内容乱码改用 `rc sftp` 或 base64 |
| 内存不足（free 后 available < 100M） | 先 `rc run "docker system prune -af"` 或清日志，勿盲目起新服务 |
| 装包找不到（yum/apt 混用） | 先确认目标机系统：`rc info`；CentOS 用 yum，Ubuntu 用 apt |

## 何时不用

- 本机文件操作（无远程需求）→ 直接用本地工具
- 短时一次性连接 → 直接 `ssh` 即可
- 未配置的服务器 → 在脚本 `SERVERS` 表加一行，或用 `ssh root@<IP>` 临时连接
