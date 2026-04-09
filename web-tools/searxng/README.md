# SearXNG on Podman

## 目录结构

```
web-tools/searxng/
├── docker-compose.yml    # Compose 配置文件
├── searxng/
│   └── settings.yml      # SearXNG 主配置
└── README.md             # 本文件
```

## 配置信息

| 项目 | 值 |
|------|-----|
| **镜像地址** | `docker.io/searxng/searxng:latest` |
| **映射端口** | `8873:8080` (主机：容器) |
| **挂载目录** | `./searxng:/etc/searxng:rw` |
| **配置文件** | `web-tools/searxng/searxng/settings.yml` |
| **访问地址** | `http://localhost:8873` |

## 运行命令

### 启动服务
```bash
cd web-tools/searxng
podman compose up -d
```

### 停止服务
```bash
cd web-tools/searxng
podman compose down
```

### 查看日志
```bash
podman compose logs -f
```

### 重启服务
```bash
podman compose restart
```

### 升级镜像
```bash
podman pull docker.io/searxng/searxng:latest
podman compose up -d --force-recreate
```

### 查看容器状态
```bash
podman ps | grep searxng
```

## 验证可用性

```bash
curl http://localhost:8873/healthz
```

浏览器访问：http://localhost:8873

## 修改配置

1. 编辑 `web-tools/searxng/searxng/settings.yml`
2. 重启服务：`podman compose restart`

## Podman Rootless 注意事项

1. **端口绑定**：只能绑定 1024 以上端口（8873 已满足）
2. **挂载目录**：确保当前用户有读写权限
3. **防火墙**：如需外部访问：
   ```bash
   sudo firewall-cmd --add-port=8873/tcp --permanent
   sudo firewall-cmd --reload
   ```
