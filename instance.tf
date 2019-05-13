resource "google_compute_instance" "ciserver" {
  name         = "ciserver"
  machine_type = "${var.machine_type_ciserver}"
  tags = ["ssh","sonar"]
  

  boot_disk {
    initialize_params {
      image = "${var.image}"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.private_subnetwork.name}"
    access_config = {
      }
  }
   metadata {
    sshKeys = "centos:${file("${var.public_key_path}")}"
   }

   metadata_startup_script = <<SCRIPT
sudo yum -y update
sudo yum -y install epel-release
sudo yum -y install ansible
sudo yum -y install mc
sudo yum -y install htop
sudo yum -y install nano
SCRIPT
}

