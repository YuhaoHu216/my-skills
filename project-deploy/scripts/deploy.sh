#!/usr/bin/env bash
# ============================================================
# project-deploy · deploy.sh —— 一键部署 Vue+Vite + Spring Boot 到指定服务器
#
# 所有参数来自命令行，IP/项目名/端口由用户交互确认后传入，脚本不写死。
# 用法:
#   ./deploy.sh --server <IP> --project <名> [选项]
#
# 必选:
#   --server <IP>        目标服务器 IP（root 免密，示例 47.108.217.78）
#   --project <名>       项目名（目录/容器名前缀，小写+连字符，示例 my-blog）
# 可选:
#   --api-port <p>       后端端口（示例 8085）
#   --web-port <p>       前端对外端口（示例 5185）
#   --domain <域名>      给则自动配 Caddy HTTPS（示例 my-blog.example.com）
#   --config <文件>      本机 application-prod.yml，挂载覆盖 jar 内配置
#   --skip-build         跳过本地构建（用已有产物）
#   --java-base <镜像>   JDK 基础镜像（示例 eclipse-temurin:21）
#   --heap <M>           JVM 堆内存 MB（示例 320）
#   --mem-limit <M>      API 容器内存硬限制 MB（示例 800）
#
# 前提: 目标机已配好本机公钥免密；本地 backend/ 为 Maven 工程、frontend/ 为 Vite 工程。
# ============================================================
set -euo pipefail

# ---------- 参数解析 ----------
SERVER=""; PROJECT=""; API_PORT="8080"; WEB_PORT="5173"; DOMAIN=""; CONFIG=""
SKIP_BUILD=0; JAVA_BASE="eclipse-temurin:21"; HEAP="320"; MEM_LIMIT="800"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --server)    SERVER="$2"; shift 2 ;;
    --project)   PROJECT="$2"; shift 2 ;;
    --api-port)  API_PORT="$2"; shift 2 ;;
    --web-port)  WEB_PORT="$2"; shift 2 ;;
    --domain)    DOMAIN="$2"; shift 2 ;;
    --config)    CONFIG="$2"; shift 2 ;;
    --skip-build) SKIP_BUILD=1; shift ;;
    --java-base) JAVA_BASE="$2"; shift 2 ;;
    --heap)      HEAP="$2"; shift 2 ;;
    --mem-limit) MEM_LIMIT="$2"; shift 2 ;;
    *) echo "未知参数: $1" >&2; exit 1 ;;
  esac
done

[[ -n "$SERVER" ]] || { echo "缺少 --server <IP>" >&2; exit 1; }
[[ -n "$PROJECT" ]] || { echo "缺少 --project <名>" >&2; exit 1; }

echo ">>> 部署目标: $SERVER  项目: $PROJECT  API端口: $API_PORT  前端端口: $WEB_PORT"
echo "    域名: ${DOMAIN:-（无，用 IP 访问）}  JDK: $JAVA_BASE  堆: ${HEAP}M  内存限制: ${MEM_LIMIT}M"
echo "    若与预期不符请 Ctrl+C 后重新传入正确参数"
read -rp ">>> 确认无误，开始部署？[y/N] " CONFIRM
[[ "$CONFIRM" =~ ^[yY] ]] || { echo "已取消"; exit 1; }

# ---------- 本地项目结构检查 ----------
[[ -d backend ]] || { echo "未找到 backend/（当前目录应是项目根）" >&2; exit 1; }
[[ -d frontend ]] || { echo "未找到 frontend/" >&2; exit 1; }

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TPL="$SKILL_DIR/templates"

# ---------- 占位符替换工具 ----------
esc() { printf '%s' "$1" | sed -e 's/[&|\\]/\\&/g'; }
gen() { # gen <模板> <输出>
  sed -e "s|{{PROJECT}}|$(esc "$PROJECT")|g" \
      -e "s|{{API_PORT}}|$(esc "$API_PORT")|g" \
      -e "s|{{WEB_PORT}}|$(esc "$WEB_PORT")|g" \
      -e "s|{{JAVA_BASE}}|$(esc "$JAVA_BASE")|g" \
      -e "s|{{MEM_LIMIT}}|$(esc "$MEM_LIMIT")|g" \
      -e "s|{{JAVA_OPTS}}|$(esc "-Xmx${HEAP}m -Xms${HEAP}m -XX:MaxMetaspaceSize=128m -XX:+UseG1GC")|g" \
      "$1" > "$2"
}

