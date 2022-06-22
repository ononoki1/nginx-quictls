set -e
cd /github/home
echo Install dependencies.
apt-get update > /dev/null 2>&1
apt-get install --allow-change-held-packages --allow-downgrades --allow-remove-essential \
-o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold -fy \
cmake curl git libcurl4-openssl-dev libjemalloc-dev libmaxminddb-dev libmodsecurity-dev \
libpcre2-dev libsodium-dev mercurial > /dev/null 2>&1
echo Fetch nginx-quic source code.
hg clone -b quic https://hg.nginx.org/nginx-quic > /dev/null 2>&1
cd nginx-quic
echo Fetch quictls source code.
mkdir modules
cd modules
git clone https://github.com/quictls/openssl > /dev/null 2>&1
echo Build quictls.
cd openssl
mkdir build
./Configure --prefix=$(pwd)/build --openssldir=$(pwd)/build \
enable-ktls enable-ec_nistp_64_gcc_128 > /dev/null 2>&1
make install_dev -j$(nproc) > /dev/null 2>&1
echo Fetch additional dependencies.
cd ..
git clone -b current https://github.com/ADD-SP/ngx_waf > /dev/null 2>&1
cd ngx_waf
git clone https://github.com/DaveGamble/cJSON lib/cjson > /dev/null 2>&1
git clone https://github.com/troydhanson/uthash lib/uthash > /dev/null 2>&1
cd ..
git clone https://github.com/cloudflare/zlib > /dev/null 2>&1
cd zlib
make -f Makefile.in distclean > /dev/null 2>&1
cd ..
git clone --recursive https://github.com/google/ngx_brotli > /dev/null 2>&1
git clone https://github.com/openresty/headers-more-nginx-module > /dev/null 2>&1
git clone https://github.com/leev/ngx_http_geoip2_module > /dev/null 2>&1
echo Build nginx.
cd ..
auto/configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx \
--add-module=modules/ngx_waf \
--add-module=modules/headers-more-nginx-module \
--add-module=modules/ngx_http_geoip2_module \
--conf-path=/etc/nginx/nginx.conf \
--error-log-path=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/access.log \
--pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock \
--http-client-body-temp-path=/var/cache/nginx/client_temp \
--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
--user=nginx --group=nginx --with-file-aio --with-threads \
--with-http_ssl_module --with-http_v2_module --with-http_v3_module \
--without-http_access_module --without-http_autoindex_module \
--without-http_browser_module --without-http_charset_module \
--without-http_empty_gif_module --without-http_geo_module \
--without-http_limit_conn_module --without-http_limit_req_module \
--without-http_memcached_module --without-http_mirror_module \
--without-http_referer_module --without-http_split_clients_module \
--without-http_scgi_module --without-http_ssi_module \
--without-http_upstream_hash_module --without-http_upstream_ip_hash_module \
--without-http_upstream_keepalive_module \
--without-http_upstream_least_conn_module \
--without-http_upstream_random_module --without-http_upstream_zone_module \
--without-http_userid_module --without-http_uwsgi_module \
--with-zlib=modules/zlib \
--with-cc-opt="-static -Imodules/openssl/build/include -fstack-protector-strong -Wno-sign-compare" \
--with-ld-opt="-ljemalloc -Lmodules/openssl/build/lib64" > /dev/null 2>&1
make -j$(nproc)
mv objs/nginx ..
cd ..
hash=$(sha256sum nginx | awk '{print $1}')
patch=$(cat /github/workspace/patch)
minor=$(cat /github/workspace/minor)
if [[ $hash != $(cat /github/workspace/hash) ]]; then
  echo $hash > /github/workspace/hash
  if [[ $GITHUB_EVENT_NAME == push ]]; then
    patch=0
    minor=$(($(cat /github/workspace/minor)+1))
    echo $minor > /github/workspace/minor
  else
    patch=$(($(cat /github/workspace/patch)+1))
  fi
  echo $patch > /github/workspace/patch
  change=1
  echo This is a new version.
else
  echo This is an old version.
fi
echo -e "hash=$hash\npatch=$patch\nminor=$minor\nchange=$change" >> $GITHUB_ENV
