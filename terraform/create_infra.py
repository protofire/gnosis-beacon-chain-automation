#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Prepare cloud providers infrastracture for Terraform."""

import json

ip_offset = {
    "gc_node": 0,
    "gbc_node": 32,
    "gbc_validator": 64
}

def prepare_providers(config_file: str, file_out: str) -> None:
    """Parse tfvars config file and create infrastructure scheme."""
    with open(config_file, mode='r', encoding='utf-8') as config_json:
        config = json.loads(config_json.read())

    template: dict = {
        "locals": {
            "aws-infra": {},
            "azure-infra": {},
            "gcp-infra": {},
            "all-infra": {}
        }
    }

    all_infra: dict = {
        "all_ips": {}
    }

    for provider in config["clouds"]:
        for item in config["clouds"][provider]:
            template["locals"][f"{provider}-infra"][item] = \
                provider_templator(
                    provider,
                    all_infra,
                    item,
                    config["clouds"][provider][item],
                    config["vm_config"])

    template["locals"]["all-infra"] = all_infra

    with open(file_out, mode='w', encoding='utf-8') as json_out:
        json_out.write(json.dumps(template, indent="\t"))


def provider_templator(
    provider: str,
    all_infra: dict,
    account: str,
    config: dict,
    vm_config: dict
) -> dict:
    """Provider templator."""
    instances: dict = {}

    for role in vm_config:
        instances.update(
            instances_templator(
                provider, all_infra, account, role, config, vm_config))

    return instances


