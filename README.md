# sms-to-telegram

Docker image for receiving SMS messages and sending them to Telegram using Gammu and compatible modem. For more details check my [tutorial](https://alik.page/posts/forwarding-sms-to-telegram/)

## Usage

```yaml
services:
  gammu:
    image: ghcr.io/alikhil/sms-to-telegram
    volumes:
    - type: bind
      source: /dev/serial/by-id/usb-HUAWEI_HUAWEI_Mobile-if00-port0 # Change this to your device path
      target: /dev/modem
    privileged: true
    environment:
      - BOT_TOKEN=<put your telegram bot token here>
      - PIN=<your sim card pin>
      - CHAT_ID=<telegram chat/channel ID>
      - DEVICE=/dev/modem
    cap_add:
    - NET_ADMIN
    - SYS_MODULE
```