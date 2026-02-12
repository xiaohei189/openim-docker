此目录挂载到 Promtail 的 /logs，用于采集 rust 日志。

方式一：把 rust.log* 复制到此目录，然后重启 Promtail。
方式二：在 .env 中设置 LOG_COLLECT_DIR 为你的 rust 日志目录（如 C:/Users/xxx/flutter_rust_demo/rust/logs），
       然后执行 docker compose --profile m up -d --force-recreate promtail。
