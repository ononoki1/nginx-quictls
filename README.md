# nginx-quictls

Similar to [nginx-http3](https://github.com/ononoki1/nginx-http3), except that it only provides a single binary `nginx` instead of Debian package.

## Distribution switch notice

According to [Debian Wiki](https://wiki.debian.org/DebianReleases), Debian bookworm has reached its end-of-life date in June 2026. Therefore, since version v9.0.0, the project will switch to Debian trixie as the packaging environment.

## Usage

First, install NGINX from [nginx-http3](https://github.com/ononoki1/nginx-http3), [Debian's official package](https://packages.debian.org/trixie/nginx) or [NGINX's official package](https://nginx.org/en/linux_packages.html#Debian). Then run following commands.

```bash
sudo systemctl stop nginx
sudo wget https://github.com/ononoki1/nginx-quictls/releases/latest/download/nginx -O /usr/sbin/nginx
sudo chmod +x /usr/sbin/nginx
sudo systemctl start nginx
```
