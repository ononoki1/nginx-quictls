set -e
cd /github/home
echo Install dependencies.
apt-get update > /dev/null 2>&1
apt-get install --allow-change-held-packages --allow-downgrades --allow-remove-essential \
-o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold -fy \
cmake git libmaxminddb-dev libpcre2-dev mercurial zlib1g-dev > /dev/null 2>&1
echo Fetch NGINX source code.
git clone --depth 1 --recursive https://github.com/nginx/nginx ngx > /dev/null 2>&1
echo Fetch quictls source code.
mkdir ngx/modules
cd ngx/modules
git clone --depth 1 --recursive https://github.com/quictls/quictls > /dev/null 2>&1
echo Fetch additional dependencies.
git clone --depth 1 --recursive https://github.com/google/ngx_brotli > /dev/null 2>&1
mkdir ngx_brotli/deps/brotli/out
cd ngx_brotli/deps/brotli/out
cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DCMAKE_INSTALL_PREFIX=installed .. \
> /dev/null 2>&1
cmake --build . --config Release --target brotlienc > /dev/null 2>&1
cd ../../../..
git clone --depth 1 --recursive https://github.com/leev/ngx_http_geoip2_module > /dev/null 2>&1
git clone --depth 1 --recursive https://github.com/openresty/headers-more-nginx-module > /dev/null 2>&1
echo Build nginx.
cd ..
auto/configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx \
--add-module=modules/ngx_brotli --add-module=modules/ngx_http_geoip2_module \
--add-module=modules/headers-more-nginx-module --conf-path=/etc/nginx/nginx.conf \
--error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log \
--pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock \
--http-client-body-temp-path=/var/cache/nginx/client_temp \
--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
--user=www-data --group=www-data --with-file-aio \
--with-threads --with-pcre-jit --with-http_ssl_module \
--with-http_v2_module --with-http_v3_module \
--without-select_module --without-poll_module \
--without-http_access_module --without-http_autoindex_module \
--without-http_browser_module --without-http_charset_module \
--without-http_empty_gif_module --without-http_limit_conn_module \
--without-http_memcached_module --without-http_mirror_module \
--without-http_referer_module --without-http_split_clients_module \
--without-http_scgi_module --without-http_ssi_module \
--without-http_upstream_hash_module --without-http_upstream_ip_hash_module \
--without-http_upstream_keepalive_module --without-http_upstream_least_conn_module \
--without-http_upstream_random_module --without-http_upstream_zone_module \
--with-openssl=modules/quictls > /dev/null 2>&1
make -j$(nproc) > /dev/null 2>&1
cp objs/nginx ..
cd ..
hash=$(ls -l nginx | awk '{print $5}')
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
