Docker Compose
=========

This Ansible role installs (or updates) docker and/or docker compose on the hosts.
It also installs the python dependencies for Ansbile to work.

Requirements
------------

Nothing special

Role Variables
--------------

| Variable | Description | Defaul value |
| :------- | :---------- | :----------- |
| docker_compose_path | Default path to the docker-compose executable | /usr/local/sbin/docker-compose |
| docker_compose_version | Docker-compose version | latest |
| add_user_to_docker_group | If true, the user will be added to the docker group | true |
| docker_package_state | Docker package version | latest |
| docker_packages | The list of docker packages | docker-ce, docker-ce-cli, containerd.io |
| debian_docker_package_dependencies | The list of docker packages for Debian-based systems | apt-transport-https, ca-certificates, curl, gnupg, lsb-release |

Dependencies
------------

None

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

```yaml
- hosts: all
  become: true
  gather_facts: yes
  roles:
    - role: docker_compose
```

License
-------

GPLv3

Author Information
------------------

 - [Leonid Belyatskiy](https://github.com/lorks) 