def instances_templator(
    provider: str,
    all_infra: dict,
    account: str,
    role: str,
    config: dict,
    vm_config: dict
) -> dict:
    """Instances templator."""
    instances: dict = {}

    for i in range(config[role]["count"]):
        instance: dict = {}
        instance = fill_vm_config(instance, role, i, vm_config)
        region_mask = {
            "aws": f'{config["region"]}',
            "azure": f'{config["region"]}',
            "gcp": f'{config["region"]}-'
        }
        num = i if len(config[role]["zones"]) >= i + 1 else -1
        instance["index"] = i + 1
        instance["route53_region"] = config["route53_region"]
        instance["cidr_range"] = config["cidr_range"]
        instance["health_check_path"] = \
            vm_config[role]["general"]["health_check_path"]
        instance["health_check_type"] = \
            vm_config[role]["general"]["health_check_type"]
        if provider != "azure":
            instance["zone"] = \
                f'{region_mask[provider]}{config[role]["zones"][num]}'
        else:
            instance["zone"] = f'{config[role]["zones"][num]}'

        for item in vm_config[role]["provider_specific"][provider]:
            instance[item] = \
                vm_config[role]["provider_specific"][provider][item]

        if "custom_vm_config" in config[role]:
            for item in config[role]["custom_vm_config"]:
                instance[item] = config[role]["custom_vm_config"][item]

        ip_addr, mask = instance["cidr_range"].split("/")
        ip_octets = ip_addr.split(".")
        changed_octet_index = (int(mask) // 8) - 1
        ip_octets[changed_octet_index] = \
            str(int(ip_octets[changed_octet_index]) + ip_offset[role] + i)
        instance["cidr_range"] = f'{".".join(ip_octets)}/{mask}'

        if role != "gbc_validator":
            name: str = f'{instance["vm_name"]}-{account}-{provider}'
            all_infra["all_ips"].update({
                name: {
                    "role": instance["role"],
                    "route53_region": instance["route53_region"],
                    "name": name,
                    "provider": provider
                }
            })

        instances[instance.pop("vm_name")] = instance

    return instances


def fill_vm_config(
    instance: dict, role: str, num: int, vm_config: dict
) -> dict:
    """Fill in VM configs."""
    instance["role"] = role
    instance["vm_name"] = f'{vm_config[role]["general"]["vm_name"]}{num+1}'
    instance["root_disk_size"] = vm_config[role]["general"]["root_disk_size"]
    instance["disk_size"] = vm_config[role]["general"]["disk_size"]
    instance["ports"] = vm_config[role]["general"]["ports"]
    instance["target_tags"] = vm_config[role]["general"]["target_tags"]

    return instance


def generate_tf(infra_file: str, output_file: str) -> None:
    """Generate providers and module calls."""
    with open(infra_file, mode='r', encoding='utf-8') as infra_json:
        infra = json.loads(infra_json.read())

    template: dict = {}

    providers: dict = {}
    modules: dict = {}
    outputs: dict = {}
    concats: str = ""
    concats_route53: str = ""

    for provider in infra["clouds"]:
        provider_name_dict = {
            "aws": "aws",
            "azure": "azurerm",
            "gcp": "google"
        }
        provider_name = provider_name_dict[provider]
        provider_conf = infra["clouds"][provider]
        for alias in provider_conf:
            providers[provider_name] = [] \
                if provider_name not in providers else providers[provider_name]
            providers[provider_name].append(
                fill_provider(alias, provider, provider_conf)
            )
            modules[alias] = fill_module(alias, provider)
            outputs[f"instances_{alias}"] = fill_output(alias)
            concats = ",".join([
                concats,
                f"lookup(module.{alias}.ips, role, [])"
            ]) if concats else f"lookup(module.{alias}.ips, role, [])"
            concats_route53 = ",".join([
                concats_route53,
                f"lookup(module.{alias}.route53_ips, role, {{}})"
            ]) if concats_route53 else \
                f"lookup(module.{alias}.route53_ips, role, {{}})"

    outputs["all_ips"] = {
        "description": "List of All IPs",
        "value": "${local.ips}"
    }
    outputs["all_route53_ips"] = {
        "description": "List of All IPs for Route53",
        "value": "${local.route53_ips}"
    }

    template["provider"] = providers
    template["module"] = modules
    template["output"] = outputs
    template["locals"] = {
        "ips": f"${{ {{ for role, value in var.vm_config : role =>\
            concat({concats})\
        }} }}",
        "route53_ips": f"${{ {{ for role, value in var.vm_config : role =>\
            merge({concats_route53})\
        }} }}"
    }

    with open(output_file, mode='w', encoding='utf-8') as json_out:
        json_out.write(json.dumps(template, indent="\t"))


def fill_provider(
    alias: str, provider: str, provider_conf: dict
) -> dict:
    """Fill in providers."""
    provider_code: dict = {}
    provider_code["alias"] = alias
    if provider != "azure":
        provider_code["region"] = provider_conf[alias]["region"]
    else:
        provider_code["features"] = {}
        provider_code["skip_provider_registration"] = "true"
    if provider == "gcp":
        provider_code["project"] = provider_conf[alias]["project"]

    return provider_code


def fill_module(alias: str, provider: str) -> dict:
    """Fill in modules."""
    module_code: dict = {}

    module_code["source"] = f"./{provider}"
    module_code["infra"] = f"${{local.{provider}-infra.{alias}}}"
    module_code["vm_config"] = "${var.vm_config}"
    module_code["provider_name"] = alias
    module_code["region"] = f"${{var.clouds.{provider}.{alias}.region}}"
    module_code["vpc_cidr_range"] = \
        f"${{var.clouds.{provider}.{alias}.vpc_cidr_range}}"
    module_code["all_ips"] = "${ local.ips }"
    module_code["security_options"] = "${local.security_options}"
    if provider == "aws":
        module_code["providers"] = {
            provider: f"{provider}.{alias}"
        }
    elif provider == "azure":
        module_code["resource_group_name"] = \
            f"${{var.clouds.{provider}.{alias}.project}}"
        module_code["providers"] = {
            "azurerm": f"azurerm.{alias}"
        }
    elif provider == "gcp":
        module_code["use_aws_route53"] = "${var.use_aws_route53}"
        module_code["hosted_zone"] = "${var.hosted_zone}"
        module_code["providers"] = {
            "google": f"google.{alias}"
        }

    return module_code


def fill_output(alias: str) -> dict:
    """Fill in alias ouptup."""
    output_code: dict = {}

    output_code["description"] = "Show instances information"
    output_code["value"] = \
        f'${{ length(module.{alias}.instances_output) != 0 ? \
             module.{alias}.instances_output : {{}} }}'

    return output_code


if __name__ == '__main__':
    prepare_providers(
        "./terraform.tfvars.json",
        "./locals.tf.json"
    )
    generate_tf(
        "./terraform.tfvars.json",
        "./main.tf.json"
    )
