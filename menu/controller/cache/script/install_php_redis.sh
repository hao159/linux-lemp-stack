#!/bin/bash

######################################################################
#           Auto Install & Optimize LEMP Stack                       #
#                                                                    #
#                Author: Sanvv - HOSTVN Technical                    #
#                  Website: https://hostvn.vn                        #
#                                                                    #
#              Please do not remove copyright. Thank!                #
#  Please do not copy under any circumstance for commercial reason!  #
######################################################################

# Install the PHP redis extension (and igbinary) for every installed PHP version.
# Prebuilt packages are used: Ondrej/Sury on Debian family, Remi on RHEL family.

source /var/hostvn/menu/helpers/variable_common

PHP1_VERSION=$(grep -w "php1_version" "/var/hostvn/.hostvn.conf" | cut -f2 -d'=')
PHP2_RELEASE=$(grep -w "php2_release" "/var/hostvn/.hostvn.conf" | cut -f2 -d'=')
PHP2_VERSION=$(grep -w "php2_version" "/var/hostvn/.hostvn.conf" | cut -f2 -d'=')

_install_ext(){
    local ver="$1"
    if ! "php${ver}" -m | grep -qi "^igbinary$"; then
        php_ext_install "${ver}" igbinary
    fi
    if ! "php${ver}" -m | grep -qi "^redis$"; then
        php_ext_install "${ver}" redis
    fi
    systemctl restart "php${ver}-fpm"
}

_install_ext "${PHP1_VERSION}"

if [ "${PHP2_RELEASE}" == "yes" ] && [ -n "${PHP2_VERSION}" ]; then
    _install_ext "${PHP2_VERSION}"
fi
