resource "aws_instance" "ec2" {
  ami                         = var.ec2.ami
  instance_type               = var.ec2.instance_type
  availability_zone           = var.availability_zone
  associate_public_ip_address = true

  subnet_id = var.ec2.subnet_id

  /* vpc_security_group_ids = [
   *   var.ec2.sg_id
   * ] */

  user_data = data.template_file.init.rendered

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.ec2.ebs_disk_size
    delete_on_termination = true
  }

  tags = {
    Name = "${var.ec2.name}"
  }

  lifecycle {
    ignore_changes = [
      user_data,
      ami,
    ]
  }
}

# For AWS EBS we could specify device name for attached volume. By default it's '/dev/sda/', '/dev/xvda' for root. 
#
# But when we specify AWS instance which is running on Nitro System (link below) root EBS on instance is '/dev/nvme0n1'. Because of this additional volume is ignore device_name in volume_attachment resource and called it like "/dev/nvme[0-26]n1".
# 
# We should remember it and specify 'device_name' for init.sh in EC2 variables scope like:
#
# - device_name = "/dev/nvme1n1" -> if instance is running on Nitro System
#
# - device_name = "/dev/xvdh" -> for other
#
# Useful links:
#
# - https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/device_naming.html#available-ec2-device-names - Linux device names convention
# - https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/RootDeviceStorage.html - Root device storage
# - https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html#ec2-nitro-instances - Nitro System based type of instances

resource "aws_volume_attachment" "volume_attachment" {
  device_name  = "/dev/xvdh" # By default for all instances (had an error with /dev/nvme1n1: "Value (/dev/nvme1n1) for parameter device is invalid. /dev/nvme1n1 is not a valid EBS device name.")
  force_detach = true
  volume_id    = var.ec2.ebs_volume_id
  instance_id  = aws_instance.ec2.id

  lifecycle {
    ignore_changes = [
      device_name,
    ]
  }
}
