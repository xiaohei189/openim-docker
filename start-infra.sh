#!/bin/bash
# 启动 OpenIM 基础设施服务（Docker）
# 包括: MongoDB, Redis, Etcd, Kafka, MinIO
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

usage() {
    echo "用法: $0 [up|down|restart|status|logs]"
    echo "  up      - 启动基础设施"
    echo "  down    - 停止基础设施"
    echo "  restart - 重启（修改配置后用此命令）"
    echo "  status  - 查看状态"
    echo "  logs    - 查看日志"
    exit 1
}

case "${1:-up}" in
    up)
        echo "=== 启动基础设施 ==="
        docker compose up -d mongo redis etcd kafka minio
        echo ""
        echo "等待服务就绪..."
        sleep 5
        docker compose ps
        ;;
    down)
        echo "=== 停止基础设施 ==="
        docker compose down
        ;;
    restart)
        echo "=== 重新创建基础设施（应用新配置）==="
        docker compose up -d --force-recreate mongo redis etcd kafka minio
        sleep 5
        docker compose ps
        ;;
    status)
        docker compose ps
        ;;
    logs)
        docker compose logs -f --tail=100 mongo redis etcd kafka minio
        ;;
    *)
        usage
        ;;
esac
