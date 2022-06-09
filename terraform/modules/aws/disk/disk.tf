resource "aws_ebs_volume" "ebs_volume" {
  size              = var.ebs.size
  type              = "gp3"
  iops              = var.ebs.iops
  throughput        = var.ebs.throughput
  availability_zone = var.availability_zone

  tags = {
    Name = "${var.ebs.name}"
  }
}
