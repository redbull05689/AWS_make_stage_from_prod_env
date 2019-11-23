This terrafprm mainfest crates an environment from existing instances.

On existing environment needs to enable 5986 port on firewall and enable WiRM service.


#Change the directory wth environment
cd sandbox
terraform init
#Add the credentals for terraform as a local bash variables
export AWS_ACCESS_KEY_ID=*********
export AWS_SECRET_ACCESS_KEY=******
terraform apply


#Destroy only instances amd AMI images, not all the infrastructure!
terraform destroy -target=aws_instance.DB_sandbox -target=aws_instance.Web_sandbox -target=aws_ami_from_instance.DB-AMI -target=aws_ami_from_instance.Web-AMI


To create a lambda functin wich wll create AMI snapshots everyning you sholuld

cd AWS-Automated-AMI-FROM-EC2/
serverless deploy

Note: This function will automaicaly crete AMI accorfing the scheduller in serverless.yml






