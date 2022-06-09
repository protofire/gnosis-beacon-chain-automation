Gnosis Chain Node
=========

This Ansible role deploys Gnosis Chain Node on the hosts.

Requirements
------------

Nothing special

Role Variables
--------------

| Variable | Description | Defaul value |
| :------- | :---------- | :----------- |
| gc_node_dir | Default path to the gbc path | /data/gc |
| gc_node_repo | URL to GC Node repository | https://github.com/xdaichain/validator-node-dockerized |
| gc_node_repo_branch | Default repo branch | nethermind |

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
    - role: gc_node
```

License
-------

GPLv3

Author Information
------------------

 - [Leonid Belyatskiy](https://github.com/lorks) 
