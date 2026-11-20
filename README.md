<p align="center"><strong>Auto Install & Optimize LEMP Stack</strong></p>
<p align="center"><strong>Ubuntu · Debian · AlmaLinux · Rocky Linux · Oracle Linux · CentOS Stream · RHEL</strong></p>
<p align="center">Script gốc: <strong>Sanvv - HOSTVN.NET Technical</strong> (<a href="https://hostvn.vn/">hostvn.vn</a>). Bản này được tiếp tục bảo trì tại <a href="https://github.com/hao159/linux-lemp-stack">hao159/linux-lemp-stack</a>.</p>

---

Script viết bằng shell dùng để cài đặt và quản lý LEMP Stack (Nginx - MariaDB - PHP-FPM) qua menu `hostvn`.

<b>Vui lòng không sao chép, phát hành lại với mục đích thương mại. Xin cảm ơn.</b>

## 1. Hệ điều hành hỗ trợ

| Họ | Bản phân phối | Phiên bản | Nguồn PHP | Firewall |
|----|---------------|-----------|-----------|----------|
| Debian | Ubuntu | 22.04, 24.04, 26.04 | PPA Ondřej (hoặc packages.sury.org) | ufw |
| Debian | Debian | 11, 12, 13 | packages.sury.org | ufw |
| RHEL | AlmaLinux, Rocky Linux, Oracle Linux, CentOS Stream, RHEL | 8, 9, 10 | Remi | firewalld |

- Yêu cầu: máy **chưa cài** web server/database, tối thiểu 512MB RAM, có `systemd`, chạy bằng `root`.
- Trên họ RHEL, SELinux được chuyển sang `permissive` (PHP-FPM cần đọc `/home/<user>/<site>`).
- CentOS 7 và Ubuntu 18.04/20.04 đã hết vòng đời nên không còn được hỗ trợ.

## 2. Phần mềm được cài

