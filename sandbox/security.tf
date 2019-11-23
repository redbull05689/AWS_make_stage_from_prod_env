resource "aws_security_group" "webserver" { 
  name              = "web_server" 
  description       = "Allow Web Server traffic" 
  vpc_id            = "${aws_vpc.mainsandbox.id}" 
 
  ingress { 
    from_port       = 80 
    to_port         = 80 
    protocol        = "tcp" 
    cidr_blocks     = ["0.0.0.0/0"] 
  } 
 
  ingress { 
    from_port       = 443 
    to_port         = 443 
    protocol        = "tcp" 
    cidr_blocks     = ["0.0.0.0/0"] 
  } 
 
  ingress { 
    from_port       = 3389 
    to_port         = 3389 
    protocol        = "tcp" 
    cidr_blocks     = ["0.0.0.0/0"] 
  } 
 
  ingress { 
    from_port       = 5985 
    to_port         = 5985 
    protocol        = "tcp" 
    cidr_blocks     = ["0.0.0.0/0"] 
  } 

  ingress { 
    from_port       = 5986 
    to_port         = 5986 
    protocol        = "tcp" 
    cidr_blocks     = ["0.0.0.0/0"] 
  }
 
  egress { 
    from_port       = 80 
    to_port         = 80 
    protocol        = "tcp" 
    cidr_blocks     = ["0.0.0.0/0"] 
  } 
 
  egress { 
    from_port       = 443 
    to_port         = 443 
    protocol        = "tcp" 
    cidr_blocks     = ["0.0.0.0/0"] 
  } 
 
  egress { 
    from_port       = 1433 
    to_port         = 1433 
    protocol        = "tcp" 
#    security_groups = ["${aws_security_group.dbserver.name}"] 
    cidr_blocks     = ["10.0.2.0/24"] 
  } 


} 
 
resource "aws_security_group" "dbserver" { 
  name              = "db_server" 
  description       = "Allow DB Server traffic" 
  vpc_id            = "${aws_vpc.mainsandbox.id}" 
 
  ingress { 
    from_port       = 1433 
    to_port         = 1433 
    protocol        = "tcp" 
#    security_groups = ["${aws_security_group.webserver.name}"] 
    cidr_blocks     = ["10.0.2.0/24"] 
  } 
 
  ingress { 
    from_port       = 3389 
    to_port         = 3389 
    protocol        = "tcp" 
    cidr_blocks     = ["0.0.0.0/0"] 
  } 
 
  egress { 
    from_port       = 80 
    to_port         = 80 
    protocol        = "tcp" 
    cidr_blocks     = ["0.0.0.0/0"] 
  } 



 
  egress { 
    from_port       = 443 
    to_port         = 443 
    protocol        = "tcp" 
    cidr_blocks     = ["0.0.0.0/0"] 
  } 
} 
 
resource "aws_security_group" "winrm" { 
  name              = "allow_winrm" 
  description       = "Allow WinRM traffic" 
  vpc_id            = "${aws_vpc.mainsandbox.id}" 
 
  # ingress { 
  #   from_port       = 5985 
  #   to_port         = 5985 
  #   protocol        = "tcp" 
  #   cidr_blocks     = ["0.0.0.0/0"] 
  # } 

  ingress { 
    from_port       = 5986 
    to_port         = 5986 
    protocol        = "tcp" 
    cidr_blocks     = ["0.0.0.0/0"] 
  } 
} 
 
resource "aws_network_acl" "restrict_env" {
  vpc_id = "${aws_vpc.mainsandbox.id}"
}

resource "aws_network_acl_rule" "restrict_env_db" {
  network_acl_id = "${aws_network_acl.restrict_env.id}"
  rule_number    = 200
  egress         = true
  protocol       = "all"
  rule_action    = "deny"
  cidr_block = "52.9.215.185/32"
  from_port      = -1
  to_port        = -1
}


resource "aws_network_acl_rule" "restrict_env_web" {
  network_acl_id = "${aws_network_acl.restrict_env.id}"
  rule_number    = 400
  egress         = true
  protocol       = "all"
  rule_action    = "deny"
  cidr_block = "52.9.10.55/32"
  from_port      = -1
  to_port        = -1
}

resource "aws_network_acl_rule" "restrict_env_ftp" {
  network_acl_id = "${aws_network_acl.restrict_env.id}"
  rule_number    = 600
  egress         = true
  protocol       = "all"
  rule_action    = "deny"
  cidr_block = "54.215.220.145/32"
  from_port      = -1
  to_port        = -1
}
