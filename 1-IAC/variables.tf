variable "projectId" {
  default = "smart-k8"
}

variable "region" {
  default = "us-central1"
}

variable "vpc_name" {
  default = "smart-k8-vpc"
}

variable "cidr" {
    default =   "10.1.0.0/16"
}

variable "firewall_name" {
   default = "smart-firewall"
}

variable "ports"{
    default = [80,8080,8081,9000,22]
}

variable "instances" {
    default = {
        "jenkins-master" = {
            instance_type= "e2-medium"
            zone = "us-central1-a"
        }

        "jenkins-slave" = {
            instance_type= "e2-medium"
            zone = "us-central1-a"
        }	


        "ansible" = {
            instance_type= "e2-medium"
            zone = "us-central1-a"
        }

        "docker" = {
            instance_type= "e2-medium"
            zone = "us-east1-b"
        }

        
    }
}

variable "vm_user"{
    default = "zain"
}
  
variable "database_password" {
    type = string
    sensitive = true
  
}
