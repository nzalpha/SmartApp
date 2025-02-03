# Creating a VPC
resource "google_compute_network" "tf-vpc" {
  name = var.vpc_name
  auto_create_subnetworks = false
}

# Creating a subnet in us-central1
resource "google_compute_subnetwork" "tf-subnet" {
    name = "${var.vpc_name}-subnet"
    network = google_compute_network.tf-vpc.name
    region = var.region
    ip_cidr_range = var.cidr
}

# Creating Firewall for the VPC
resource "google_compute_firewall" "tf-allow-ports" {
  name = var.firewall_name
  network = google_compute_network.tf-vpc.name
  dynamic "allow" {
    for_each = var.ports
    content {
       protocol = "tcp"
       ports    = [allow.value]
    }
  }
  source_ranges = ["0.0.0.0/0"]
}

# Generating SSH Key Pair through tls_private_key (Resource) it Creates a pvt and public key but its not saved anywhere
resource "tls_private_key" "ssh-keys" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Saving the the private key to a local file using local_file resource 
resource "local_file" "private_key" {
  content  = tls_private_key.ssh-keys.private_key_pem
  filename = "${path.module}/id_rsa" # saving in the current working directory

}
# Save the Pub key to a local file
resource "local_file" "public_key" {
  content  = tls_private_key.ssh-keys.public_key_openssh
  filename = "${path.module}/id_rsa_pub" # saving in the current working directory

}

# Creating Compute Engine Instance which are needed for infra
resource "google_compute_instance" "tf-vm-instances" {
  for_each = var.instances
  name = each.key
  zone = each.value.zone
  machine_type = each.value.instance_type
  tags = [each.key]
 

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20240519"
      size = 10
      type = "pd-balanced"

    }
    
  }
  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }
    subnetwork = google_compute_subnetwork.tf-subnet.name
    network = google_compute_network.tf-vpc.name
  }

 # Connection block to help us connect to vm via ssh

 connection {
   type = "ssh"
   user = var.vm_user
   host = self.network_interface[0].access_config[0].nat_ip
   private_key = tls_private_key.ssh-keys.private_key_pem
 }

 # You also need to store the public key in the metadata of the project id

  metadata = {
    ssh-keys = "${var.vm_user}:${tls_private_key.ssh-keys.public_key_openssh}"
  }

  # Provisioner to run commands or scripts. Based on the tag of the vm I want to execute the script. 
  #For ansible vm i need to run ansible.sh to install ansible

provisioner "file" {
  # If ansible execuste ansible.sh, else exe other.sh
  source = each.key == "ansible" ? "ansible.sh" : "other.sh"
  #copy the file in the vm home directory
  destination = each.key == "ansible" ? "/home/${var.vm_user}/ansible.sh" : "/home/${var.vm_user}/other.sh" 
}

provisioner "file" {
  # If ansible execuste ansible.sh, else exe other.sh
  source = "${path.module}/id_rsa"
  #copy the pvt file in the vm home directory
  destination = "/home/${var.vm_user}/ssh-key"
}


# We have copied the ansible script and now we need to execute it.

provisioner "remote-exec" {
    inline = [ 
        each.key == "ansible" ? "chmod +x /home/${var.vm_user}/ansible.sh && sh /home/${var.vm_user}/ansible.sh" : "echo Skipping the command"
     ]
  
}


}