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

- **Nginx** (bản stable, build từ source để mọi hệ điều hành có cùng module): Brotli, headers-more, cache purge, VTS, FastCGI cache, Lua (LuaJIT).
- **PHP**: 8.5, 8.4, 8.3, 8.2, 8.1, 8.0, 7.4 — chạy song song hai phiên bản, đổi phiên bản qua menu.
- **MariaDB** 11.8 LTS, **phpMyAdmin** 5.2.
- WP-CLI, Composer, Rclone, acme.sh (Let's Encrypt), Fail2ban, Opcache Dashboard.
- Tuỳ chọn qua menu: Redis, Memcached, Node.js, ClamAV/ImunifyAV, ionCube.
- Tuỳ chọn lúc cài hoặc thêm sau qua menu: **CrowdSec**, **AppSec (WAF)**, thông báo **Telegram** — xem [mục 3.3](#33-crowdsec-appsec-và-telegram).

Phiên bản các phần mềm nằm trong file [`version`](version) — chỉ cần sửa file này để nâng cấp.

## 3. Cài đặt

### 3.1. VPS public (production)

```bash
curl -sO https://raw.githubusercontent.com/hao159/linux-lemp-stack/master/install && chmod +x install && ./install
```

### 3.2. Dev server nội bộ (truy cập bằng IP:PORT)

```bash
curl -sO https://raw.githubusercontent.com/hao159/linux-lemp-stack/master/install && chmod +x install && ./install --dev
```

Khác biệt của chế độ `--dev`:

- Dùng IP nội bộ của máy (không dò IP public), email là tuỳ chọn.
- Không đổi port SSH, không tinh chỉnh kernel (`sysctl`), không cài Fail2ban, không cài acme.sh, **không tự reboot**.
- Không tự bật firewall: nếu ufw/firewalld đang tắt thì giữ nguyên; nếu đang bật thì chỉ mở thêm các port cần thiết.
- PHP: `display_errors = On`, `opcache.revalidate_freq = 0` (sửa code thấy ngay).

Hoặc cài từ bản clone:

```bash
git clone https://github.com/hao159/linux-lemp-stack.git && cd linux-lemp-stack && bash install --dev
```

Log cài đặt: `/opt/install.txt`. Thông tin đăng nhập: `/var/hostvn/.hostvn.conf`.

### 3.3. CrowdSec, AppSec và Telegram

Trình cài đặt hỏi ba tuỳ chọn, trả lời `n` thì bỏ qua và bật sau trong menu `hostvn`:

| Tuỳ chọn | Tác dụng | Bật sau khi đã cài |
| --- | --- | --- |
| CrowdSec | Đọc log Nginx/SSH, tự chặn IP tấn công/scan ở tầng firewall (nftables) | Firewall → CrowdSec & AppSec → Cài đặt CrowdSec |
| AppSec (WAF) | Kiểm tra từng request trên Nginx, chặn request độc hại (403), IP vi phạm nhiều lần bị ban | Firewall → CrowdSec & AppSec → Bật/Tắt AppSec |
| Telegram | Báo đăng nhập SSH, dịch vụ ngừng chạy, đầy ổ cứng, IP bị CrowdSec chặn | Công cụ → Telegram notify |

Server cài bằng phiên bản cũ: chạy `hostvn` → **Cập nhật Scripts** để có các menu trên.

Lưu ý:

- Nginx được build kèm Lua (LuaJIT + lua-nginx-module). AppSec dùng bouncer Lua chính thức của CrowdSec nên kiểm tra được URI, header và cả body của request.
- Server cài từ bản 1.0.0 có Nginx chưa kèm Lua: khi bật AppSec, menu sẽ hỏi và build lại Nginx cùng phiên bản (mất vài phút, Nginx khởi động lại một lần).
- Cài CrowdSec sẽ bật access log của Nginx tại `/var/log/nginx/access/access.log` (CrowdSec cần log này để phát hiện scan). Log được rotate hằng ngày và nén; số ngày giữ log (7/14/30 hoặc tự nhập) chọn lúc cài, đổi lại ở Firewall → CrowdSec & AppSec → Thay đổi thời gian giữ access log. Gỡ CrowdSec thì access log tắt lại.
- Khi CrowdSec dừng hoặc khởi động lại, Nginx cho request đi qua (fail-open), website không bị gián đoạn.
- Port admin (phpMyAdmin, Opcache dashboard) không đi qua AppSec để tránh chặn nhầm câu lệnh SQL.
- IP đang SSH lúc cài CrowdSec được thêm vào danh sách tin cậy. Thêm IP khác: Firewall → CrowdSec & AppSec → IP tin cậy.
- Bot Token và Chat ID chỉ nhập một lần, lưu ở `/var/hostvn/telegram/telegram.conf` (quyền 600).
- Group Telegram có bật Topics: nhập thêm **Message Thread ID** để mọi thông báo vào đúng một topic (lấy từ link tin nhắn trong topic: `https://t.me/c/<group>/<thread id>/<tin nhắn>`). Bỏ trống nếu không dùng topic. Đổi lại ở Công cụ → Telegram notify → Cấu hình Telegram.

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
menu/helpers/os      Lớp trừu tượng hệ điều hành (apt/dnf, ufw/firewalld, PHP, MariaDB, build Nginx)
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
- **LEMP**: quản lý Nginx (update/rebuild), PHP (đổi phiên bản, PHP thứ hai, ionCube, thông số), MariaDB, log.
- **Firewall**: mở port, block/unblock IP (ufw hoặc firewalld + Fail2ban), CrowdSec & AppSec (WAF).
- **WordPress**: cài tự động, cập nhật, tối ưu database, bảo mật, cấu hình plugin cache/SEO.
- **Backup**: local, Google Drive, OneDrive (Rclone), cronjob tự động.
- **Công cụ**: Node.js, antivirus, nén ảnh, thông báo Telegram, cập nhật script.

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
