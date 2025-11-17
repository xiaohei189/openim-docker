# 使用本地源码调试 OpenIM

## 修改内容

已将 `docker-compose.yaml` 修改为使用本地源码：

### 修改项
- ✅ `openim-server`: 改为挂载本地 `C:/Users/11456/workspace/open-im-server`
- ✅ `openim-chat`: 改为挂载本地 `C:/Users/11456/workspace/chat`
- ✅ 添加调试端口：40000 (server), 40001 (chat)
- ✅ 移除 healthcheck 避免干扰调试
- ✅ 使用 golang:1.22 基础镜像

## 启动服务

### 方式一：使用 Docker Compose

```bash
cd C:/Users/11456/workspace/openim-docker

# 启动基础设施 + 本地源码服务
docker-compose up -d

# 查看日志
docker-compose logs -f openim-server
docker-compose logs -f openim-chat

# 停止服务
docker-compose down
```

### 方式二：直接在本地运行（推荐调试）

```bash
# 启动基础设施（不启动 openim-server 和 openim-chat）
cd C:/Users/11456/workspace/openim-docker
docker-compose up -d mongo redis etcd kafka minio

# 在 VSCode 中直接调试
# 1. 打开 open-im-server 项目
# 2. 按 F5 或点击 "调试 msggateway"
```

## VSCode 调试配置

已创建调试配置文件：

### open-im-server/.vscode/launch.json

提供以下调试选项：
- **调试 msggateway** - 调试消息网关（WebSocket 服务）
- **调试 api** - 调试 API 服务
- **调试 RPC 服务** - 调试 RPC 消息服务
- **附加到容器** - 附加到运行中的容器进行远程调试

### chat/.vscode/launch.json

提供以下调试选项：
- **调试 chat-api** - 调试聊天 API
- **调试 admin-api** - 调试管理 API
- **附加到容器** - 远程调试

## 调试步骤

### 1. 启动基础设施

```bash
cd C:/Users/11456/workspace/openim-docker
docker-compose up -d mongo redis etcd kafka minio
```

等待所有服务启动完成。

### 2. 在 VSCode 中调试

#### 调试 openim-server

1. 打开 `C:/Users/11456/workspace/open-im-server` 项目
2. 在 `internal/msggateway/ws_server.go` 设置断点
3. 按 `F5` 选择 "调试 msggateway"
4. 服务启动后可以在 `localhost:10001` 访问

#### 调试 openim-chat

1. 打开 `C:/Users/11456/workspace/chat` 项目
2. 在需要的地方设置断点
3. 按 `F5` 选择 "调试 chat-api"
4. 服务启动后可以在 `localhost:10008` 访问

### 3. 调试 Rust 客户端发送消息

1. 在 msggateway 的 `ws_server.go:452 wsHandler` 设置断点
2. 在 `client.go:190 handleMessage` 设置断点
3. 运行 Rust 客户端发送消息
4. 查看服务器端收到的数据和验证逻辑

## 端口映射

| 服务 | 容器端口 | 主机端口 | 调试端口 |
|------|---------|---------|---------|
| openim-server (msggateway) | 10001 | 10001 | 40000 |
| openim-server (api) | 10002 | 10002 | - |
| openim-chat (chat-api) | 10008 | 10008 | 40001 |
| openim-chat (admin-api) | 10009 | 10009 | - |
| MongoDB | 27017 | 27017 | - |
| Redis | 6379 | 16379 | - |
| Etcd | 2379 | 12379 | - |
| Kafka | 9094 | 19094 | - |
| Minio | 9000 | 10005 | - |

## 调试 Rust 客户端发送消息问题

### 步骤

1. **启动服务器调试**
   ```bash
   # 在 open-im-server 项目中按 F5
   # 选择 "调试 msggateway"
   ```

2. **设置断点**
   - `internal/msggateway/ws_server.go:452` - wsHandler
   - `internal/msggateway/client.go:190` - handleMessage
   - `internal/msggateway/message_handler.go:151` - SendMessage

3. **运行 Rust 客户端**
   ```bash
   cd C:/Users/11456/workspace/flutter_rust_demo
   # 取消 simple.rs 中发送消息的注释
   cargo test run_openim_client -- --nocapture --ignored
   ```

4. **观察服务器端**
   - 查看收到的 MsgData 内容
   - 检查验证逻辑
   - 查看错误信息

## 恢复镜像模式

如果需要恢复使用镜像：

```yaml
# 取消注释这两行
image: ${OPENIM_SERVER_IMAGE}
image: ${OPENIM_CHAT_IMAGE}

# 注释掉
# image: golang:1.22
# volumes: ...
```

## 常见问题

### Q: 容器无法访问本地文件？
A: Windows 下确保 Docker Desktop 已共享 C: 盘

### Q: 编译失败？
A: 检查 go.mod 和依赖是否完整，运行 `go mod tidy`

### Q: 服务启动失败？
A: 检查环境变量和基础设施是否都已启动

---

**提示**：修改源码后，重启容器会自动重新编译。

