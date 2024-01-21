resource "tls_private_key" "portfolio" {
  algorithm = "RSA"
  rsa_bits  = 4096

  provisioner "local-exec" {
    command = "echo '${self.public_key_pem}' > ./pubkey.pem"
  }
}

resource "aws_key_pair" "portfolio" {
  key_name   = "portfolio"
  public_key = tls_private_key.portfolio.public_key_openssh

  provisioner "local-exec" {
    command = "echo '${tls_private_key.portfolio.private_key_pem}' > ./portfolio.pem"
  }
}

resource "aws_instance" "control_plane" {
  instance_type               = var.control_plane_nodes.instance_type
  ami                         = var.ubuntu_ami
  key_name                    = aws_key_pair.portfolio.key_name
  subnet_id                   = aws_subnet.portfolio[var.availability_zones[0]].id
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.common_ports.id,
    aws_security_group.k8_control_plane.id
  ]
  root_block_device {
    volume_size = var.control_plane_nodes.volume_size
    volume_type = "gp2"
  }
  tags = {
    Name              = "${var.env}-portfolio-${var.region}-control-plane"
    Availability_Zone = var.availability_zones[0]
  }

}

resource "aws_instance" "worker_nodes" {
  for_each                    = toset(var.availability_zones)
  instance_type               = var.worker_nodes.instance_type
  ami                         = var.ubuntu_ami
  key_name                    = aws_key_pair.portfolio.key_name
  subnet_id                   = aws_subnet.portfolio[each.key].id
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.common_ports.id,
    aws_security_group.k8_control_plane.id
  ]
  root_block_device {
    volume_type = "gp2"
    volume_size = var.worker_nodes.volume_size
  }

  tags = {
    Name              = "${var.env}-portfolio-${var.region}-worker-${index(var.availability_zones, each.key)}"
    Availability_Zone = each.key
  }
}