Lúc cài chọn gói **Minimal** hoặc **Advanced**, sau đó bật/tắt từng thành phần tuỳ chọn — xem [mục 3.7](#37-gói-minimal--advanced-và-thành-phần-tuỳ-chọn). Không có gì ngoài phần lõi bị cài nếu bạn không chọn.

Phần lõi (luôn cài):

- **Nginx** (bản stable, build từ source để mọi hệ điều hành có cùng binary), FastCGI cache có sẵn trong Nginx.
- Hoặc **Apache** 2.4 (event MPM + PHP-FPM) thay cho Nginx, hoặc chạy phía sau Nginx — xem [mục 3.6](#36-chọn-web-server-nginx-hoặc-apache).
- **PHP-FPM**: 8.5, 8.4, 8.3, 8.2, 8.1, 8.0, 7.4 — có thể chạy song song hai phiên bản, đổi phiên bản qua menu. Opcache bật sẵn.
- **MariaDB** 11.8 LTS, acme.sh (SSL Let's Encrypt), WP-CLI.

Thành phần tuỳ chọn (chọn lúc cài hoặc thêm sau qua menu):

- Module Nginx: **Brotli**, **Headers-More**, **Lua** (LuaJIT, cần cho AppSec), **VTS**, **Cache Purge**.
- Công cụ: **phpMyAdmin** 5.2, **Opcache Dashboard**, **Composer**, **Rclone**, **Fail2ban**.
- Bảo mật: **CrowdSec**, **AppSec (WAF)**, thông báo **Telegram** — xem [mục 3.3](#33-crowdsec-appsec-và-telegram).
- Chỉ qua menu: Redis, Memcached, Node.js, ClamAV/ImunifyAV, ionCube.

Phiên bản các phần mềm nằm trong file [`version`](version) — chỉ cần sửa file này để nâng cấp.

## 3. Cài đặt

### 3.1. Chạy trình cài đặt

```bash
curl -sO https://raw.githubusercontent.com/hao159/linux-lemp-stack/master/install && chmod +x install && ./install
```

Hoặc cài từ bản clone:

```bash
git clone https://github.com/hao159/linux-lemp-stack.git && cd linux-lemp-stack && bash install
```

Không cần tham số dòng lệnh: trình cài đặt là một wizard hỏi lần lượt từng bước, mỗi bước có lựa chọn mặc định (nhấn Enter để chọn):

1. Chế độ cài đặt: **Production** (VPS public) hoặc **Dev server nội bộ** (IP:PORT) — xem [mục 3.2](#32-chế-độ-dev-server-nội-bộ-truy-cập-bằng-ipport).
2. Email quản trị.
3. Địa chỉ IP của server (tự dò, Enter để dùng).
4. Port SSH (chỉ ở chế độ Production).
5. Gói cài đặt: **Minimal** (VPS cấu hình thấp) hoặc **Advanced** — xem [mục 3.7](#37-gói-minimal--advanced-và-thành-phần-tuỳ-chọn).
6. Phiên bản PHP; gói Advanced hỏi thêm có cài phiên bản PHP thứ hai không.
7. Web server: Nginx hoặc Apache — xem [mục 3.6](#36-chọn-web-server-nginx-hoặc-apache).
8. Thành phần tuỳ chọn: danh sách có đánh dấu `[x]`, nhập số để bật/tắt từng mục (module Nginx, phpMyAdmin, Composer, Rclone, Fail2ban, CrowdSec, AppSec...).
9. Swap (chỉ hỏi khi VPS chưa có swap).
10. Thông báo Telegram.

Cuối cùng là màn hình tóm tắt để chọn **Bắt đầu cài đặt**, **Chọn lại từ đầu** hoặc **Huỷ**. Chưa có gì được cài lên server cho tới khi bạn xác nhận; sau đó quá trình cài chạy tự động, không hỏi thêm.

Nếu server không phải máy mới (đã cài script, đang chạy Nginx/Apache/MariaDB, hoặc `/var/lib/mysql` có dữ liệu), trình cài đặt liệt kê những gì phát hiện được và hỏi có tiếp tục không (mặc định là huỷ).

### 3.2. Chế độ Dev server nội bộ (truy cập bằng IP:PORT)

Chọn **Dev server nội bộ** ở bước 1 của wizard. Khác biệt so với Production:

- Dùng IP nội bộ của máy (không dò IP public), email là tuỳ chọn.
- Không đổi port SSH, không tinh chỉnh kernel (`sysctl`), không cài Fail2ban, không cài acme.sh, **không tự reboot**.
- Không tự bật firewall: nếu ufw/firewalld đang tắt thì giữ nguyên; nếu đang bật thì chỉ mở thêm các port cần thiết.
- PHP: `display_errors = On`, `opcache.revalidate_freq = 0` (sửa code thấy ngay).

Log cài đặt: `/opt/install.txt`. Thông tin đăng nhập: `/var/hostvn/.hostvn.conf`.

### 3.3. CrowdSec, AppSec và Telegram

CrowdSec và AppSec nằm trong danh sách thành phần tuỳ chọn của wizard (mặc định tắt ở cả hai gói), Telegram là một bước riêng. Bỏ qua thì bật sau trong menu `hostvn`:

| Tuỳ chọn | Tác dụng | Bật sau khi đã cài |
| --- | --- | --- |
| CrowdSec | Đọc log Nginx/SSH, tự chặn IP tấn công/scan ở tầng firewall (nftables) | Firewall → CrowdSec & AppSec → Cài đặt CrowdSec |
| AppSec (WAF) | Kiểm tra từng request trên Nginx, chặn request độc hại (403), IP vi phạm nhiều lần bị ban | Firewall → CrowdSec & AppSec → Bật/Tắt AppSec |
| Telegram | Báo đăng nhập SSH, dịch vụ ngừng chạy, đầy ổ cứng, IP bị CrowdSec chặn | Công cụ → Telegram notify |

Server cài bằng phiên bản cũ: chạy `hostvn` → **Cập nhật Scripts** để có các menu trên.

Lưu ý:

- AppSec cần module Lua của Nginx (LuaJIT + lua-nginx-module): chọn AppSec trong wizard thì CrowdSec và Lua được bật theo. AppSec dùng bouncer Lua chính thức của CrowdSec nên kiểm tra được URI, header và cả body của request.
- Nginx chưa có Lua (cài không chọn Lua, hoặc cài từ bản 1.0.0): khi bật AppSec, menu sẽ hỏi và build lại Nginx cùng phiên bản kèm Lua (mất vài phút, Nginx khởi động lại một lần).
- Server dùng Apache cài được CrowdSec (đọc log Apache), nhưng không có AppSec.
- Cài CrowdSec sẽ bật access log của Nginx tại `/var/log/nginx/access/access.log` (CrowdSec cần log này để phát hiện scan). Log được rotate hằng ngày và nén; số ngày giữ log (7/14/30 hoặc tự nhập) chọn lúc cài, đổi lại ở Firewall → CrowdSec & AppSec → Thay đổi thời gian giữ access log. Gỡ CrowdSec thì access log tắt lại.
- Khi CrowdSec dừng hoặc khởi động lại, Nginx cho request đi qua (fail-open), website không bị gián đoạn.
- Port admin (phpMyAdmin, Opcache dashboard) không đi qua AppSec để tránh chặn nhầm câu lệnh SQL.
- IP đang SSH lúc cài CrowdSec được thêm vào danh sách tin cậy. Thêm IP khác: Firewall → CrowdSec & AppSec → IP tin cậy.
- Bot Token và Chat ID chỉ nhập một lần, lưu ở `/var/hostvn/telegram/telegram.conf` (quyền 600).
- Group Telegram có bật Topics: nhập thêm **Message Thread ID** để mọi thông báo vào đúng một topic (lấy từ link tin nhắn trong topic: `https://t.me/c/<group>/<thread id>/<tin nhắn>`). Bỏ trống nếu không dùng topic. Đổi lại ở Công cụ → Telegram notify → Cấu hình Telegram.

### 3.4. Cập nhật và cảnh báo

`hostvn` → **14. Cập nhật & cảnh báo**:

| Mục | Cách cập nhật |
| --- | --- |
| Nginx | Build lại từ mã nguồn bản mới nhất cùng nhánh (ví dụ 1.30.x) lấy từ nginx.org. Website vẫn chạy trong lúc build, Nginx restart một lần. Build lỗi, cấu hình không hợp lệ hoặc không khởi động được thì tự khôi phục bản cũ (`/usr/sbin/nginx.hostvn.bak`). |
| PHP, MariaDB, CrowdSec | Nâng cấp gói bằng apt/dnf từ repo đã cấu hình lúc cài (Ondrej/Sury/Remi, MariaDB, CrowdSec), giữ nguyên file cấu hình đã sửa, restart dịch vụ và kiểm tra lại. |
| Hệ điều hành | Nâng cấp toàn bộ gói, báo khi cần reboot. |
| Scripts | Tải bản menu mới từ GitHub. |

Cảnh báo: mỗi ngày (05:23) server tự kiểm tra. Khi có bản mới của Nginx, PHP, MariaDB, CrowdSec, Redis/Memcached, OpenSSL/OpenSSH, bản vá bảo mật của hệ điều hành hoặc Scripts thì:

- Menu `hostvn` hiện danh sách ngay đầu màn hình.
- Gửi tin nhắn Telegram nếu đã cấu hình Telegram. Tin chỉ gửi lại khi danh sách thay đổi, hoặc sau 7 ngày chưa cập nhật.

Cảnh báo được bật sẵn khi cài mới. Server cài từ bản cũ: bật ở mục 8 của menu Cập nhật & cảnh báo.

Lưu ý:

- Cảnh báo dựa trên việc có phiên bản mới, không tra theo mã CVE. Các bản vá của nhánh stable (Nginx 1.30.x, PHP 8.x.y) chủ yếu là sửa lỗi và vá bảo mật nên có bản mới là nên cập nhật.
- Server không tự cập nhật, bạn chủ động chọn thời điểm trong menu.
- Chuyển sang nhánh Nginx mới (ví dụ 1.30 → 1.32) chỉ diễn ra sau khi file `version` của repo đổi `nginx_new_version`.

### 3.5. Cài extension PHP

`hostvn` → **4. LEMP** → **2. PHP** → **11. Cài đặt extension**: chọn phiên bản PHP (PHP 1, PHP 2 hoặc cả hai), rồi nhập số thứ tự các extension cần cài.

Danh sách có sẵn: mongodb, redis, memcached, pgsql, sqlite3, intl, imagick, gd, zip, bcmath, gmp, soap, xsl, mbstring, curl, iconv, exif, apcu, igbinary, msgpack, ldap, imap, tidy, yaml, ssh2, uuid, mailparse, amqp, swoole, xdebug. Extension khác: nhập tên của nó (ví dụ `rdkafka`).

- Extension cài bằng gói dựng sẵn của Ondrej/Sury (Debian, Ubuntu) hoặc Remi (họ RHEL), không biên dịch. Extension nào repo không có gói cho phiên bản PHP đó sẽ được báo rõ.
- PHP-FPM tự restart sau khi cài. Extension đi theo cập nhật của PHP ở mục 3.4.
- Đổi phiên bản PHP thì cần cài lại extension cho phiên bản mới.

### 3.6. Chọn web server: Nginx hoặc Apache

Chọn ở bước **Web server** của wizard cài đặt (mặc định Nginx).

| Chế độ | Khi nào dùng | Ghi chú |
| --- | --- | --- |
| **Nginx** (mặc định) | VPS yếu, cần hiệu năng cao nhất | Có FastCGI cache và AppSec (WAF) |
| **Apache** | Quen dùng Apache, mã nguồn dựa vào `.htaccess` / mod_rewrite | Apache nghe port 80/443, không cài Nginx |
| **Nginx phía trước + Apache phía sau** | Server Nginx có vài website cần `.htaccess` | Bật theo từng website sau khi cài: LEMP → Apache phía sau Nginx |

Apache ở cả hai chế độ đều chạy **event MPM + PHP-FPM**, không dùng mod_php, nên các pool PHP, phiên bản PHP và extension giống hệt bản Nginx. Số worker được tính theo RAM (2 process x 25 thread cho VPS ≤ 1GB, tối đa 8 process; chế độ phía sau Nginx dùng một nửa). Nâng cấp RAM xong thì chạy "Tính lại cấu hình Apache theo RAM" trong menu Apache.

**Apache làm web server** — những gì đã có:

- Thêm/xoá website (domain và IP:PORT), chọn mã nguồn, Rewrite config, đổi tên domain, clone website, Alias domain, Redirect domain, đổi phiên bản PHP.
- SSL Let's Encrypt (xác thực qua thư mục website hoặc CloudFlare DNS API) cho website và cho alias domain, SSL trả phí, tự chuyển HTTP → HTTPS.
- phpMyAdmin/Opcache dashboard trên port quản trị, đổi port quản trị, Fail2ban, cập nhật Apache bằng gói hệ điều hành, cảnh báo dịch vụ.
- CrowdSec: đọc access log và error log của Apache, chặn IP ở tầng firewall. Access log nằm tại `/var/log/apache2/access/access.log` (họ RHEL: `/var/log/httpd/access/access.log`).
- Bảo vệ thư mục bằng mật khẩu, mật khẩu cho wp-admin, chặn `xmlrpc.php` và User API của WordPress: menu ghi một khối có đánh dấu `# BEGIN hostvn ...` vào `.htaccess`, phần còn lại của file không bị đụng tới.
- Cài tự động WordPress (tạo sẵn `.htaccess`), chuyển dữ liệu sang VPS khác cũng dùng Apache.
- Plugin cache/SEO/WebP của WordPress tự ghi luật vào `.htaccess` nên không cần màn hình cấu hình như bản Nginx.

Không có ở chế độ Apache (menu sẽ báo rõ): AppSec (WAF) vì CrowdSec chỉ có bouncer AppSec cho Nginx, Nginx FastCGI cache, và import từ VPSSIM.

**Nginx phía trước + Apache phía sau**:

- Apache chỉ nghe trên `127.0.0.1` và chỉ được cài khi bạn bật cho website đầu tiên (tốn thêm khoảng 30-60 MB RAM).
- Nginx vẫn làm SSL, phục vụ file tĩnh, cache và CrowdSec; request PHP được chuyển sang Apache kèm URL gốc nên luật trong `.htaccess` có hiệu lực. File tĩnh có sẵn trên đĩa do Nginx trả trực tiếp, không đi qua `.htaccess`.
- Tắt cho một website là quay về Nginx + PHP-FPM như cũ. Không áp dụng cho website Node.js và website IP:PORT.

Thư mục `/etc/nginx/ssl` (chứng chỉ) và `/usr/share/nginx` (trang mặc định, công cụ quản trị), cùng tài khoản hệ thống `nginx`, vẫn được dùng ở chế độ Apache để menu dùng chung đường dẫn.

### 3.7. Gói Minimal / Advanced và thành phần tuỳ chọn

VPS cấu hình thấp không nên chạy những thứ không dùng tới. Wizard cho chọn gói, rồi hiện danh sách để bạn bật/tắt từng thành phần theo ý:

✔ = luôn cài · ☑ = chọn sẵn (bỏ được) · ☐ = tuỳ chọn, để trống (bật được ngay trong wizard)

| Thành phần | Minimal | Advanced | Thêm sau trong menu |
| --- | :---: | :---: | --- |
| Nginx (không module ngoài), PHP-FPM, MariaDB, SSL, Opcache, WP-CLI | ✔ | ✔ | — (luôn cài) |
| Giới hạn Opcache | 64 MB, 16k file (≤ 2GB RAM), tối đa 128 MB | theo RAM, 65k file | — |
| PHP thứ hai | — | hỏi | LEMP → PHP → Cài PHP 2 |
| Brotli, Headers-More, VTS, Cache Purge (module Nginx) | ☐ | ☑ | LEMP → Nginx → Module Nginx |
| Lua (module Nginx) | ☐ | ☐ | LEMP → Nginx → Module Nginx (hoặc tự build khi bật AppSec) |
| phpMyAdmin, Opcache Dashboard | ☐ | ☑ | Admin Tool → Cài đặt phpMyAdmin / Opcache Panel |
| Composer | ☐ | ☑ | Tự cài khi tạo website Laravel |
| Rclone | ☐ | ☑ | Tự hỏi cài khi kết nối Google Drive / OneDrive |
| Fail2ban | ☐ | ☑ | Firewall → Cài đặt Fail2ban |
| CrowdSec, AppSec (WAF) | ☐ | ☐ | Firewall → CrowdSec & AppSec |

- Gói mặc định: Minimal khi VPS dưới 4GB RAM, Advanced từ 4GB trở lên. Hai gói hiện cùng một danh sách, chỉ khác mục nào được chọn sẵn: ví dụ chọn Minimal rồi bật thêm phpMyAdmin và Fail2ban ở bước **Thành phần tuỳ chọn**.
- **Module Nginx**: chỉ module được chọn mới được tải và build, nên gói Minimal build nhanh hơn nhiều (không LuaJIT, không Brotli). Danh sách lưu ở `/var/hostvn/nginx_modules`; cập nhật hoặc rebuild Nginx giữ nguyên danh sách. Đổi module: LEMP → Nginx → **Module Nginx** — Nginx được build lại cùng phiên bản, lỗi thì tự khôi phục bản cũ.
- Không có Headers-More: header bảo mật dùng `add_header` của Nginx, header `Server` hiện là `nginx`. FastCGI cache cho WooCommerce cần Headers-More (để xoá `Set-Cookie` khỏi trang cache), menu sẽ báo nếu chưa có.
- Menu không cho bỏ module đang được dùng (Lua khi AppSec đang bật, Headers-More khi có website dùng cache WooCommerce).
- Server cài từ bản cũ không có `/var/hostvn/nginx_modules` nên được coi là có đủ module, không có gì thay đổi khi cập nhật.

## 4. Tạo website chạy bằng IP:PORT

`hostvn` → **1. Quản lý Domain** → **2. Thêm domain** → chọn **IP:PORT**.

1. Nhập port (1024-65535), ví dụ `8081`.
2. Nhập tên project, ví dụ `shop` (bỏ trống sẽ là `site8081`).
3. Chọn mã nguồn (WordPress, Laravel, ...) và database như bình thường.

Kết quả:

- Website truy cập tại `http://<IP-server>:8081`.
- Mã nguồn tại `/home/<user>/shop.test/public_html` (`shop.test` là định danh nội bộ của website trong menu).
- Port được mở trên firewall nếu firewall đang bật, và đóng lại khi xoá website.
- Cài tự động WordPress/Laravel sẽ dùng đúng URL `http://IP:PORT`.

Website IP:PORT dùng được các chức năng: xoá, đổi phiên bản PHP, rewrite vhost, cấu hình PHP, backup, các công cụ WordPress. Các chức năng cần tên miền (SSL, alias, redirect, đổi domain) sẽ từ chối website loại này. Chế độ IP:PORT cũng dùng được trên máy cài ở chế độ production.

## 5. Cấu trúc source

```
install              Kiểm tra hệ thống, tải source, gọi bộ cài
hostvn               Bộ cài LEMP Stack
version              Phiên bản các phần mềm + phiên bản script
menu/helpers/os      Lớp trừu tượng hệ điều hành (apt/dnf, ufw/firewalld, PHP, MariaDB, build Nginx + module)
menu/helpers/component  Thành phần tuỳ chọn (phpMyAdmin, Composer, Rclone, Fail2ban...) dùng chung cho bộ cài và menu
menu/                Menu quản lý (cài vào /var/hostvn/menu, lệnh: hostvn)
```

Trên họ RHEL, PHP của Remi được ánh xạ về cùng bố cục với Debian để toàn bộ menu dùng chung đường dẫn:

```
/etc/php/8.4/fpm            -> /etc/opt/remi/php84
/etc/php/8.4/fpm/conf.d     -> php.d
/etc/php/8.4/fpm/pool.d     -> php-fpm.d
php8.4-fpm.service          -> php84-php-fpm.service
/usr/bin/php8.4             -> /opt/remi/php84/root/usr/bin/php
```

Dùng fork riêng: đặt biến môi trường trước khi cài, và sửa `REPO_SLUG` trong `menu/helpers/os` để menu cập nhật từ repo của bạn.

```bash
REPO_SLUG=ten-ban/linux-lemp-stack REPO_BRANCH=master ./install
```

## 6. Tính năng menu

- **Domain**: thêm/xoá/đổi domain, alias, redirect, clone, đổi phiên bản PHP, bảo vệ thư mục, website IP:PORT.
- **SSL**: Let's Encrypt (kèm CloudFlare DNS API), SSL trả phí.
- **Cache**: Nginx FastCGI cache, Redis, Memcached, Opcache.
- **LEMP**: quản lý Nginx (update/rebuild, thêm/bỏ module), PHP (đổi phiên bản, PHP thứ hai, ionCube, thông số, cài extension), MariaDB, log.
- **Firewall**: mở port, block/unblock IP (ufw hoặc firewalld + Fail2ban), CrowdSec & AppSec (WAF).
- **WordPress**: cài tự động, cập nhật, tối ưu database, bảo mật, cấu hình plugin cache/SEO.
- **Backup**: local, Google Drive, OneDrive (Rclone), cronjob tự động.
- **Công cụ**: Node.js, antivirus, nén ảnh, thông báo Telegram.
- **Cập nhật & cảnh báo**: cập nhật Nginx, PHP, MariaDB, CrowdSec, hệ điều hành, script; cảnh báo khi có bản mới.

## 7. Thay đổi so với bản gốc

- Không còn phụ thuộc `scripts.hostvn.net`: source và file `version` lấy từ GitHub, phần mềm tải từ trang chủ của từng dự án.
- Bỏ ngx_pagespeed (dự án đã ngừng phát triển, không build được với toolchain hiện tại).
- Extension PHP Redis/Memcached/igbinary cài bằng gói dựng sẵn thay vì biên dịch.
- Fail2ban giữ `jail.conf` của bản phân phối, chỉ ghi phần ghi đè vào `jail.d/`.
- Không ghi đè `sources.list`, `resolv.conf`; cấu hình kernel ghi vào `/etc/sysctl.d/99-hostvn.conf`.

## 8. Nguồn download các phần mềm

- Nginx: https://nginx.org/en/download.html
- MariaDB: https://mariadb.org/download/
- PHP: https://www.php.net/ — https://deb.sury.org/ — https://rpms.remirepo.net/
- phpMyAdmin: https://www.phpmyadmin.net/
- Rclone: https://rclone.org/ · WP-CLI: https://wp-cli.org/ · Composer: https://getcomposer.org/

## 9. Credits

- Tác giả script gốc: **Sanvv** — HOSTVN.NET (https://hostvn.vn, https://hostvn.net)
- Bảo trì bản này: https://github.com/hao159/linux-lemp-stack
