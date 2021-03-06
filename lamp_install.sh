#!/bin/bash
# Author:  yeho
#          <lj2007331 AT gmail.com>.
# Blog:  http://blog.linuxeye.com
#
# Version:  0.1 21-Aug-2013 lj2007331 AT gmail.com
# Notes: LAMP for CentOS/RadHat 5/6 
#
# This script's project home is:
#       https://github.com/lj2007331/lamp
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

echo "#######################################################################"
echo "#                    LAMP for CentOS/RadHat 5/6                       #"
echo "# For more information Please visit http://blog.linuxeye.com/82.html  #"
echo "#######################################################################"

# Check if user is root
[ $(id -u) != "0" ] && echo "Error: You must be root to run this script, Please use root to install lamp" && kill -9 $$

# get ipv4 
IP=`ifconfig | grep 'inet addr:' | cut -d: -f2 | grep -v ^10\. | grep -v ^192\.168 | grep -v ^172\. | grep -v ^127\. | awk '{print  $1}' | awk '{print;exit}'`
[ ! -n "$IP" ] && IP=`ifconfig | grep 'inet addr:' | cut -d: -f2 | grep -v ^127\. | awk '{print  $1}' | awk '{print;exit}'`

#Definition Directory
home_dir=/home/wwwroot
wwwlogs_dir=/home/wwwlogs
mkdir -p $home_dir/default $wwwlogs_dir /root/lamp/{source,conf}

#choice database
while :
do
        read -p "Do you want to install MySQL or MariaDB ? ( MySQL / MariaDB ) " choice_DB
        choice_db=`echo $choice_DB | tr [A-Z] [a-z]`
        if [ "$choice_db" != 'mariadb' ] && [ "$choice_db" != 'mysql' ];then
                echo -e "\033[31minput error! Please input 'MySQL' or 'MariaDB'\033[0m"
        else
                break
        fi
done

