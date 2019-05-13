data "template_file" "jenkins_conf" {
  template = "${file("${path.module}/templates/jenkins.plugins.publish_over_ssh.BapSshPublisherPlugin.tpl")}"
  vars {
    web0_server = "${element(google_compute_instance.ciserver.*.network_interface.0.network_ip, count.index)}"
    web1_server = "localhost"
  }
}

data "template_file" "app_conf" {
  template = "${file("${path.module}/templates/application.properties.tpl")}"
  depends_on = ["google_sql_database_instance.instance"]
  vars {
  # db_server = "${google_sql_database_instance.instance.ip_address.0.ip_address}"
    db_server = "localhost"
    db_name = "${var.db_name}"
    db_user = "${var.user_name}"
    db_pass = "${var.user_password}"
  }
}

data "template_file" "job_frontend" {
  template = "${file("${path.module}/templates/job_frontend.tpl")}"
  vars {
    key = "${var.key}"
    key_view = "${var.key_view}"
    project = "${var.project}"
  # lb_backend = "${google_dns_record_set.eschool_app_subdomain.name}"
    lb_backend = "${google_compute_global_address.my_global_address.address}"
  }
}

data "template_file" "deploy_frontend" {
  template = "${file("${path.module}/ansible/kubernetes/deployment-frontend.yml")}"
  vars {
    project = "${var.project}"
  }
}

data "template_file" "job_backend" {
  template = "${file("${path.module}/templates/job_backend.tpl")}"
  vars {
    key = "${var.key}"
    key_sql = "${var.key_sql}"
    key_view = "${var.key_view}"
    project = "${var.project}"
    user_name = "${var.user_name}"
    user_password = "${var.user_password}"
  }
}

data "template_file" "deploy_backend" {
  template = "${file("${path.module}/ansible/kubernetes/deployment-backend.yml")}"
  vars {
    project = "${var.project}"
    region = "${var.region}"
    db_instance_name = "${google_sql_database_instance.instance.name}"
  }
}

data "template_file" "ingress_eschool" {
  template = "${file("${path.module}/ansible/kubernetes/ingress-eschool.yml")}"
  vars {
    lb_backend = "${google_dns_record_set.eschool_app_subdomain.name}"
    static_ip = "${google_compute_global_address.my_global_address.address}"
  }
}

data "template_file" "service_lb" {
  template = "${file("${path.module}/ansible/kubernetes/service-lb.yml")}"
  vars {
    static_ip = "${google_compute_global_address.my_global_address.address}"
  }
}