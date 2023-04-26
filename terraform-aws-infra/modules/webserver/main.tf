# using default security group
resource "aws_default_security_group" "default-sg" {
    vpc_id = var.vpc_id

    # firewall rules
    # ingress - inbound traffic
    
    ingress {
        cidr_blocks = [ var.my_ip ]
        from_port = 22
        protocol = "tcp"
        to_port = 22
    }

    ingress {
        cidr_blocks = [ "0.0.0.0/0" ]
        from_port = 8080
        protocol = "tcp"
        to_port = 8080
    }

    # outbound traffic
    egress {
        cidr_blocks = [ "0.0.0.0/0" ]
        from_port = 0
        protocol = "-1"
        to_port = 0
        prefix_list_ids = []
    }
    
    tags = {
        Name: "${var.env_prefix}-default-sg"
    }
}

# query ami id from aws
data "aws_ami" "latest-amazon-linux-image" {
    most_recent = true
    owners = [ "amazon" ]
    filter {
      name = "name"
      values = [ var.image_name ]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

# create ssh key pair
resource "aws_key_pair" "ssh-key" {
    key_name = "server-key"
    public_key = file(var.public_key_location)
}

# creating ec2 instance
resource "aws_instance" "myapp-server" {
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type

    subnet_id = var.subnet_id
    vpc_security_group_ids = [ aws_default_security_group.default-sg.id ]
    availability_zone = var.avail_zone

    associate_public_ip_address = true
    key_name = aws_key_pair.ssh-key.key_name

    # installing docker and running nginx container
    # this block will only get executed once on initial run
    user_data = file("entry-script.sh")

    tags = {
      Name = "${var.env_prefix}-server"
    }
}