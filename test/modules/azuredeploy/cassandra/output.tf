output "cassandra_resource_count" {
  value = module.cassandra.cassandra_resource_count
}

output "cassandra_provision_ids" {
  value = module.cassandra.cassandra_provision_ids
}

output "cassandra_start_on_initial_boot" {
  value = module.cassandra.cassandra_start_on_initial_boot
}

output "cassandra_test_ip_0" {
  value = module.cassandra.cassandra_host_ips[0]
}

output "cassandra_test_ip_1" {
  value = module.cassandra.cassandra_host_ips[1]
}
