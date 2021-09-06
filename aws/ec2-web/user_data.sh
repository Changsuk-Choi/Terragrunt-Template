#!/bin/bash

NOW=$(date +"%Y-%m-%d-%H:%M")
INSTANCE_AZ=`curl http://169.254.169.254/latest/meta-data/placement/availability-zone`
REGION=`echo $INSTANCE_AZ | sed 's/.$//g'`
INSTANCE_ID=`curl http://169.254.169.254/latest/meta-data/instance-id`
INSTANCE_IP=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
INSTANCE_EIP=`curl http://169.254.169.254/latest/meta-data/public-ipv4`
INSTANCE_TYPE=`curl http://169.254.169.254/latest/meta-data/instance-type`

echo '#!/bin/sh
cat << EOF
********************************************************************************
* This is a private computer facility.                                         *
* Access for any reason must be specifically authorized by the manager.        *
* Unless you are so authorized, your access and any other use                  *
* may expose you to criminal and civil proceedings.                            *
* This system access is monitored for our auditing.                            *
********************************************************************************
* Region                : '$REGION'
* Availibility Zone     : '$INSTANCE_AZ'
* Instance id           : '$INSTANCE_ID'
* Instance Type         : '$INSTANCE_TYPE'
* Public IP             : '$INSTANCE_EIP'
* Private IP            : '$INSTANCE_IP'
********************************************************************************
EOF' > /etc/update-motd.d/90-messages
chmod +x /etc/update-motd.d/90-messages
/usr/sbin/update-motd

userdel lp
chmod 755 /etc/profile
chmod 400 /etc/shadow
chmod 644 /etc/hosts
chmod 644 /etc/services
chmod 700 /usr/bin/last
chmod 700 /usr/sbin/ifconfig
chmod 644 /var/log/messages
chmod 600 /var/log/wtmp
chmod 600 /var/log/btmp
systemctl stop rpcbind.service
systemctl disable rpcbind.service

echo " " >> /etc/profile
echo "# UMASK" >> /etc/profile
echo "umask 022" >> /etc/profile
echo "export umask" >> /etc/profile

echo " " >> /etc/profile
echo "# Session Timeout" >> /etc/profile
echo "TMOUT=1800" >> /etc/profile
echo "export TMOUT" >> /etc/profile

echo " " >> /etc/profile
echo "# Add timestamp to .bash_history" >> /etc/profile
echo 'HISTTIMEFORMAT="%Y-%m-%d_%H:%M:%S"' >> /etc/profile
echo "export HISTTIMEFORMAT" >> /etc/profile
source /etc/profile

sed -i -e 's/localhost localhost.localdomain localhost4 localhost4.localdomain4/localhost '${HOSTNAME}'/g' -i -e 's/localhost6 localhost6.localdomain6/localhost '${HOSTNAME}'/g' /etc/hosts
echo ${HOSTNAME} > /proc/sys/kernel/hostname

sed -i 's/#Port 22/Port 8222/g' /etc/ssh/sshd_config
service sshd restart

yum update -y

# install Compile Library
yum install -y apr apr-devel apr-util expat-devel openssl-devel gcc gcc-c++

# install Openssl 1.0.2
cd /tmp
curl -L -C - -O 'https://www.openssl.org/source/openssl-1.0.2-latest.tar.gz'
tar -zxf openssl-1.0.2-latest.tar.gz
cd openssl-1.0.2*
./config --prefix=/usr --openssldir=/usr/local/openssl shared
make
sudo make install

# install Apache HTTPD
cd /tmp
curl -L -C - -O 'http://archive.apache.org/dist/httpd/httpd-2.4.38.tar.gz'
curl -L -C - -O 'http://mirror.apache-kr.org//apr/apr-1.6.5.tar.gz'
curl -L -C - -O 'http://mirror.apache-kr.org//apr/apr-util-1.6.1.tar.gz'
curl -L -C - -O 'https://sourceforge.net/projects/pcre/files/pcre/8.41/pcre-8.41.tar.gz'
tar -xvzf httpd-2.*.gz
tar -xvzf apr-1*.gz
tar -xvzf apr-util-1.*.gz
tar -xvzf pcre-8*.gz

# install APR
cd apr-1*
./configure
make
make install

# install APR-Util
cd /tmp/apr-util-1.*
./configure --with-apr=/usr/local/apr
make
make install

# install PCRE 
cd /tmp/pcre-8*
./configure --prefix=/usr/local/pcre
make
make install

# install HTTPD
cd /tmp/httpd-2.*
./configure --prefix=/usr/local/apache2 --enable-proxy --enable-so --enable-http --enable-ssl --with-ssl=/usr/local/openssl --enable-modules=ssl --with-mpm=worker --enable-info --enable-cache --with-pcre=/usr/local/pcre --with-apr=/usr/local/apr
make
make install

# create a symbolic link to HTTPD 
ln -s /usr/local/apache2 /usr/local/apache

# create automated start
cp -a /usr/local/apache/bin/apachectl /etc/init.d/httpd
sed -i '1a\\# chkconfig: 345 50 50' /etc/init.d/httpd
sed -i '2a\\# description: Web server' /etc/init.d/httpd
chkconfig --add httpd

# replace text in index.html
sed -i 's/It works!/Bespin Training Apache Server/g' /usr/local/apache/htdocs/index.html

# start HTTPD
sleep 10
service httpd start
