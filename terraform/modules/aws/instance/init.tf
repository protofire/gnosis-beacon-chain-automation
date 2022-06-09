data "template_file" "init" {
  template = <<-EOF
                #!/bin/bash

                echo "Create protoadmin user..."

                useradd -m -s /bin/bash protoadmin
                usermod -aG sudo protoadmin
                mkdir -p /home/protoadmin/.ssh/
                touch /home/protoadmin/.ssh/authorized_keys

                echo "${file("${var.protoadmin_authorized_keys.path_to_ansible_public_key}")}" >> /home/protoadmin/.ssh/authorized_keys
                echo "${file("${var.protoadmin_authorized_keys.path_to_engineer_public_key}")}" >> /home/protoadmin/.ssh/authorized_keys

                echo "protoadmin ALL = (ALL: ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/protoadmin
                chown -R protoadmin:protoadmin /home/protoadmin/.ssh
                chmod 700 -R /home/protoadmin/.ssh
                chmod 600 /home/protoadmin/.ssh/authorized_keys

                echo "User protoadmin created!"

                echo "Set hostname..."

                hostnamectl set-hostname ${var.ec2.hostname}

                echo "Done!"

                echo "Starting do some stuff with additional volume..."

                while true
                do
                if [ -e ${var.ec2.ebs_device_name} ] ; then

                  echo "Disk attached! Trying to find file system..."

                  DISK_NAME=$(echo ${var.ec2.ebs_device_name} | sed 's/dev//' | tr -d /)

                  FS=$(lsblk --output NAME,FSTYPE --json | grep $DISK_NAME | tr -d ' ')
                  
                  if [[ $FS == *"null"* ]]; then
                    
                    echo "Disk doesn't have file system! Preparing..."

                    mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard ${var.ec2.ebs_device_name}
                    mkdir /data && chmod -R 777 /data
                    cp /etc/fstab /etc/fstab.orig
                    UUID=$(blkid ${var.ec2.ebs_device_name} -s UUID -o value)
                    echo "UUID=$UUID  /data  ext4  discard,defaults,nofail  0  2" | tee -a /etc/fstab
                    mount -a

                    break
                  else

                    echo "Disk has file system! Attaching..."

                    mkdir /data && chmod -R 777 /data
                    cp /etc/fstab /etc/fstab.orig
                    UUID=$(blkid ${var.ec2.ebs_device_name} -s UUID -o value)
                    echo "UUID=$UUID  /data  ext4  discard,defaults,nofail  0  2" | tee -a /etc/fstab
                    mount -a

                    break
                  fi
                else
                  echo "Disk still attaching..."
                  sleep 5
                fi
                done

                echo "All steps completed!"
    EOF
}
