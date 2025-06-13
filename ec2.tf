# This script will run to stored data in S3 EC2 aws site
resource "aws_instance" "nginx" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.allow_all.id]

  tags = var.ec2_tags

  provisioner "local-exec" {
    command = "echo ${self.public_ip} > inventory"
    #on_failure = continue #ignoring errors  
    # if 10 line not given echo if show error after 11 line is ignowing error goes to 14-16 line it will display destroy  
  }

  provisioner "local-exec" {
    command = "echo 'instance is destroyed'"
    when    = destroy
  } # this is upto Local connect process

  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo dnf install nginx -y",
      "sudo systemctl start nginx"
    ]

  }

  provisioner "remote-exec" {
    when = destroy
    inline = [ 
      "sudo systemctl stop nginx"
    ]

  }

}
resource "aws_security_group" "allow_all" {
  name        = var.sg_name
  description = var.sg_description

  ingress {
    from_port        = var.from_port
    to_port          = var.to_port
    protocol         = "-1"
    cidr_blocks      = var.cidr_blocks
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = var.from_port
    to_port          = var.to_port
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = var.sg_tags
}