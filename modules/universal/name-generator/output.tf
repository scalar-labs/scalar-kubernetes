output "name" {
  value = "${lower(var.name)}-${replace(lower(random_id.id.b64_url), "_", "")}"
}

