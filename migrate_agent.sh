#!/bin/bash

PE_SERVER="CHANGEME"

# halt on errors
set -e

echo "Migrating puppet agent node to ${PE_SERVER}"

# never overwrite an existing backup
if [ ! -d /root/puppet-ssl-backup ] && [ -d /etc/puppetlabs/puppet/ssl ] ; then
    cp -a /etc/puppetlabs/puppet/ssl /root/puppet-ssl-backup
else
    echo "Skipping puppet SSL backup (exists or no source)"
fi

if ! command -v curl >/dev/null ; then
    echo "Installing curl"
    yum -y install curl
fi

# download install before removing packages
# verifies connectivity to new server
URL="https://${PE_SERVER}:8140/packages/current/install.bash"
curl -k "${URL}" > /root/install-pe.bash

# remove old agent
if [ -x /opt/puppetlabs/bin/puppet-enterprise-uninstaller ] ; then
    /opt/puppetlabs/bin/puppet-enterprise-uninstaller > /tmp/pe-uninstall.log
else
    rpm -e puppet-agent || true
    rm -rf /opt/puppetlabs
    rm -rf /etc/puppetlabs
fi

# install new agent
cd /root && bash install-pe.bash
