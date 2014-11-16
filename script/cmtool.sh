#!/bin/bash -eux

# CM and CM_VERSION variables should be set inside of the Packer template:
#
# Values for CM can be:
#   'nocm'               -- build a box without a configuration management tool
#   'chef'               -- build a box with Chef
#   'chefdk'             -- build a box with Chef Development Kit
#   'salt'               -- build a box with Salt
#   'puppet'             -- build a box with Puppet
#
# Values for CM_VERSION can be (when CM is chef|chefdk|salt|puppet):
#   'x.y.z'              -- build a box with version x.y.z of Chef
#   'x.y'                -- build a box with version x.y of Salt
#   'x.y.z-apuppetlabsb' -- build a box with package version of Puppet
#   'latest'             -- build a box with the latest version
#
# Set CM_VERSION to 'latest' if unset because it can be problematic
# to set variables in pairs with Packer (and Packer does not support
# multi-value variables).
CM_VERSION=${CM_VERSION:-latest}

#
# Provisioner installs.
#

install_chef()
{
    echo "==> Installing Chef"
    wget https://gist.githubusercontent.com/narkisr/5e37903f1d1bf386ceb5/raw/d87fe7bff0f557d16c2c9b92fe0e6637595ed530/chef-preq.sh
    chmod +x chef-preqs.sh
    /bin/bash chef-preq.sh
}

install_chef_dk()
{
    echo "==> Installing Chef Development Kit"
    if [[ ${CM_VERSION:-} == 'latest' ]]; then
        echo "==> Installing latest Chef Development Kit version"
        curl -Lk https://www.getchef.com/chef/install.sh | sh -s -- -P chefdk
    else
        echo "==> Installing Chef Development Kit ${CM_VERSION}"
        curl -Lk https://www.getchef.com/chef/install.sh | sh -s -- -P chefdk -v ${CM_VERSION}
    fi

    echo "==> Adding Chef Development Kit and Ruby to PATH"
    echo 'eval "$(chef shell-init bash)"' >> /home/vagrant/.bash_profile
    chown vagrant /home/vagrant/.bash_profile
}

install_salt()
{
    echo "==> Installing Salt"
    if [[ ${CM_VERSION:-} == 'latest' ]]; then
        echo "Installing latest Salt version"
        wget -O - http://bootstrap.saltstack.org | sudo sh
    else
        echo "Installing Salt version $CM_VERSION"
        curl -L http://bootstrap.saltstack.org | sudo sh -s -- git $CM_VERSION
    fi
}

install_puppet()
{
    echo "==> Installing Puppet"
    wget https://gist.githubusercontent.com/narkisr/6097786/raw/902226d865be04dc26b5afb00526ca6d7701bdb7/puppet-preqs.sh
    chmod +x puppet-preqs.sh
    /bin/bash puppet-preqs.sh
}

#
# Main script
#

case "${CM}" in
  'chef')
    install_chef
    ;;

  'chefdk')
    install_chef_dk
    ;;

  'salt')
    install_salt
    ;;

  'puppet')
    install_puppet
    ;;

  *)
    echo "==> Building box without baking in a configuration management tool"
    ;;
esac
