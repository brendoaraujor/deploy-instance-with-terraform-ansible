terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 2.70"
        }
    }
}

provider "aws" {
    profile = "default"
    region  = "us-west-2"
}

/*
 * Cria a keypair que será usada para conectar a instancia EC2
 */
resource "aws_key_pair" "keypair" {
    key_name    = "TerraformAnsible-Keypair"
    public_key  = var.public_key
}

/*
 * Cria o Security Group para permir o trafego HTTP e SSH
 */
resource "aws_security_group" "sg-ec2" {
    name        = "dev"

    ingress {
        description = "HTTP from everywhere"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "SSH from everywhere"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "dev"
    }
}

/*
 * Cria AWS Instance
 */
resource "aws_instance" "servers" {
    count               = 3
    ami                 = "ami-0da36f7f059b7086e" // Ubuntu 20.04 
    instance_type       = "t2.micro"
    key_name            = "TerraformAnsible-Keypair"

    security_groups = [aws_security_group.sg-ec2.name]

    tags = {
        Name = "Server${count.index}"
    }
}

data "template_file" "hosts" {
    template = file("./hosts.tpl")
    vars = {
        instance_name = join(" ansible_user=ubuntu ansible_ssh_private_key_file=/home/brendo/deploy-instance-ec2/ssh-key ansible_ssh_common_args='-o StrictHostKeyChecking=no'\n", concat(aws_instance.servers.*.public_ip, [""]))
    }
}

resource "local_file" "hosts_file" {
    content  = data.template_file.hosts.rendered
    filename = "./ansible/hosts"
}

output "public_ips" {
    value = aws_instance.servers.*.public_ip
}