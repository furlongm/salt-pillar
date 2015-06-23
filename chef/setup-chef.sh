#!/bin/bash

usage() {
    echo "Usage: $0 -e EMAIL_ADDRESS (as root)"
    exit 1
}

install_deps() {
    if [ -f '/etc/debian_version' ] ; then
        apt-get update
        pm="apt-get -y"
    elif [ -f '/etc/redhat-release' ] ; then
        pm="yum -y"
    elif [ -f '/etc/SuSE-release' ] ; then
        pm="zypper -n"
    fi
    $pm install git curl
}

install_chef() {
    curl -L https://www.chef.io/chef/install.sh | sudo bash || exit 1
}

install_vim_syntax_highlighting() {
    tmp_dir=$(mktemp -d)
    mkdir -p ~/.vim
    git clone https://github.com/vadv/vim-chef.git ${tmp_dir}
    cp -r ${tmp_dir}/* ~/.vim/
    rm -fr ${tmp_dir}
}

get_config_from_github() {
    tmp_dir=$(mktemp -d)
    git clone https://github.com/furlongm/standalone-configuration-management ${tmp_dir}
    cp -r ${tmp_dir}/chef /srv
    rm -fr ${tmp_dir}
}

main() {
    which chef-solo 1>/dev/null 2>&1 || install_chef
    install_vim_syntax_highlighting
    get_config_from_github
    #sed -i -e "s/admin@example.com/${email}/" /srv/chef/postfix/init.sls
    if [ "${run_local}" == "true" ] ; then
        run_path=.
    else
        run_path=/srv/chef
    fi
    chef-solo -c ${run_path}/solo.rb
}

while getopts ":le:" opt ; do
    case ${opt} in
        e)
            email=${OPTARG}
            ;;
        l)
            run_local=true
            ;;
        *)
            usage
            ;;
    esac
done

if [[ -z ${email} || ${EUID} -ne 0 ]] ; then
    usage
else
    which git 1>/dev/null 2>&1 || install_deps
    which curl 1>/dev/null 2>&1 || install_deps
    main
fi
