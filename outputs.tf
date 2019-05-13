output "app_domain" {
   value = ["${google_dns_record_set.eschool_app_subdomain.name}"]
}

output "public_ip_ciserver" {
   value = ["${google_compute_instance.ciserver.*.network_interface.0.access_config.0.nat_ip}"]
}

output "public_ip_sql" {
   value = ["${google_sql_database_instance.instance.ip_address.0.ip_address}"]
}

output "lb_public_ip" {
   value = ["${google_compute_global_address.my_global_address.*.address}"]
}
