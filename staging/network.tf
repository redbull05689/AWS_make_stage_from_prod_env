resource "aws_vpc" "mainstaging" { 
  cidr_block = "10.0.0.0/16" 
 
  tags = { 
    Name = "acsa" 
  } 
} 
 
resource "aws_subnet" "public" { 
  vpc_id     = "${aws_vpc.mainstaging.id}" 
  cidr_block = "10.0.1.0/24" 

 
  tags = { 
    Name = "Public" 
  } 
} 
 
resource "aws_subnet" "private" { 
  vpc_id     = "${aws_vpc.mainstaging.id}" 
  cidr_block = "10.0.2.0/24" 
 
 
  tags = { 
    Name = "Private" 
  } 
} 
 
resource "aws_default_route_table" "rt" { 
  default_route_table_id = "${aws_vpc.mainstaging.default_route_table_id}" 
 
  route { 
    cidr_block = "0.0.0.0/0" 
    gateway_id = "${aws_internet_gateway.gw.id}" 
  } 
 
  tags = { 
    Name = "default" 
  } 
} 
 
# Internet GW 
resource "aws_internet_gateway" "gw" { 
  vpc_id = "${aws_vpc.mainstaging.id}" 
 
  tags = { 
    Name = "mainstaging" 
  } 
} 
 
# EC2 Instances 
resource "aws_eip" "web_server" { 
#  instance = "${aws_instance.web_server.id}" 
  vpc      = true 
} 
 
resource "aws_eip_association" "eip_web_server_assoc" { 
  instance_id   = "${aws_instance.Web_server.id}" 
  allocation_id = "${aws_eip.web_server.id}" 
} 
 
data "aws_route53_zone" "acsa_org" { 
  name         = "acsa.org." 
} 
 
resource "aws_route53_record" "web_server" { 
  zone_id = "${data.aws_route53_zone.acsa_org.zone_id}" 
  name    = "${var.dns_env_name}.${data.aws_route53_zone.acsa_org.name}"
  type    = "A" 
  ttl     = "3600" 
  records = ["${aws_eip.web_server.public_ip}"] 
 
}

resource "aws_route53_record" "api_web_server" { 
  zone_id = "${data.aws_route53_zone.acsa_org.zone_id}" 
  name    = "api.${var.dns_env_name}.${data.aws_route53_zone.acsa_org.name}"
  type    = "A" 
  ttl     = "3600" 
  records = ["${aws_eip.web_server.public_ip}"] 
 
}

resource "aws_route53_record" "ams_web_server" { 
  zone_id = "${data.aws_route53_zone.acsa_org.zone_id}" 
  name    = "ams.${var.dns_env_name}.${data.aws_route53_zone.acsa_org.name}"
  type    = "A" 
  ttl     = "3600" 
  records = ["${aws_eip.web_server.public_ip}"] 
 
}

# resource "aws_route53_record" "reports_web_server" { 
#   zone_id = "${data.aws_route53_zone.acsa_org.zone_id}" 
#   name    = "reports.${var.dns_env_name}.${data.aws_route53_zone.acsa_org.name}"
#   type    = "A" 
#   ttl     = "3600" 
#   records = ["${aws_eip.web_server.public_ip}"] 
 
# }