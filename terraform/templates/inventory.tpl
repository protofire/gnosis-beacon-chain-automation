---
all:
  children:
%{ for role, instances in route53_ips ~}
    ${role}s:
      hosts:
%{ for name, value in instances ~}
        ${name}:
          ansible_host: ${value.ip}
          ansible_user: ${admin_user }
          ansible_ssh_private_key_file: ${path_to_ansible_public_key}
%{ endfor ~}
%{ endfor ~}
