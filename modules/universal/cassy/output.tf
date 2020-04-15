
output "public_key" {
  value = tls_private_key.cassy_private_key.public_key_openssh
}