# ---------- 1. 生成部署文件 ----------
echo ">>> 生成部署文件..."
mkdir -p frontend/nginx/html
gen "$TPL/docker-compose.yml" docker-compose.yml
gen "$TPL/dockerfile" dockerfile
gen "$TPL/nginx.conf" frontend/nginx/nginx.conf

# ---------- 2. 本地构建 ----------
if [[ $SKIP_BUILD -eq 0 ]]; then
  echo ">>> 构建后端 (mvn package)..."
  command -v mvn >/dev/null || { echo "本机无 mvn，请手动构建或加 --skip-build" >&2; exit 1; }
  ( cd backend && mvn clean package -DskipTests -q )
  echo ">>> 构建前端 (npm run build)..."
  command -v npm >/dev/null || { echo "本机无 npm，请手动构建或加 --skip-build" >&2; exit 1; }
  ( cd frontend && npm run build )
fi

JAR="$(ls backend/*.jar 2>/dev/null | head -1 || true)"
[[ -n "$JAR" ]] || { echo "backend/ 下没有 *.jar，先构建" >&2; exit 1; }

# 前端产物拷入 nginx 目录
if [[ -d frontend/dist && -n "$(ls -A frontend/dist 2>/dev/null)" ]]; then
  cp -r frontend/dist/* frontend/nginx/html/
else
  [[ $SKIP_BUILD -eq 0 ]] && { echo "frontend/dist 为空，前端未构建成功" >&2; exit 1; }
fi

# ---------- 3. 远端准备 ----------
SSH() { ssh -o BatchMode=yes -o ConnectTimeout=10 root@"$SERVER" "$@"; }
echo ">>> 远端准备（建目录 + shared-infra 网络）..."
SSH "docker network inspect shared-infra >/dev/null 2>&1 || docker network create shared-infra
     mkdir -p /root/$PROJECT/{backend,frontend/nginx,uploads}"

# ---------- 4. 上传 ----------
echo ">>> 上传文件..."
scp -o BatchMode=yes "$JAR" docker-compose.yml dockerfile root@"$SERVER":/root/$PROJECT/
scp -r -o BatchMode=yes frontend/nginx/nginx.conf frontend/nginx/html root@"$SERVER":/root/$PROJECT/frontend/nginx/
[[ -n "$CONFIG" ]] && scp -o BatchMode=yes "$CONFIG" root@"$SERVER":/root/$PROJECT/backend/application-prod.yml && echo "    已上传外部配置 application-prod.yml"

# ---------- 5. 可选 Caddy 网关 ----------
GW=""
if [[ -n "$DOMAIN" ]]; then
  echo ">>> 配置 Caddy 网关（$DOMAIN → $PROJECT-web:5173）..."
  mkdir -p caddy
  cat > caddy/Caddyfile <<EOF
$DOMAIN {
	reverse_proxy $PROJECT-web:5173
}
EOF
  cat > docker-compose.gw.yml <<EOF
services:
  caddy:
    image: caddy:2-alpine
    container_name: caddy
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./caddy/Caddyfile:/etc/caddy/Caddyfile
      - ./caddy/data:/data
      - ./caddy/config:/config
    depends_on:
      - $PROJECT-web
    networks:
      - shared-infra

networks:
  shared-infra:
    name: shared-infra
    external: true
EOF
  scp -o BatchMode=yes caddy/Caddyfile docker-compose.gw.yml root@"$SERVER":/root/$PROJECT/
  GW="-f docker-compose.yml -f docker-compose.gw.yml"
fi

# ---------- 6. 远端启动 ----------
echo ">>> 远端 docker compose 构建并启动..."
SSH "cd /root/$PROJECT && docker compose $GW up -d --build"

# ---------- 7. 验证 ----------
sleep 3
echo ">>> 容器状态:"
SSH "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' | grep -E 'NAME|$PROJECT|caddy'"
echo ">>> 前端: http://$SERVER:$WEB_PORT"
[[ -n "$DOMAIN" ]] && echo ">>> 域名: https://$DOMAIN（等待证书签发）"
echo ">>> 后端日志: docker logs --tail 50 /root/$PROJECT 的 $PROJECT-api 容器"
