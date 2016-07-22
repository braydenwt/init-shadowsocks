#! /usr/bin/env bash

# Usage: run it on ubuntu-based server.

if [ ! -f shadowsocks.json ] 
then
  cat > shadowsocks.json << EOF
{
  "server": "0.0.0.0",
  "server_port": 443,
  "password": "123456789"
  "local_port": 1080,
  "method": "rc4-md5",
  "timeout": 600,
  "fast_open": true
}
EOF
fi

if [ $# -gt 0 ]
then
  echo "reading command..."
  cmd=$1
else
  echo "Usage: shadowsocks [command]"
  exit
fi

echo "command: $cmd"

sudo_required ()
{
  [ $(id -u) = 0 ] || { echo 'must be root' ; exit 1; }
}

# sudo
install_pip_if_not_exist ()
{
  pip_cmd=$(which pip)
  echo "locating pip cmd:$pip_cmd"

  if [ -z "$pip_cmd" -o "$pip_cmd" == " " ]
  then
    echo "installing pip ..."
    apt-get install python-pip
  fi
}

# sudo
install_shadowsocks_if_not_exist ()
{
  shadowsocks_cmd=$(which ssserver)
  echo "locating shadowsocks cmd:$shadowsocks_cmd"

  if [ ! -z "$shadowsocks_cmd" -a "$shadowsocks_cmd" != " " ]
  then
    echo "shadowsocks already installed."
    exit
  fi

  install_pip_if_not_exist

  echo "installing shadowsocks with pip ..."
  pip install shadowsocks  
}

# sudo
shadowsocks_start ()
{
  ssserver -c shadowsocks.json -d start
}

# sudo
shadowsocks_stop ()
{
  ssserver -d stop
}

# sudo
shadowsocks_client_start ()
{
  sslocal -c ~/shadowsocks.json -d start
}

# sudo
shadowsocks_client_stop ()
{
  sslocal -d stop
}

case $cmd in 

  "install" )
  sudo_required
  install_shadowsocks_if_not_exist
  ;;

  "start" )
  sudo_required
  shadowsocks_start
  ;;
  
  "stop" )
  sudo_required
  shadowsocks_stop
  ;;
  
  "restart" )
  sudo_required
  shadowsocks_stop
  shadowsocks_start
  ;;

  "on" )
  sudo_required
  shadowsocks_client_start
  ;;

  "off" )
  sudo_required
  shadowsocks_client_stop
  ;;

  "log" )
  tail -f /var/log/shadowsocks.log
  ;;
  
  * )
  echo "command $cmd not supported"
  ;;
 
esac

if [ -f shadowsocks.json ] 
then
  rm shadowsocks.json
fi
