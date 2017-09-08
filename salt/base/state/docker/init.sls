
include:
  - pip

{% if grains['os_family'] == 'RedHat' %}
{% set repo = 'main' %}
{% set lsb_dist = salt['grains.get']('os', '')|lower %}
{% set dist_version = salt['grains.get']('osmajorrelease', '') %}

"Disable firewalld":
   service.dead:
     - name: firewalld

"Add YUM Docker repo":
  pkgrepo.managed:
    - name: "Docker-{{ repo }}-Repository"
    - humanname: "docker-{{ repo }}-repo"
    - file: "/etc/yum.repos.d/docker-{{ repo }}.repo"
    - baseurl: "https://yum.dockerproject.org/repo/{{ repo }}/centos/7"
    - enabled: True
    - gpgkey: https://yum.dockerproject.org/gpg
    - require:
      - service: "Disable firewalld"

{% elif grains['os_family'] == 'Debian' %}

{% set repo = 'main' %}
{% set lsb_dist = salt['grains.get']('lsb_distrib_id', '')|lower %}
{% set dist_version = salt['grains.get']('lsb_distrib_codename', '') %}
{% set kernel_release = salt['grains.get']('kernelrelease', '') %}

"Add APT Docker repo":
  pkgrepo.managed:
    - name: "deb https://apt.dockerproject.org/repo {{ lsb_dist }}-{{ dist_version }} {{ repo }}"
    - file: /etc/apt/sources.list.d/docker-main.list
    - keyid: 58118E89F3A912897C070ADBF76221572C52609D
    - keyserver: hkp://p80.pool.sks-keyservers.net:80

{% endif %}

"Install Docker":
  pkg.installed:
    - name: docker-engine
    - refresh: True
    - pkg: docker-engine

"Start Docker Service":
  service.running:
    - name: docker
    - reload: True
    - init_delay: 10
    - enable: True
    - require:
      - pkg: "Install Docker"

"Docker Python API":
  pip.installed:
    - name: docker-py
    - upgrade: True
    - require:
      - service: "Start Docker Service"
      - cmd: "Update PIP"
