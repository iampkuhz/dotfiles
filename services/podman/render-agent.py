#!/usr/bin/env python3
"""将路径写入 LaunchAgent 模板并输出到 stdout；不安装、不加载服务。"""
import plistlib
import sys
from pathlib import Path


def main():
    # 从脚本位置推导仓库，不依赖运行目录或硬编码用户名。
    service_dir = Path(__file__).resolve().parent
    with (service_dir / "agent.plist.template").open("rb") as source:
        agent = plistlib.load(source)
    agent["ProgramArguments"][1] = str(service_dir / "start.sh")
    # plistlib 负责 XML 转义；仓库路径带空格或 & 字符也能生成有效配置。
    logs = Path.home() / "Library" / "Logs"
    agent["StandardOutPath"] = str(logs / "dotfiles-podman-services.log")
    agent["StandardErrorPath"] = str(logs / "dotfiles-podman-services.err.log")
    plistlib.dump(agent, sys.stdout.buffer, sort_keys=False)


if __name__ == "__main__":
    main()
