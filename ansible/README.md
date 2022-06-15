# infra-gbc-validator-ansible
---
This section of the repository contains Ansible playbook for deploying Lighthouse client for Gnosis Beacon Chain (GBC).

You can learn more about Lighthouse-launch for Gnosis Beacon Chain here:
https://github.com/gnosischain/lighthouse-launch

## TOC
- [How to use](#how-to-use)
- [Configuration options](#configuration-options)

## How to use 
1. (Optional) Secure your data using Ansible Vault to encrypt your `keystore_password`:
   1. Create a plain-text file named `vpass` outside this working directory.
   2. Store an Ansible Vault password in this file.
   3. Define a path to this file in `vault_password_file` variable of [ansible.cfg](ansible.cfg) file.

2. By default, the inventory file `inventories/hosts.yml` is generated during the infrastructure deployment phase (Terraform). (see [`generate_ansible_inventory`](../terraform/README.md#generate_ansible_inventory))
   <blockquote><details>
   <summary><b>NOTE:</b> If you want to fill in the inventory file manually</summary>
   Fill in the `inventories/hosts.yml` inventory file. Note the following:
   <ul>
   <li>`ansible_host` values must match IP addresses from `terraform apply` command output.</li>
   <li>`ansible_user` value must always be `protoadmin`. This user is created for all instances during deployment for consistency.</li>
   <li>`ansible_ssh_private_key_file` value must match `path_to_ansible_public_key` parameter of deployment configuration.</li>
   </ul>
   </details></blockquote>

   > **NOTE:** In case you want to deploy GBC Validators on additional instances (e.g. bare metal), you should fill in the `inventories/other.yml` file for this purpose.
3. Configure options in [group_vars/all.yml](group_vars/all.yml) and [group_vars/gc_nodes.yml](group_vars/gc_nodes.yml) (see [specification](#configuration-options))
4. Create directories for keystores in `validator_keys` directory using the following command:
     ```bash
     ansible-playbook ./playbooks/deployment.yml -i inventories --tags preparation
     ```

     > **NOTE:** Created directories will be named after `hosts` in [inventories/hosts.yml](inventories/hosts.yml) (and `inventories/other.yml` if used). Each host from inventory will have its own corresponding directory.
5. Store your GBC `keystore*.json` files in corresponding directories.
6. Test connection to each instance using the following command:
   ```bash
   ansible -m ping -i inventories all
   ```
7. Validate changes that are about to be applyied using the following command:
   ```bash
   ansible-playbook ./playbooks/deployment.yml -i inventories --check --diff
   ```
8. Deploy the application using the following command:
   ```bash
   ansible-playbook ./playbooks/deployment.yml -i inventories
   ```

## Configuration options

### [group_vars/all.yml](group_vars/all.yml)

#### `xdai_rpc_url`

> Required: yes
>
> Type: `url`
>
> Example: `http://gc-node.gnosis.example.com:8545`

This parameter defines Gnosis Chain (xDai) RPC URL. You have to configure this parameter as following: http://gc-node. `hosted_zone`:`port` where:
   - `hosted zone` matches parameter whith the same name in your [Terraform configuration](../terraform/terraform.tfvars.json).
   - `port` matches one of ports defined by `vm_config.gc_node.general.ports.rpc` parameter in your [Terraform configuration](../terraform/terraform.tfvars.json).

#### `node_url`

> Required: yes
>
> Type: `url`
>
> Example: `http://gbc-node.gnosis.example.com:5052`

This parameter defines Gnosis Beacon Chain Node RPC URL. You have to configure this parameter as following: http://gbc-node. `hosted_zone`:`port` where:
   - `hosted zone` matches parameter whith the same name in your [Terraform configuration](../terraform/terraform.tfvars.json).
   - `port` matches one of ports defined by `vm_config.gbc_node.general.ports.rpc` parameter in your [Terraform configuration](../terraform/terraform.tfvars.json).

#### `target_peers`

> Required: no
> 
> Type: `int`
>
> Default: 80

This parameter defines the number of peers which beacon node should find and maintain. Leave it blank to use default value.

#### `graffitiwall`

> Required: no
>
> Type: refer to [documentation](https://lighthouse-book.sigmaprime.io/graffiti.html)
>
> Default: Lighthouse + version of the client

This parameter defines a *default* Validator Graffiti that will be used for drawing on the beaconcha.in graffiti wall (see [documentation](https://lighthouse-book.sigmaprime.io/graffiti.html)).

#### `keystore_password`

> Required: yes
>
> Type: `string` | Ansible Vault entry

This parameter defines a password to import Gnosis Beacon Chain keystores. It's the same password that has been used to generate the keystores. If you prefer to use Ansible Vault to store you secrets, Ansible Vault entry is also acceptable as a value.

#### `validator_keys_dir`

> Required: no
>
> Type: `path`
>
> Default: `{{ inventory_hostname }}`

This parameter defines a directory that contains validator keys. If you prefer to use different directory rather than default one, set this parameter to point to your directory of choice.

Be sure to follow this directory structure:
```
ansible/validator_keys
├── hostname1
│   ├── keystore-1.json
│   └── keystore-2.json
├── hostanme2
│   ├── keystore-3.json
│   └── keystore-4.json
```

Directories that are prefixed with `hostname` on this scheme must match in name with Ansible hosts in your [production.yml](production.yml) inventory file.

#### `update_lighthouse`

> Required: yes
>
> Type: `bool`
>
> Default: `false`

Setting this parameter to `true` will result in attempt to update Lighthouse. All service containers will be restarted. If [graffitiwall](#graffitiwall) parameter is changed, a force update will be attempted on the next run in spite of this parameter.

#### `node_slasher_enabled`

> Required: yes
>
> Type: `bool`
>
> Default: false

Setting this parameter to true enables slasher to run together with your node. To learn more see the official [documentation](https://github.com/gnosischain/lighthouse-launch#running-node).

#### `node_slasher_type`

> Required: yes
>
> Type: `string`
>
> Default: `private`
>
> Valid values: `public`, `private`

Setting this parameter to `public` enables broadcast found slashings to other peers. To learn more see the official [documentation](https://github.com/gnosischain/lighthouse-launch#running-node).

#### `node_metrics_enabled`

> Required: yes
>
> Type: `bool`
>
> Default: `true`

Setting this parameter to `false` disables nodes metrics collecting. To learn more see the official [documentation](https://lighthouse-book.sigmaprime.io/advanced_metrics.html?highlight=node-metric#example)


#### `node_metrics_address`

> Required: no
>
> Type: `ip`
>
> Default: `0.0.0.0`

This parameter is used to customize the metrics server. To learn more see the official [documentation](https://lighthouse-book.sigmaprime.io/advanced_metrics.html?highlight=node-metric#example)

#### `node_metrics_allow_origin`

> Required: no
>
> Type: `url`
>
> Default: `*`

This parameter is used to customize the metrics server. To learn more see the official [documentation](https://lighthouse-book.sigmaprime.io/advanced_metrics.html?highlight=node-metric#example)


#### `validator_metrics_enabled`

> Required: yes
>
> Type: `bool`
>
> Default: `true`

Setting this parameter to `false` disables validators metrics collecting. To learn more see the official [documentation](https://lighthouse-book.sigmaprime.io/advanced_metrics.html?highlight=node-metric#validator-client-metrics)

#### `validator_metrics_address`

> Required: no
>
> Type: `ip`
>
> Default: `0.0.0.0`

This parameter is used to customize the metrics server. To learn more see the official [documentation](https://lighthouse-book.sigmaprime.io/advanced_metrics.html?highlight=node-metric#example)

#### `validator_metrics_allow_origin`

> Required: no
>
> Type: `url`
>
> Default: `*`

This parameter is used to customize the metrics server. To learn more see the official [documentation](https://lighthouse-book.sigmaprime.io/advanced_metrics.html?highlight=node-metric#example)


#### `python_script_grafana_dependencies`

> Required: yes
>
> Type: `bool`
>
> Default: `true`

Setting this parameter to `false` uninstalls Python dependencies that are used by the script that collects metrics for Grafana.

### [group_vars/gc_nodes.yml](group_vars/gc_nodes.yml)

#### `json_rpc_port`

> Required: yes
>
> Type: `int`
>
> Default: `8545`

This parameter defines a JSON-RPC port that is open for the Gnosis Chain (xDai) node. Make sure that value of this parameter matches one of ports defined by `vm_config.gc_node.general.ports.rpc` parameter of your [Terraform configuration](../terraform/terraform.tfvars.json).

#### `json_rpc_host`

> Required: yes
>
> Type: `ip`
>
> Default: `0.0.0.0`

This parameter defines IP address that is allowed to send JSON-RPC requests to this node. `0.0.0.0` means that requests from any host are allowed. To learn more refer to [documentation](https://docs.nethermind.io/nethermind/ethereum-client/configuration/jsonrpc)

#### `websocket_port`

> Required: yes
>
> Type: `int`
>
> Default: `8545`

This parameter defines a websocket port that is open for the Gnosis Chain (xDai) node. Make sure that value of this parameter matches one of ports defined by `vm_config.gc_node.general.ports.ws` parameter of your [Terraform configuration](../terraform/terraform.tfvars.json).


#### `ethstats_id`

> Required: no
>
> Type: `string`

This parameter defines a display name of your validator on [xDAI Netstat](https://dai-netstat.poa.network/).

#### `ethstats_contact`

> Required: no
>
> Type: `string`

This parameter defines a contact details (e.g. email address) of your validator on  [xDAI Netstat](https://dai-netstat.poa.network/).

#### `ethstats_secret`

> Required: no
>
> Type: `string`

This parameter defines a secret key that is used to connect to [xDAI Netstat](https://dai-netstat.poa.network/). Request the key from xDAI team to enable this behaviour.

#### `ethstats_key`

> Required: no
>
> Type: `string` (hex 64 characters long whithout leading `0x`)

This parameter defines your mining address private key.

#### `ethstats_key`

> Required: no
>
> Type: `string`

This parameter defines an API key that is used to connect to [Seq log collector](https://datalust.co/seq). Request the key from xDAI team to enable this behaviour.
