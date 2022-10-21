# nginx-quictls

Similar to [nginx-http3](https://github.com/ononoki1/nginx-http3), except that it uses [quictls](https://github.com/quictls/openssl) instead of [BoringSSL](https://github.com/google/boringssl).

## Compare with nginx-http3

- Some OpenSSL-only directives are supported, e.g. `ssl_conf_command`
- OCSP stapling can be enabled directly by using `ssl_stapling on; ssl_stapling_verify on;`
- Add [RTMP module](https://github.com/arut/nginx-rtmp-module)

## Usage

Run following commands.

```bash
systemctl stop nginx
wget https://github.com/ononoki1/nginx-quictls/releases/latest/download/nginx -O /usr/sbin/nginx
chmod +x /usr/sbin/nginx
systemctl start nginx
```
