Gnosis Beacon Chain Node and Validator
=========

This Ansible role deploys Gnosis Beacon Chain Nodes and Validators on the hosts.

Requirements
------------

Nothing special

Role Variables
--------------

| Variable | Description | Defaul value |
| :------- | :---------- | :----------- |
| gbc_lighthouse_dir | Default path to the gbc path | /data/gbc |
| gbc_lighthouse_repo | URL to GBC lighthouse-launch repository | https://github.com/gnosischain/lighthouse-launch |
| gbc_lighthouse_repo_branch | Default repo branch | master |

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
    - role: gbc_lighthouse
```

License
-------

GPLv3

Author Information
------------------

 - [Leonid Belyatskiy](https://github.com/lorks) 
