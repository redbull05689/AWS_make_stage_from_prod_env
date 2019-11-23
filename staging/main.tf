provider "aws" {
  
   region     = "us-west-1"
}

# resource "aws_ami_from_instance" "Web-AMI" {
#   name               = "${var.dns_env_name}.Web"
#   source_instance_id = "i-bfd3eb7f"
  
# }


# resource "aws_ami_from_instance" "DB-AMI" {
#   name             = "${var.dns_env_name}.DBA"
#   source_instance_id = "i-b342bb24"
# }


data "aws_ami" "Web" {
most_recent = true
owners = ["482441072630"] 

  filter {
      name   = "name"
      values = ["ACSAWEB*"]
  }
#depends_on = ["aws_ami_from_instance.Web-AMI"]
}


data "aws_ami" "DBA" {
most_recent = true
owners = ["482441072630"] 

  filter {
      name   = "name"
      values = ["ACSAWEB*"]
  }
 # depends_on = ["aws_ami_from_instance.DB-AMI"]
}

resource "aws_instance" "DB_server" {
  
  #count = 1
  ami           = "${data.aws_ami.DBA.id}"
  instance_type = "m4.large"
#  key_name               = "${aws_key_pair.key_pair.key_name}" 
  subnet_id              = "${aws_subnet.private.id}" 
  vpc_security_group_ids  = ["${aws_security_group.dbserver.id}"] 
#  vpc_security_group_ids = ["${aws_default_security_group.default.id}"] 
#  get_password_data      = true 
  associate_public_ip_address = true 
  
  
  tags = {
    Name = "${var.dns_env_name}.DB_server"
    Server = "DB"
  }
  #depends_on = ["aws_ami_from_instance.DB-AMI"]
}

data "template_file" "change_ip" {
  template = "${file("./script_change_db_ip.ps1.tpl")}"
  vars = {
    db_ip_private = "${aws_instance.DB_server.private_ip}"
  }
}  

resource "local_file" "powershell_script1" {
    content     = "${data.template_file.change_ip.rendered}"
    filename = "./script_change_db_ip.ps1"
}

data "template_file" "change_iss_settings" {
  template = "${file("./script.ps1.tpl")}"
  vars = {
    env_name = "${var.dns_env_name}"
  }
}  

resource "local_file" "powershell_script2" {
    content     = "${data.template_file.change_iss_settings.rendered}"
    filename = "./script.ps1"
}

data "template_file" "change_app_settings" {
  template = "${file("./script_D.ps1.tpl")}"
  vars = {
    env_name = "${var.dns_env_name}"
  }
}  

resource "local_file" "powershell_script3" {
    content     = "${data.template_file.change_app_settings.rendered}"
    filename = "./script_D.ps1"
}

resource "aws_instance" "Web_server" {
  #count = 1
  ami           = "${data.aws_ami.Web.id}"
  instance_type = "t2.medium"
  subnet_id              = "${aws_subnet.private.id}" 
  vpc_security_group_ids  = ["${aws_security_group.webserver.id}"] 
  associate_public_ip_address = true


    provisioner  "file" {
      source      = "./script.ps1"
      destination = "D:/script.ps1"
    connection {
      type     = "winrm"
      host     = "${aws_instance.Web_server.public_ip}"
      user     = "${var.admin_user}"
      password = "${var.admin_password}"
      timeout  = "15m"
      https    = true
      port     = "5986"
      insecure = true
              }
    }

    provisioner  "file" {
      source      = "./script_D.ps1"
      destination = "D:/script_D.ps1"
    connection {
      type     = "winrm"
      host     = "${aws_instance.Web_server.public_ip}"
      user     = "${var.admin_user}"
      password = "${var.admin_password}"
      timeout  = "15m"
      https    = true
      port     = "5986"
      insecure = true
              }
    }

    provisioner  "file" {
      source      = "./script_change_db_ip.ps1"
      destination = "D:/script_change_db_ip.ps1"
    connection {
      type     = "winrm"
      host     = "${aws_instance.Web_server.public_ip}"
      user     = "${var.admin_user}"
      password = "${var.admin_password}"
      timeout  = "15m"
      https    = true
      port     = "5986"
      insecure = true
              }
    }
    provisioner  "remote-exec" {
      #script      = "./script.ps1"
      inline = [
      "powershell -ExecutionPolicy Unrestricted -File D:\\script.ps1 "
      ]

      
    connection {
      type     = "winrm"
      host     = "${aws_instance.Web_server.public_ip}"
      user     = "${var.admin_user}"
      password = "${var.admin_password}"
      timeout  = "15m"
      https    = true
      port     = "5986"
      insecure = true
              }                          
      }
          provisioner  "remote-exec" {
      #script      = "./script.ps1"
      inline = [
      "powershell -ExecutionPolicy Unrestricted -File D:\\script_change_db_ip.ps1 "
      ]

      
    connection {
      type     = "winrm"
      host     = "${aws_instance.Web_server.public_ip}"
      user     = "${var.admin_user}"
      password = "${var.admin_password}"
      timeout  = "15m"
      https    = true
      port     = "5986"
      insecure = true
              }                          
      }
      provisioner  "remote-exec" {
      #script      = "./script.ps1"
      inline = [
      "powershell -ExecutionPolicy Unrestricted -File D:\\script_D.ps1"
      ]

      
    connection {
      type     = "winrm"
      host     = "${aws_instance.Web_server.public_ip}"
      user     = "${var.admin_user}"
      password = "${var.admin_password}"
      timeout  = "15m"
      https    = true
      port     = "5986"
      insecure = true
              }                          
      }

  tags = {
    Name = "${var.dns_env_name}.Web_server"
    
    Server = "Web"

  }
  #depends_on = ["aws_ami_from_instance.Web-AMI"]
}

#export TF_LOG_PATH=./terraform.log