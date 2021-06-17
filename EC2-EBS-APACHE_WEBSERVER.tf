provider "aws"{
    region = "ap-south-1"
    profile = "default"
    }

resource "aws_security_group" "allow_http_80_port"{
    name = "allow_http_80_port"
    description = "ALLOW HTTP 80 PORT"
    ingress{
        description = "Inbound rule"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks  = ["0.0.0.0/0"]
        #ipv6_cidr_blocks = ["::/0"]
    }
       ingress{
        description = "Inbound rule"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks  = ["0.0.0.0/0"]
        #ipv6_cidr_blocks = ["::/0"]
    }
    tags = {
        Name = "allow_http_80_port"
    }

    egress {
      cidr_blocks = ["0.0.0.0/0"]
      description = "OUTBOUND RULE"
      from_port = 0
      protocol = "all"
      to_port = 0
    } 

}


resource "aws_instance" "webos1"{
    ami = "ami-010aff33ed5991201"
    instance_type = "t2.micro"
    security_groups = ["allow_http_80_port"]
    key_name = "AWS-KEY"
      tags ={
        Name = "Web server by TF"
    }
}




resource "aws_ebs_volume" "st1"{
    availability_zone = aws_instance.webos1.availability_zone
    size=10
    tags={
        Name="WEB SERVER HDD BY TF"
    }
}

resource "aws_volume_attachment" "ebs_attache"{
    device_name = "/dev/sdh"
    volume_id = aws_ebs_volume.st1.id
    instance_id = aws_instance.webos1.id
}

resource "null_resource" "nullresource0" {
    connection {
  type = "ssh"
  user = "ec2-user"
  private_key= file("AWS-KEY.pem")
  host = aws_instance.webos1.public_ip
}

provisioner "remote-exec" {
    inline = [
        "sudo yum install httpd -y",
        "sudo yum install php -y",
        "sudo systemctl start httpd",
        "sudo systemctl enable httpd",
        "sudo mkfs.ext4 /dev/sdh",
        "sudo mount /dev/sdh /var/www/html",
        "sudo yum install git -y",
        "sudo git clone https://github.com/yanuragaj/gitphptest.git  /var/www/html/web"
    ]
}

    provisioner "local-exec" {
        command= "chrome http://${aws_instance.webos1.public_ip}/web/index.php"
    
    }

}