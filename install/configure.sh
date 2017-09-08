#!/bin/bash

CONF_MASTER=/etc/salt/master
CONF_MINION=/etc/salt/minion
CONF_SOURCE=/root/bootstrap/configs/saltstack

CONF_D=/etc/salt/master.d

if [[ $(hostname -s) = salt ]]; then
  cp -r /root/bootstrap/salt /srv/
  cp $CONF_SOURCE/master $CONF_MASTER
  cp $CONF_SOURCE/file_roots.conf $CONF_D
  cp $CONF_SOURCE/pillar_roots.conf $CONF_D
  apt-get install python-pip -y
  pip install docker-py
  service salt-master restart
  echo "192.168.10.10 salt" >> /etc/hosts
  echo "192.168.10.20 chat" >> /etc/hosts
fi

if [[ $(hostname -s) = chat ]]; then
  cp $CONF_SOURCE/minion $CONF_MINION
  service salt-minion restart
  echo "192.168.10.10 salt" >> /etc/hosts
  echo "192.168.10.20 chat" >> /etc/hosts
fi
