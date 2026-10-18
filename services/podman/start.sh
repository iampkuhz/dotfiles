#!/usr/bin/env bash
# 手工或由用户 LaunchAgent 启动已有服务；不建 machine、不拉镜像、不克隆源码。
set -euo pipefail

MACHINE="${PODMAN_MACHINE:-podman-machine-default}"
# LaunchAgent 不加载交互 shell；兼容两种 Homebrew 的标准安装路径。
if command -v podman >/dev/null 2>&1; then
  PODMAN_BIN="$(command -v podman)"
elif [[ -x /opt/homebrew/bin/podman ]]; then
  PODMAN_BIN=/opt/homebrew/bin/podman
elif [[ -x /usr/local/bin/podman ]]; then
  PODMAN_BIN=/usr/local/bin/podman
else
  echo "未找到 podman，请先完成 Homebrew 依赖安装。" >&2
  exit 1
fi

# 先确认 machine 已由用户准备；只启动停止的 machine，其他状态不自动处理。
machine_state="$("$PODMAN_BIN" machine inspect "$MACHINE" --format '{{.State}}')"
case "$machine_state" in
running) ;;
stopped) "$PODMAN_BIN" machine start "$MACHINE" ;;
*)
  echo "machine 状态无法自动处理：$machine_state" >&2
  exit 1
  ;;
esac

# 与现有本机服务一致，数据库排在代理前；名称固定，不执行用户字符串或任意命令。
containers=(litellm-db-podman litellm-proxy-podman searxng crawl4ai)
for container_name in "${containers[@]}"; do
  if ! "$PODMAN_BIN" container exists "$container_name"; then
    echo "缺少容器 ${container_name}；请先按服务所属项目的 Compose 重建。" >&2
    exit 1
  fi
done
for container_name in "${containers[@]}"; do
  # 已运行容器直接跳过；启动失败保留错误，不静默吞掉失败。
  if [[ "$("$PODMAN_BIN" container inspect "$container_name" --format '{{.State.Running}}')" != true ]]; then
    "$PODMAN_BIN" start "$container_name"
  fi
done
