provider "aws" {
    region = "us-east-1"
}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}
variable my_ip {}
variable instance_type {}
variable public_key_location {}

# custom vpc
resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name: "${var.env_prefix}-vpc"
    }
}

# custom subnet
resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name: "${var.env_prefix}-subnet-1"
    }
}

# # route table
# resource "aws_route_table" "myapp_route_table" {
#     vpc_id = aws_vpc.myapp-vpc.id

#     route {
#         cidr_block = "0.0.0.0/0"
#         gateway_id = aws_internet_gateway.myapp-igw.id 
#     }

#     tags = {
#         Name: "${var.env_prefix}-rtb"
#     }
# }

# internet gateway
resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = aws_vpc.myapp-vpc.id

    tags = {
        Name: "${var.env_prefix}-igw"
    }
}

# # associate subnet with route table
# resource "aws_route_table_association" "a-rtb-subnet" {
#     subnet_id = aws_subnet.myapp-subnet-1.id
#     route_table_id = aws_route_table.myapp_route_table.id
# }

# using default route table
# no need to create the association, it is associated by default
resource "aws_default_route_table" "main-rtb" {
    default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }

    tags = {
        Name: "${var.env_prefix}-main-rtb"
    }
}

# # security group
# resource "aws_security_group" "myapp-sg" {
#     name = "myapp-sg"
#     vpc_id = aws_vpc.myapp-vpc.id

#     # firewall rules
#     # ingress - inbound traffic
#     ingress = [ 
#         {
#             cidr_blocks = [ var.my_ip ]
#             from_port = 22
#             protocol = "tcp"
#             to_port = 22
#         },
#         {
#             cidr_blocks = [ "0.0.0.0/0" ]
#             from_port = 8080
#             protocol = "tcp"
#             to_port = 8080
#         }
#     ]

#     # outbound traffic
#     egress = [
#         {
#             cidr_blocks = [ "0.0.0.0/0" ]
#             from_port = 0
#             protocol = "-1"
#             to_port = 0
#             prefix_list_ids = []
#         }
#     ]
    

#     tags = {
#         Name: "${var.env_prefix}-sg"
#     }
# }

# using default security group
resource "aws_default_security_group" "default-sg" {
    vpc_id = aws_vpc.myapp-vpc.id

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
      values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

output "aws_ami_id" {
    value = data.aws_ami.latest-amazon-linux-image.id
}

output "ec2_public_ip" {
    value = aws_instance.myapp-server.public_ip
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

    subnet_id = aws_subnet.myapp-subnet-1.id
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

resource "aws_instance" "myapp-server-two" {
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type

    subnet_id = aws_subnet.myapp-subnet-1.id
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

resource "aws_instance" "myapp-server-three" {
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type

    subnet_id = aws_subnet.myapp-subnet-1.id
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