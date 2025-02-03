# Display the VM's Public & Private IP

output "instance_ips" {
    value = {
        for instance in google_compute_instance.tf-vm-instances :
        instance.name => {
            #The expression instance.name => { ... } inside the Terraform for loop is creating a map (key-value pair) where:
            #instance.name acts as the key (the unique identifier for each instance).
            # The { ... } block contains values (private and public IPs in this case).


            private_ip = instance.network_interface[0].network_ip  # network ip is pvt ip https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance
            public_ip = instance.network_interface[0].access_config[0].nat_ip
        }
    }
  
}