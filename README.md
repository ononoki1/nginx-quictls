# nginx-quictls

Similar to [nginx-http3](https://github.com/ononoki1/nginx-http3), except that it uses [quictls](https://github.com/quictls/openssl) instead of [BoringSSL](https://github.com/google/boringssl).

## Compare with nginx-http3

- Some OpenSSL-only directives are supported, e.g. `ssl_conf_command`
- OCSP stapling can be enabled directly by using `ssl_stapling on; ssl_stapling_verify on;`

## Usage

First, install NGINX from [nginx-http3](https://github.com/ononoki1/nginx-http3), [Debian's official package](https://packages.debian.org/bullseye/nginx) or [NGINX's official package](https://nginx.org/en/linux_packages.html#Debian). Then run following commands.

```bash
sudo systemctl stop nginx
sudo wget https://github.com/ononoki1/nginx-quictls/releases/latest/download/nginx -O /usr/sbin/nginx
sudo chmod +x /usr/sbin/nginx
sudo systemctl start nginx
```
