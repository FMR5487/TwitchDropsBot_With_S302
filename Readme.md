# TwitchDropsBot + Steamcommunity 302 Docker 镜像

带有 [Steamcommunity 302](https://www.dogfight360.com/blog/18682/) 的 [TwitchDropsBot](https://github.com/Alorf/TwitchDropsBot) 的Docker容器。  

## 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `START_DELAY` | `15` | 启动 Bot 前等待 302 代理就绪的秒数(留空为15秒) |

## 注意事项

- 请自行前往 [TwitchDropsBot](https://github.com/Alorf/TwitchDropsBot/releases) 源项目下载程序运行自行生成配置文件放入./config目录下,否则Bot无法正常运行
- 容器需要 `NET_ADMIN` 能力以修改网络配置（302 需要）
- `S302.ini` 已配置正确，如无需要请勿更改
- 若 Bot 无法正确访问[Twitch](Twitch.tv)，适当增大 `START_DELAY` 值，查看代理是否启动成功

## 文件结构

- project/
- ├── Dockerfile
- ├── docker-compose.yaml
- ├── config/ # 挂载目录，存放配置文件
- │ ├── config.json # TwitchDropsBot 配置（需自行生成）
- │ ├── S302.ini # 302 主配置（无需修改）
- │ └── S302_rules.ini # 302 分流规则（供302程序更新规则的持久化存储）
- ├── TwitchDropsBot/（Console-Linux）
- └── S302/（Linux-cil）

## 项目引用

- [TwitchDropsBot by Alorf](https://github.com/Alorf/TwitchDropsBot)
- [Steamcommunity 302 by Dogfight360](https://www.dogfight360.com/blog/18682/)

## docker-compose.yaml

```yaml
services:
  twitchdropsbots302:
    container_name: TwitchDropsBotS302
    image: ghcr.io/fmr5487/TwitchDropsBot_With_S302:latest
    network_mode: "bridge"
    ports:
      - "8082:80"
      - "4434:443"
    volumes:
      - ./config/config.json:/init/Configuration/config.json
      - ./config/S302_rules.ini:/S302/S302_rules.ini
      - ./config/S302.ini:/S302/S302.ini
    environment:
      - ADD_ACCOUNT=false
      - INSIDE_DOCKER=true
      - START_DELAY=15
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
    extra_hosts:
      "twitch.tv": "127.0.0.1"
      "www.twitch.tv": "127.0.0.1"
      "m.twitch.tv": "127.0.0.1"
      "app.twitch.tv": "127.0.0.1"
      "auth.twitch.tv": "127.0.0.1"
      "music.twitch.tv": "127.0.0.1"
      "blog.twitch.tv": "127.0.0.1"
      "inspector.twitch.tv": "127.0.0.1"
      "dev.twitch.tv": "127.0.0.1"
      "clips.twitch.tv": "127.0.0.1"
      "spade.twitch.tv": "127.0.0.1"
      "gql.twitch.tv": "127.0.0.1"
      "vod-secure.twitch.tv": "127.0.0.1"
      "vod-storyboards.twitch.tv": "127.0.0.1"
      "trowel.twitch.tv": "127.0.0.1"
      "extension-files.twitch.tv": "127.0.0.1"
      "vod-metro.twitch.tv": "127.0.0.1"
      "player.m7g.twitch.tv": "127.0.0.1"
      "help.twitch.tv": "127.0.0.1"
      "passport.twitch.tv": "127.0.0.1"
      "id.twitch.tv": "127.0.0.1"
      "id-cdn.twitch.tv": "127.0.0.1"
      "player.twitch.tv": "127.0.0.1"
      "api.twitch.tv": "127.0.0.1"
      "panels.twitch.tv": "127.0.0.1"
      "extensions-discovery-images.twitch.tv": "127.0.0.1"
      "cvp.twitch.tv": "127.0.0.1"
      "pubsub-edge.twitch.tv": "127.0.0.1"
      "ingest.twitch.tv": "127.0.0.1"
      "assets.help.twitch.tv": "127.0.0.1"
      "assets.twitch.tv": "127.0.0.1"
      "discuss.dev.twitch.tv": "127.0.0.1"
      "irc-ws.chat.twitch.tv": "127.0.0.1"
      "irc-ws-r.chat.twitch.tv": "127.0.0.1"
      "dashboard.twitch.tv": "127.0.0.1"
      "appeals.twitch.tv": "127.0.0.1"
      "safety.twitch.tv": "127.0.0.1"
      "brand.twitch.tv": "127.0.0.1"
      "usher.ttvnw.net": "127.0.0.1"
      "production.assets.clips.twitchcdn.net": "127.0.0.1"
      "static-cdn.jtvnw.net": "127.0.0.1"
      "*.pdx01.abs.hls.ttvnw.net": "127.0.0.1"
      "beacon.twitch.tv": "127.0.0.1"
```
