data "aws_ami" "ubuntu" {
     most_recent = true
     filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server*"]
 }

     filter {
       name   = "virtualization-type"
       values = ["hvm"]
 }

     owners = ["099720109477"]

 }



 resource "aws_iam_role" "role" {
  name = "${var.project_name}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "tls_private_key" "key_pair" {
  count = length(var.instance_names)
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key" {
  count = length(var.instance_names)
  key_name   = "${var.instance_names[count.index]}-keypair"
  public_key = tls_private_key.key_pair[count.index].public_key_openssh
}

resource "local_file" "pem_file" {
  count = length(var.instance_names)
  filename = pathexpand("cred/${var.instance_names[count.index]}.pem")
  file_permission = "400"
  sensitive_content = tls_private_key.key_pair[count.index].private_key_pem
}


resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "test_profile" {
  name = "${var.project_name}-iam-profile"
  role = "${aws_iam_role.role.name}"
}
 
 resource "aws_security_group" "optimus-dev" {
  name        = "${var.project_name}-sg"
  description = "Allow TLS inbound traffic1"

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "TLS from VPC"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "TLS from VPC"
    from_port        = 3000
    to_port          = 3000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}


resource "aws_instance" "optimus-portfoilo-new" {
  count = length(var.instance_names)
  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name = "${var.instance_names[count.index]}-keypair"
  vpc_security_group_ids = [aws_security_group.optimus-dev.id]
  iam_instance_profile = "${aws_iam_instance_profile.test_profile.name}"
  tags = {
    Name = "${var.instance_names[count.index]}"
  }
    root_block_device {
    volume_size    = 15
  }

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.key_pair[count.index].private_key_pem
      host        = "${self.public_ip}"
    }

    provisioner "remote-exec" {
    inline = [
      "sudo apt update"
    ]

  }

  
}
