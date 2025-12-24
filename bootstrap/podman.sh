# 启动本地plantuml服务
podman run --rm -d -p 8199:8080 --name plantuml docker.io/plantuml/plantuml-server:jetty