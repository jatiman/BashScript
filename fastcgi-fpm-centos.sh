#!/bin/bash
#
# Script for installing and configure mod_fastcgi+php-fpm+httpd2
#
# Jati Nurohman | jatinurohman19@gmail.com
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version, with the following exception:
# the text of the GPL license may be omitted.

if [[ $(id -u) -ne 0 ]]; then
  echo -e "\nYou are not a root user! Please use su - or sudo su - before run this script\n";
  exit 1
fi

installed=$(yum list installed | grep httpd);

if [[ ! -z $installed ]]; then
  echo "This server already contain httpd! Please remove it before use this script";
  exit 1;
fi

echo "######################################################################"
echo "#   Welcome to mod_fastcgi and php-fpm installation for centos 6.x   #"
echo "######################################################################"

POS=$(pwd)

# get server architecture and set default top_dir
ARCH=$(uname -m)
if [[ $ARCH == "x86_64" ]]; then
	TOP_DIR="/usr/lib64/httpd/"
else
	TOP_DIR="/usr/lib/httpd/"
fi

# define top_dir by user
echo "top dir (default = $TOP_DIR, leave blank if you dont know what you do) : "; read TOP_DIR_INP

#if [[ $TOP_DIR_INP != "" ]]; then
if [[ ! -z $TOP_DIR_INP ]]; then
  TOP_DIR=$TOP_DIR_INP
fi

# update repo
yum update -y

# install httpd php-fpm
yum install httpd php-fpm php-mysqli -y

# install mod_fastcgi builder
yum install libtool httpd-devel apr-devel apr wget unzip -y

# get mod_fastcgi
if [[ ! -f "precise.zip" ]]; then
	wget -q https://github.com/ceph/mod_fastcgi/archive/precise.zip
	if [ $? -ne 0 ]; then
		echo "### Cannot download mod_fastcgi ###"
		exit 1
	fi
fi

unzip precise.zip && \
cd mod_fastcgi-precise

#copy makefile for httpd2
cp Makefile.AP2 Makefile

#compile
make 'top_dir='$TOP_DIR && \
make install 'top_dir='$TOP_DIR

cd $POS
rm -rf mod_fastcgi-precise

################build mod_fastcgi done####################
################add conf file to httpd####################

touch /etc/httpd/conf.d/fastcgi.conf && \
$(echo "LoadModule fastcgi_module modules/mod_fastcgi.so

  <IfModule mod_fastcgi.c>
    FastCGIExternalServer /usr/sbin/php-fpm -host 127.0.0.1:9000
    AddHandler php-fastcgi .php

    #<LocationMatch "/status">
    #  SetHandler php-fastcgi-virt
    #  Action php-fastcgi-virt /usr/sbin/php-fpm.fcgi virtual
    #</LocationMatch>

    Action php-fastcgi /usr/sbin/php-fpm.fcgi
    ScriptAlias /usr/sbin/php-fpm.fcgi /usr/sbin/php-fpm

    <Directory /usr/sbin>
      Options ExecCGI FollowSymLinks
      SetHandler fastcgi-script
      Order allow,deny
      Allow from all
    </Directory>
  </IfModule>" > /etc/httpd/conf.d/fastcgi.conf)

#disable selinux
#sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
#echo 0 > /selinux/enforce

service httpd restart && service php-fpm restart > /dev/null 2>&1

#iptables to open access http
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT

echo "Installation Success"
exit 0
###############php-fpm+mod_fastcgi+httpd2 successfully installed################!/bin/bash
#
# Script for installing and configure mod_fastcgi+php-fpm+httpd2
#
# Jati Nurohman | jatinurohman19@gmail.com
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version, with the following exception:
# the text of the GPL license may be omitted.



echo "################################################################################"
echo "#   Welcome to mod_fastcgi and php-fpm automatic installation for centos 6.x   #"
echo "################################################################################"

POS=$(pwd)
#get server architecture and set default top_dir
ARCH=$(uname -m)
if [[ $ARCH == "x86_64" ]]; then
	TOP_DIR="/usr/lib64/httpd/"
else
	TOP_DIR="/usr/lib/httpd/"
fi

#define top_dir by user
echo "top dir (default = $TOP_DIR, leave blank if dont know what you do) : "; read TOP_DIR_INP

if [[ $TOP_DIR_INP != "" ]]; then
	TOP_DIR=$TOP_DIR_INP
fi

#install httpd php-fpm
yum install httpd php-fpm -y
#install mod_fastcgi builder
yum install libtool httpd-devel apr-devel apr wget unzip -y

#get file
if [[ ! -f "precise.zip" ]]; then
	wget -q https://github.com/ceph/mod_fastcgi/archive/precise.zip
	if [ $? -ne 0 ]; then
		echo "### no internet connection to download mod_fastcgi ###"
		exit 1
	fi
fi
unzip precise.zip && \
cd mod_fastcgi-precise

#copy makefile for httpd2
cp Makefile.AP2 Makefile

#compile
make 'top_dir='$TOP_DIR && \
make install 'top_dir='$TOP_DIR

cd $POS
rm -rf mod_fastcgi-precise

################build mod_fastcgi done####################
################add conf file to httpd####################
touch /etc/httpd/conf.d/fastcgi.conf && \
$(echo "LoadModule fastcgi_module modules/mod_fastcgi.so

  <IfModule mod_fastcgi.c>  
    FastCGIExternalServer /usr/sbin/php-fpm -host 127.0.0.1:9000
    AddHandler php-fastcgi .php  

    #<LocationMatch "/status">
    #  SetHandler php-fastcgi-virt
    #  Action php-fastcgi-virt /usr/sbin/php-fpm.fcgi virtual
    #</LocationMatch>

    Action php-fastcgi /usr/sbin/php-fpm.fcgi  
    ScriptAlias /usr/sbin/php-fpm.fcgi /usr/sbin/php-fpm  

    <Directory /usr/sbin>  
      Options ExecCGI FollowSymLinks  
      SetHandler fastcgi-script  
      Order allow,deny  
      Allow from all  
    </Directory>  
  </IfModule> " > /etc/httpd/conf.d/fastcgi.conf)

#disable selinux
#sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
#echo 0 > /selinux/enforce

service httpd restart && service php-fpm restart > /dev/null 2>&1

#iptables to open access http
#iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT

echo "installation success"
exit 0
###############php-fpm+mod_fastcgi+httpd2 successfully installed###############