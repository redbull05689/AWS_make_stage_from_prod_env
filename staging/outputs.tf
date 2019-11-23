output "elastic_web_ip" { 
#  value = "${aws_instance.web_server.*.public_ip}" 
  value = "${aws_eip.web_server.public_ip}" 
} 

 
output "private_db_ip" { 
#  value = "${aws_instance.sandbox_db.*.public_ip}" 
  value = "${aws_instance.DB_server.private_ip}" 
} 
 
