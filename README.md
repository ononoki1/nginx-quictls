# nginx-quictls

Similar to [nginx-http3](https://github.com/ononoki1/nginx-http3), except that it uses [quictls](https://github.com/quictls/openssl) instead of [BoringSSL](https://github.com/google/boringssl).

## Compare with [nginx-http3](https://github.com/ononoki1/nginx-http3)

- Some OpenSSL-only directives are supported, e.g. `ssl_conf_command`
- OCSP stapling can be enabled directly by using `ssl_stapling on; ssl_stapling_verify on;`
- Remove [ngx_headers_more](https://github.com/openresty/headers-more-nginx-module) module
