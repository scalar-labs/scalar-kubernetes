cassandra = {
  start_on_initial_boot = true
}

cassy = {
  resource_root_volume_size = "16"
  use_managed_identity      = "false"
  storage_base_uri          = "https://yourstorageaccountname.blob.core.windows.net/your-container-name"
}