#eheck dbrootpwd
while :
do
        read -p "Please input the root password of database:" dbrootpwd
        (( ${#dbrootpwd} >= 5 )) && break || echo -e "\033[31m$choice_DB root password least 5 characters! \033[0m"
done

while :
do
        read -p "Do you want to install Memcache? (y/n)" Memcache_yn
        if [ "$Memcache_yn" != 'y' ] && [ "$Memcache_yn" != 'n' ];then
                echo -e "\033[31minput error! Please input 'y' or 'n'\033[0m"
        else
                break
        fi
done

while :
do
        read -p "Do you want to install Pure-FTPd? (y/n)" FTP_yn
        if [ "$FTP_yn" != 'y' ] && [ "$FTP_yn" != 'n' ];then
                echo -e "\033[31minput error! Please input 'y' or 'n'\033[0m"
        else
                break
        fi
done

if [ $FTP_yn == 'y' ];then
        while :
        do
                read -p "Please input the manager password of Pureftpd:" ftpmanagerpwd
                (( ${#ftpmanagerpwd} >= 5 )) && break || echo -e "\033[31mFtp manager password least 5 characters! \033[0m"
        done
fi

while :
do
        read -p "Do you want to install phpMyAdmin? (y/n)" phpMyAdmin_yn
        if [ "$phpMyAdmin_yn" != 'y' ] && [ "$phpMyAdmin_yn" != 'n' ];then
                echo -e "\033[31minput error! Please input 'y' or 'n'\033[0m"
        else
                break
        fi
done

function Download_src()
{
cd /root/lamp
[ -s init.sh ] && echo 'init.sh found' || wget -c --no-check-certificate https://raw.github.com/lj2007331/lamp/master/init.sh
[ -s vhost.sh ] && echo 'vhost.sh found' || wget -c --no-check-certificate https://raw.github.com/lj2007331/lamp/master/vhost.sh
cd conf
[ -s index.html ] && echo 'index.html found' || wget -c --no-check-certificate https://raw.github.com/lj2007331/lamp/master/conf/index.html
[ -s pure-ftpd.conf ] && echo 'pure-ftpd.conf found' || wget -c --no-check-certificate https://raw.github.com/lj2007331/lamp/master/conf/pure-ftpd.conf
[ -s pureftpd-mysql.conf ] && echo 'pureftpd-mysql.conf found' || wget -c --no-check-certificate https://raw.github.com/lj2007331/lamp/master/conf/pureftpd-mysql.conf
[ -s chinese.php ] && echo 'chinese.php found' || wget -c --no-check-certificate https://raw.github.com/lj2007331/lamp/master/conf/chinese.php 
[ -s script.mysql ] && echo 'script.mysql found' || wget -c --no-check-certificate https://raw.github.com/lj2007331/lamp/master/conf/script.mysql
cd /root/lamp/source
[ -s tz.zip ] && echo 'tz.zip found' || wget -c http://www.yahei.net/tz/tz.zip
[ -s cmake-2.8.12.tar.gz ] && echo 'cmake-2.8.12.tar.gz found' || wget -c http://www.cmake.org/files/v2.8/cmake-2.8.12.tar.gz 
[ -s mysql-5.6.14.tar.gz ] && echo 'mysql-5.6.14.tar.gz found' || wget -c http://cdn.mysql.com/Downloads/MySQL-5.6/mysql-5.6.14.tar.gz 
[ -s mariadb-5.5.33a.tar.gz ] && echo 'mariadb-5.5.33a.tar.gz found' || wget -c http://ftp.osuosl.org/pub/mariadb/mariadb-5.5.33a/kvm-tarbake-jaunty-x86/mariadb-5.5.33a.tar.gz 
[ -s libiconv-1.14.tar.gz ] && echo 'libiconv-1.14.tar.gz found' || wget -c http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz
[ -s mcrypt-2.6.8.tar.gz ] && echo 'mcrypt-2.6.8.tar.gz found' || wget -c http://downloads.sourceforge.net/project/mcrypt/MCrypt/2.6.8/mcrypt-2.6.8.tar.gz
[ -s libmcrypt-2.5.8.tar.gz ] && echo 'libmcrypt-2.5.8.tar.gz found' || wget -c http://downloads.sourceforge.net/project/mcrypt/Libmcrypt/2.5.8/libmcrypt-2.5.8.tar.gz
[ -s mhash-0.9.9.9.tar.gz ] && echo 'mhash-0.9.9.9.tar.gz found' || wget -c http://downloads.sourceforge.net/project/mhash/mhash/0.9.9.9/mhash-0.9.9.9.tar.gz
[ -s php-5.5.5.tar.gz ] && echo 'php-5.5.5.tar.gz found' || wget -c http://kr1.php.net/distributions/php-5.5.5.tar.gz
[ -s memcached-1.4.15.tar.gz ] && echo 'memcached-1.4.15.tar.gz found' || wget -c --no-check-certificate https://memcached.googlecode.com/files/memcached-1.4.15.tar.gz
[ -s memcache-2.2.7.tgz ] && echo 'memcache-2.2.7.tgz found' || wget -c http://pecl.php.net/get/memcache-2.2.7.tgz
[ -s ImageMagick-6.8.7-5.tar.gz ] && echo 'ImageMagick-6.8.7-5.tar.gz found' || wget -c http://blog.linuxeye.com/lnmp/src/ImageMagick-6.8.7-5.tar.gz 
[ -s imagick-3.1.2.tgz ] && echo 'imagick-3.1.2.tgz found' || wget -c http://pecl.php.net/get/imagick-3.1.2.tgz 
[ -s pecl_http-1.7.6.tgz ] && echo 'pecl_http-1.7.6.tgz found' || wget -c http://pecl.php.net/get/pecl_http-1.7.6.tgz
[ -s pcre-8.33.tar.gz ] && echo 'pcre-8.33.tar.gz found' || wget -c http://ftp.cs.stanford.edu/pub/exim/pcre/pcre-8.33.tar.gz 
[ -s apr-1.4.8.tar.gz ] && echo 'apr-1.4.8.tar.gz found' || wget -c http://archive.apache.org/dist/apr/apr-1.4.8.tar.gz 
[ -s apr-util-1.5.2.tar.gz ] && echo 'apr-util-1.5.2.tar.gz found' || wget -c http://archive.apache.org/dist/apr/apr-util-1.5.2.tar.gz 
[ -s httpd-2.4.6.tar.gz ] && echo 'httpd-2.4.6.tar.gz found' || wget -c http://www.apache.org/dist/httpd/httpd-2.4.6.tar.gz 
[ -s pure-ftpd-1.0.36.tar.gz ] && echo 'pure-ftpd-1.0.36.tar.gz found' || wget -c http://download.pureftpd.org/pub/pure-ftpd/releases/pure-ftpd-1.0.36.tar.gz 
[ -s ftp_v2.1.tar.gz ] && echo 'ftp_v2.1.tar.gz found' || wget -c http://machiel.generaal.net/files/pureftpd/ftp_v2.1.tar.gz 
[ -s phpMyAdmin-4.0.8-all-languages.tar.gz ] && echo 'phpMyAdmin-4.0.8-all-languages.tar.gz found' || wget -c http://downloads.sourceforge.net/project/phpmyadmin/phpMyAdmin/4.0.8/phpMyAdmin-4.0.8-all-languages.tar.gz 

# check source packages
for src in `cat /root/lamp/lamp_install.sh | grep found.*wget | awk '{print $3}' | grep gz`
do
        if [ ! -e "/root/lamp/source/$src" ];then
		echo -e "\033[31m$src no found! \033[0m"
                echo -e "\033[31mUpdated version of the Package source, Please Contact the author! \033[0m"
                kill -9 $$
        fi
done
}

function Install_MySQL()
{
cd /root/lamp/source
useradd -M -s /sbin/nologin mysql
mkdir -p $db_data_dir;chown mysql.mysql -R $db_data_dir
tar xzf cmake-2.8.12.tar.gz
cd cmake-2.8.12
./configure
make &&  make install
cd ..
tar zxf mysql-5.6.14.tar.gz
cd mysql-5.6.14
cmake . -DCMAKE_INSTALL_PREFIX=$db_install_dir \
-DMYSQL_UNIX_ADDR=/tmp/mysql.sock \
-DMYSQL_DATADIR=$db_data_dir \
-DSYSCONFDIR=/etc \
-DMYSQL_USER=mysql \
-DMYSQL_TCP_PORT=3306 \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DWITH_READLINE=1 \
-DENABLED_LOCAL_INFILE=1 \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DEXTRA_CHARSETS=all \
-DWITH_BIG_TABLES=1 \
-DWITH_DEBUG=0
make && make install

if [ -d "$db_install_dir" ];then
        echo -e "\033[32mMySQL install successfully! \033[0m"
else
        echo -e "\033[31mMySQL install failed, Please Contact the author! \033[0m"
        kill -9 $$
fi

/bin/cp support-files/mysql.server /etc/init.d/mysqld
chmod +x /etc/init.d/mysqld
chkconfig --add mysqld
chkconfig mysqld on
cd ..

# my.cf
cat > /etc/my.cnf << EOF
[mysqld]
basedir = $db_install_dir
datadir = $db_data_dir
pid-file = $db_data_dir/mysql.pid
character-set-server = utf8
collation-server = utf8_general_ci
user = mysql
port = 3306
default_storage_engine = InnoDB
innodb_file_per_table = 1
server_id = 1
log_bin = mysql-bin
binlog_format = mixed
expire_logs_days = 7
bind-address = 0.0.0.0

# name-resolve
skip-name-resolve
skip-host-cache

#lower_case_table_names = 1
ft_min_word_len = 1
query_cache_size = 64M
query_cache_type = 1

skip-external-locking
key_buffer_size = 16M
max_allowed_packet = 1M
table_open_cache = 64
sort_buffer_size = 512K
net_buffer_length = 8K
read_buffer_size = 256K
read_rnd_buffer_size = 512K
myisam_sort_buffer_size = 8M

# LOG
log_error = $db_data_dir/mysql-error.log
long_query_time = 1
slow_query_log
slow_query_log_file = $db_data_dir/mysql-slow.log

# Oher
#max_connections = 1000
open_files_limit = 65535

[client]
port = 3306
EOF

$db_install_dir/scripts/mysql_install_db --user=mysql --basedir=$db_install_dir --datadir=$db_data_dir

chown mysql.mysql -R $db_data_dir
/sbin/service mysqld start
export PATH=$PATH:$db_install_dir/bin
echo "export PATH=\$PATH:$db_install_dir/bin" >> /etc/profile
source /etc/profile

$db_install_dir/bin/mysql -e "grant all privileges on *.* to root@'127.0.0.1' identified by \"$dbrootpwd\" with grant option;"
$db_install_dir/bin/mysql -e "grant all privileges on *.* to root@'localhost' identified by \"$dbrootpwd\" with grant option;"
$db_install_dir/bin/mysql -uroot -p$dbrootpwd -e "delete from mysql.user where Password='';"
$db_install_dir/bin/mysql -uroot -p$dbrootpwd -e "delete from mysql.db where User='';"
$db_install_dir/bin/mysql -uroot -p$dbrootpwd -e "drop database test;"
$db_install_dir/bin/mysql -uroot -p$dbrootpwd -e "reset master;"
/sbin/service mysqld restart
}

function Install_MariaDB()
{
cd /root/lamp/source
useradd -M -s /sbin/nologin mysql
mkdir -p $db_data_dir;chown mysql.mysql -R $db_data_dir
tar xzf cmake-2.8.12.tar.gz
cd cmake-2.8.12
./configure
make &&  make install
cd ..
tar zxf mariadb-5.5.33a.tar.gz
cd mariadb-5.5.33a
cmake . -DCMAKE_INSTALL_PREFIX=$db_install_dir \
-DMYSQL_UNIX_ADDR=/tmp/mysql.sock \
-DMYSQL_DATADIR=$db_data_dir \
-DSYSCONFDIR=/etc \
-DMYSQL_USER=mysql \
-DMYSQL_TCP_PORT=3306 \
-DWITH_ARIA_STORAGE_ENGINE=1 \
-DWITH_XTRADB_STORAGE_ENGINE=1 \
-DWITH_ARCHIVE_STORAGE_ENGINE=1 \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DWITH_READLINE=1 \
-DENABLED_LOCAL_INFILE=1 \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DEXTRA_CHARSETS=all \
-DWITH_BIG_TABLES=1 \
-DWITH_DEBUG=0
make && make install

if [ -d "$db_install_dir" ];then
        echo -e "\033[32mMariaDB install successfully! \033[0m"
else
        echo -e "\033[31mMariaDB install failed, Please Contact the author! \033[0m"
        kill -9 $$
fi

/bin/cp support-files/my-small.cnf /etc/my.cnf
/bin/cp support-files/mysql.server /etc/init.d/mysqld
chmod +x /etc/init.d/mysqld
chkconfig --add mysqld
chkconfig mysqld on
cd ..

# my.cf
cat > /etc/my.cnf << EOF
[mysqld]
basedir = $db_install_dir
datadir = $db_data_dir
pid-file = $db_data_dir/mariadb.pid
character-set-server = utf8
collation-server = utf8_general_ci
user = mysql
port = 3306
default_storage_engine = InnoDB
innodb_file_per_table = 1
server_id = 1
log_bin = mysql-bin
binlog_format = mixed
expire_logs_days = 7
bind-address = 0.0.0.0

# name-resolve
skip-name-resolve
skip-host-cache

#lower_case_table_names = 1
ft_min_word_len = 1
query_cache_size = 64M
query_cache_type = 1

skip-external-locking
key_buffer_size = 16M
max_allowed_packet = 1M
table_open_cache = 64
sort_buffer_size = 512K
net_buffer_length = 8K
read_buffer_size = 256K
read_rnd_buffer_size = 512K
myisam_sort_buffer_size = 8M

# LOG
log_error = $db_data_dir/mariadb-error.log
long_query_time = 1
slow_query_log
slow_query_log_file = $db_data_dir/mariadb-slow.log

# Oher
#max_connections = 1000
open_files_limit = 65535

[client]
port = 3306
EOF

$db_install_dir/scripts/mysql_install_db --user=mysql --basedir=$db_install_dir --datadir=$db_data_dir

chown mysql.mysql -R $db_data_dir
/sbin/service mysqld start
export PATH=$PATH:$db_install_dir/bin
echo "export PATH=\$PATH:$db_install_dir/bin" >> /etc/profile
source /etc/profile

$db_install_dir/bin/mysql -e "grant all privileges on *.* to root@'127.0.0.1' identified by \"$dbrootpwd\" with grant option;"
$db_install_dir/bin/mysql -e "grant all privileges on *.* to root@'localhost' identified by \"$dbrootpwd\" with grant option;"
$db_install_dir/bin/mysql -uroot -p$dbrootpwd -e "delete from mysql.user where Password='';"
$db_install_dir/bin/mysql -uroot -p$dbrootpwd -e "delete from mysql.db where User='';"
$db_install_dir/bin/mysql -uroot -p$dbrootpwd -e "drop database test;"
$db_install_dir/bin/mysql -uroot -p$dbrootpwd -e "reset master;"
/sbin/service mysqld restart
}

function Install_Apache()
{
useradd -M -s /sbin/nologin www
cd /root/lamp/source
tar xzf pcre-8.33.tar.gz
cd pcre-8.33
./configure
make && make install
cd ../
tar xzf httpd-2.4.6.tar.gz
tar xzf apr-1.4.8.tar.gz
tar xzf apr-util-1.5.2.tar.gz
cd httpd-2.4.6
/bin/cp -R ../apr-1.4.8 ./srclib/apr
/bin/cp -R ../apr-util-1.5.2 ./srclib/apr-util
./configure --prefix=/usr/local/apache --enable-headers --enable-deflate --enable-mime-magic --enable-so --enable-rewrite --enable-ssl --with-ssl --enable-expires --enable-static-support --enable-suexec --disable-userdir --with-included-apr --with-mpm=prefork --disable-userdir --disable-cgid --disable-cgi
make && make install
/bin/cp /usr/local/apache/bin/apachectl  /etc/init.d/httpd
sed -i '2a # chkconfig: - 85 15' /etc/init.d/httpd
sed -i '3a # description: Apache is a World Wide Web server. It is used to serve' /etc/init.d/httpd
chmod 755 /etc/init.d/httpd
chkconfig --add httpd
chkconfig httpd on
cd ..

#logrotate apache log
cat > /etc/logrotate.d/apache << EOF
$wwwlogs_dir/*.log {
daily
rotate 5
missingok
dateext
compress
notifempty
sharedscripts
postrotate
    [ -f /usr/local/apache/logs/httpd.pid ] && kill -USR1 \`cat /usr/local/apache/logs/httpd.pid\`
endscript
}
EOF

service httpd start
}

function Apache_conf()
{
sed -i 's/^User daemon/User www/' /usr/local/apache/conf/httpd.conf
sed -i 's/^Group daemon/Group www/' /usr/local/apache/conf/httpd.conf
sed -i 's/^#ServerName www.example.com:80/ServerName 0.0.0.0:80/' /usr/local/apache/conf/httpd.conf
sed -i "s@AddType\(.*\)Z@AddType\1Z\n    AddType application/x-httpd-php .php .phtml\n    AddType application/x-httpd-php-source .phps@" /usr/local/apache/conf/httpd.conf
sed -i 's@^#LoadModule\(.*\)mod_deflate.so@LoadModule\1mod_deflate.so@' /usr/local/apache/conf/httpd.conf
sed -i 's@DirectoryIndex index.html@DirectoryIndex index.html index.php@' /usr/local/apache/conf/httpd.conf
sed -i "s@^DocumentRoot.*@DocumentRoot \"$home_dir/default\"@" /usr/local/apache/conf/httpd.conf
sed -i "s@^<Directory \"/usr/local/apache/htdocs\">@<Directory \"$home_dir/default\">@" /usr/local/apache/conf/httpd.conf
mkdir /usr/local/apache/conf/vhost
cat > /usr/local/apache/conf/vhost/admin.conf << EOF
<VirtualHost *:80>
    ServerAdmin admin@linuxeye.com
    DocumentRoot "$home_dir/default"
    ServerName $IP
    ErrorLog "$wwwlogs_dir/admin-error.log"
    CustomLog "$wwwlogs_dir/admin-access.log" common
<Directory "$home_dir/default">
    SetOutputFilter DEFLATE
    Options FollowSymLinks
    Require all granted
    AllowOverride All
    Order allow,deny
    Allow from all
    DirectoryIndex index.html index.php
</Directory>
</VirtualHost>
EOF
cat >> /usr/local/apache/conf/httpd.conf <<EOF
ServerTokens ProductOnly
ServerSignature Off
AddOutputFilterByType DEFLATE text/html text/plain text/css text/xml text/javascript
DeflateCompressionLevel 6
SetOutputFilter DEFLATE
Include conf/vhost/*.conf
EOF
}

function Install_PHP()
{
cd /root/lamp/source
tar xzf libiconv-1.14.tar.gz
cd libiconv-1.14
./configure --prefix=/usr/local
make && make install
cd ../

tar xzf libmcrypt-2.5.8.tar.gz
cd libmcrypt-2.5.8
./configure
make && make install
/sbin/ldconfig
cd libltdl/
./configure --enable-ltdl-install
make && make install
cd ../../

tar xzf mhash-0.9.9.9.tar.gz
cd mhash-0.9.9.9
./configure
make && make install
cd ../

tar xzf ImageMagick-6.8.7-5.tar.gz
cd ImageMagick-6.8.7-5
./configure
make && make install
cd ../

# linked library
cat >> /etc/ld.so.conf.d/local.conf <<EOF
/usr/local/lib
EOF
cat >> /etc/ld.so.conf.d/mysql.conf <<EOF
$db_install_dir/lib
EOF
/sbin/ldconfig
ln -s /usr/local/bin/libmcrypt-config /usr/bin/libmcrypt-config
ln -s $db_install_dir/include/* /usr/local/include/
ln -s /usr/local/include/ImageMagick-6 /usr/local/include/ImageMagick
if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
        ln -s /lib64/libpcre.so.0.0.1 /lib64/libpcre.so.1
        cp -frp /usr/lib64/libldap* /usr/lib
else
        ln -s /lib/libpcre.so.0.0.1 /lib/libpcre.so.1
fi

tar xzf mcrypt-2.6.8.tar.gz
cd mcrypt-2.6.8
/sbin/ldconfig
./configure
make && make install
cd ../

tar xzf php-5.5.5.tar.gz
cd php-5.5.5
./configure  --prefix=/usr/local/php --with-apxs2=/usr/local/apache/bin/apxs \
--with-config-file-path=/usr/local/php/etc --enable-opcache --with-mysql=$db_install_dir \
--with-mysqli=$db_install_dir/bin/mysql_config --with-pdo-mysql --disable-fileinfo \
--with-iconv-dir=/usr/local --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib \
--with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-exif \
--enable-sysvsem --enable-inline-optimization --with-curl --with-kerberos --enable-mbregex \
--enable-mbstring --with-mcrypt --with-gd --enable-gd-native-ttf --with-xsl --with-openssl \
--with-mhash --enable-pcntl --enable-sockets --with-ldap --with-ldap-sasl --with-xmlrpc \
--enable-ftp --with-gettext --enable-zip --enable-soap --disable-ipv6 --disable-debug
make ZEND_EXTRA_LIBS='-liconv'
make install

if [ -d "/usr/local/php" ];then
        echo -e "\033[32mPHP install successfully! \033[0m"
else
        echo -e "\033[31mPHP install failed, Please Contact the author! \033[0m"
        kill -9 $$
fi
#wget -c http://pear.php.net/go-pear.phar
#/usr/local/php/bin/php go-pear.phar

/bin/cp php.ini-production /usr/local/php/etc/php.ini
cd ..

tar xzf imagick-3.1.2.tgz
cd imagick-3.1.2
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make && make install
cd ../

# Support HTTP request curls
tar xzf pecl_http-1.7.6.tgz
cd pecl_http-1.7.6 
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make && make install
cd ../

# Modify php.ini
sed -i "s@extension_dir = \"ext\"@extension_dir = \"ext\"\nextension_dir = \"/usr/local/php/lib/php/extensions/`ls /usr/local/php/lib/php/extensions/`\"\nextension = \"imagick.so\"\nextension = \"http.so\"@" /usr/local/php/etc/php.ini
sed -i 's@^output_buffering =@output_buffering = On\noutput_buffering =@' /usr/local/php/etc/php.ini
sed -i 's@^;cgi.fix_pathinfo.*@cgi.fix_pathinfo=0@' /usr/local/php/etc/php.ini
sed -i 's@^short_open_tag = Off@short_open_tag = On@' /usr/local/php/etc/php.ini
sed -i 's@^expose_php = On@expose_php = Off@' /usr/local/php/etc/php.ini
sed -i 's@^request_order.*@request_order = "CGP"@' /usr/local/php/etc/php.ini
sed -i 's@^;date.timezone.*@date.timezone = Asia/Shanghai@' /usr/local/php/etc/php.ini
sed -i 's@^post_max_size.*@post_max_size = 50M@' /usr/local/php/etc/php.ini
sed -i 's@^upload_max_filesize.*@upload_max_filesize = 50M@' /usr/local/php/etc/php.ini
sed -i 's@^;upload_tmp_dir.*@upload_tmp_dir = /tmp@' /usr/local/php/etc/php.ini
sed -i 's@^max_execution_time.*@max_execution_time = 300@' /usr/local/php/etc/php.ini
sed -i 's@^disable_functions.*@disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server,fsocket@' /usr/local/php/etc/php.ini
sed -i 's@^session.cookie_httponly.*@session.cookie_httponly = 1@' /usr/local/php/etc/php.ini
sed -i 's@^pdo_mysql.default_socket.*@pdo_mysql.default_socket = /tmp/mysql.sock@' /usr/local/php/etc/php.ini
sed -i 's@#sendmail_path.*@#sendmail_path = /usr/sbin/sendmail -t@' /usr/local/php/etc/php.ini

sed -i 's@^\[opcache\]@[opcache]\nzend_extension=opcache.so@' /usr/local/php/etc/php.ini
sed -i 's@^;opcache.enable=.*@opcache.enable=1@' /usr/local/php/etc/php.ini
sed -i 's@^;opcache.memory_consumption.*@opcache.memory_consumption=128@' /usr/local/php/etc/php.ini
sed -i 's@^;opcache.interned_strings_buffer.*@opcache.interned_strings_buffer=8@' /usr/local/php/etc/php.ini
sed -i 's@^;opcache.max_accelerated_files.*@opcache.max_accelerated_files=4000@' /usr/local/php/etc/php.ini
sed -i 's@^;opcache.revalidate_freq.*@opcache.revalidate_freq=60@' /usr/local/php/etc/php.ini
sed -i 's@^;opcache.fast_shutdown.*@opcache.fast_shutdown=1@' /usr/local/php/etc/php.ini
sed -i 's@^;opcache.enable_cli.*@opcache.enable_cli=1@' /usr/local/php/etc/php.ini
}

function Install_Memcache()
{
cd /root/lamp/source
tar xzf memcache-2.2.7.tgz
cd memcache-2.2.7
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make && make install
sed -i 's@^extension_dir\(.*\)@extension_dir\1\nextension = "memcache.so"@' /usr/local/php/etc/php.ini
cd ../

tar xzf memcached-1.4.15.tar.gz
cd memcached-1.4.15
./configure --prefix=/usr/local/memcached
make && make install

ln -s /usr/local/memcached/bin/memcached /usr/bin/memcached
/bin/cp scripts/memcached.sysv /etc/init.d/memcached
sed -i 's@^USER=.*@USER=root@' /etc/init.d/memcached
sed -i 's@chown@#chown@' /etc/init.d/memcached
sed -i 's@/var/run/memcached/memcached.pid@/var/run/memcached.pid@' /etc/init.d/memcached
sed -i 's@^prog=.*@prog="/usr/local/memcached/bin/memcached"@' /etc/init.d/memcached
chmod +x /etc/init.d/memcached
chkconfig --add memcached
chkconfig memcached on
service memcached start
cd ..
}

function Install_Pureftp()
{
cd /root/lamp/source
tar xzf pure-ftpd-1.0.36.tar.gz
cd pure-ftpd-1.0.36
./configure --prefix=/usr/local/pureftpd CFLAGS=-O2 --with-mysql=$db_install_dir --with-quotas --with-cookie --with-virtualhosts --with-virtualchroot --with-diraliases --with-sysquotas --with-ratios --with-altlog --with-paranoidmsg --with-shadow --with-welcomemsg  --with-throttling --with-uploadscript --with-language=english 
make && make install
cp configuration-file/pure-config.pl /usr/local/pureftpd/sbin
chmod +x /usr/local/pureftpd/sbin/pure-config.pl
cp contrib/redhat.init /etc/init.d/pureftpd
sed -i 's@fullpath=.*@fullpath=/usr/local/pureftpd/sbin/$prog@' /etc/init.d/pureftpd
sed -i 's@pureftpwho=.*@pureftpwho=/usr/local/pureftpd/sbin/pure-ftpwho@' /etc/init.d/pureftpd
sed -i 's@/etc/pure-ftpd.conf@/usr/local/pureftpd/pure-ftpd.conf@' /etc/init.d/pureftpd
chmod +x /etc/init.d/pureftpd
chkconfig --add pureftpd
chkconfig pureftpd on

cd /root/lamp/conf
/bin/cp pure-ftpd.conf /usr/local/pureftpd/
/bin/cp pureftpd-mysql.conf /usr/local/pureftpd/
mysqlftppwd=`cat /dev/urandom | head -1 | md5sum | head -c 8`
sed -i 's/tmppasswd/'$mysqlftppwd'/g' /usr/local/pureftpd/pureftpd-mysql.conf
sed -i 's/mysqlftppwd/'$mysqlftppwd'/g' script.mysql
sed -i 's/ftpmanagerpwd/'$ftpmanagerpwd'/g' script.mysql
$db_install_dir/bin/mysql -uroot -p$dbrootpwd < script.mysql
service pureftpd start

tar xzf /root/lamp/source/ftp_v2.1.tar.gz
sed -i 's/tmppasswd/'$mysqlftppwd'/' ftp/config.php
sed -i "s/myipaddress.com/`echo $IP`/" ftp/config.php
sed -i 's@\$DEFUserID.*;@\$DEFUserID = "501";@' ftp/config.php
sed -i 's@\$DEFGroupID.*;@\$DEFGroupID = "501";@' ftp/config.php
sed -i 's@iso-8859-1@UTF-8@' ftp/language/english.php
/bin/cp /root/lamp/conf/chinese.php ftp/language/
sed -i 's@\$LANG.*;@\$LANG = "chinese";@' ftp/config.php
rm -rf  ftp/install.php
mv ftp $home_dir/default
}

function Install_phpMyAdmin()
{ 
cd $home_dir/default
tar xzf /root/lamp/source/phpMyAdmin-4.0.8-all-languages.tar.gz
mv phpMyAdmin-4.0.8-all-languages phpMyAdmin
}

function TEST()
{
echo '<?php
phpinfo()
?>' > $home_dir/default/phpinfo.php
cp /root/lamp/conf/index.html $home_dir/default
unzip -q /root/lamp/source/tz.zip -d $home_dir/default
chown -R www.www $home_dir/default
service httpd restart
}

function Iptables()
{
cat > /etc/sysconfig/iptables << EOF
# Firewall configuration written by system-config-securitylevel
# Manual customization of this file is not recommended.
*filter
:INPUT DROP [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:syn-flood - [0:0]
-A INPUT -i lo -j ACCEPT
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 21 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 20000:30000 -j ACCEPT
-A INPUT -p icmp -m limit --limit 100/sec --limit-burst 100 -j ACCEPT
-A INPUT -p icmp -m limit --limit 1/s --limit-burst 10 -j ACCEPT
-A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j syn-flood
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A syn-flood -p tcp -m limit --limit 3/sec --limit-burst 6 -j RETURN
-A syn-flood -j REJECT --reject-with icmp-port-unreachable
COMMIT
EOF
service iptables restart
}

Download_src 2>&1 | tee -a /root/lamp/lamp_install.log 
chmod +x /root/lamp/{init,vhost}.sh
sed -i "s@/home/wwwroot@$home_dir@g" /root/lamp/vhost.sh
sed -i "s@/home/wwwlogs@$wwwlogs_dir@g" /root/lamp/vhost.sh
/root/lamp/init.sh 2>&1 | tee -a /root/lamp/lamp_install.log 
if [ $choice_db == 'mysql' ];then
        db_install_dir=/usr/local/mysql
	db_data_dir=/data/mysql
        Install_MySQL 2>&1 | tee -a /root/lamp/lamp_install.log
fi
if [ $choice_db == 'mariadb' ];then
        db_install_dir=/usr/local/mariadb
	db_data_dir=/data/mariadb
        Install_MariaDB 2>&1 | tee -a /root/lamp/lamp_install.log
fi
Install_Apache 2>&1 | tee -a /root/lamp/lamp_install.log 
Install_PHP 2>&1 | tee -a /root/lamp/lamp_install.log 

if [ $Memcache_yn == 'y' ];then
	Install_Memcache 2>&1 | tee -a /root/lamp/lamp_install.log 
fi

if [ $FTP_yn == 'y' ];then
	Install_Pureftp 2>&1 | tee -a /root/lamp/lamp_install.log 
	Iptables 2>&1 | tee -a /root/lamp/lamp_install.log 
fi

if [ $phpMyAdmin_yn == 'y' ];then
	Install_phpMyAdmin 2>&1 | tee -a /root/lamp/lamp_install.log
fi
Apache_conf 2>&1 | tee -a /root/lamp/lamp_install.log
TEST 2>&1 | tee -a /root/lamp/lamp_install.log 

echo "################Congratulations####################"
echo -e "\033[32mPlease restart the server and see if the services start up fine.\033[0m"
echo ''
echo "The path of some dirs:"
echo -e "`printf "%-32s" "Apache dir:"`\033[32m/usr/local/apache\033[0m"
echo -e "`printf "%-32s" "$choice_DB dir:"`\033[32m$db_install_dir\033[0m"
echo -e "`printf "%-32s" "PHP dir:"`\033[32m/usr/local/php\033[0m"
echo -e "`printf "%-32s" "$choice_DB User:"`\033[32mroot\033[0m"
echo -e "`printf "%-32s" "$choice_DB Password:"`\033[32m${dbrootpwd}\033[0m"
echo -e "`printf "%-32s" "Manager url:"`\033[32mhttp://$IP/\033[0m"
