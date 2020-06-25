base = "default" # bai, chiku, sho

cassandra = {
  # resource_type                 = "Standard_B2ms"
  # resource_count                = "3"
  # resource_root_volume_size     = "64"
  # enable_data_volume            = "false"
  # data_use_local_volume         = "false"
  # data_remote_volume_size       = "64"
  # enable_commitlog_volume       = "false"
  # commitlog_use_local_volume    = "false"
  # commitlog_remote_volume_size  = ""
  # memtable_threshold            = "0.33"
  # data_remote_volume_type       = "Premium_LRS"
  # commitlog_remote_volume_type  = "Premium_LRS"
  # enable_tdagent                = "true"
  # start_on_initial_boot         = "false"
  # enable_accelerated_networking = "false"
}

cassy = {
  # image_tag                     = "1.2.0"
  # resource_type                 = "Standard_B2s"
  # resource_count                = "1"
  # resource_root_volume_size     = "64"
  # enable_tdagent                = "true"
  # enable_accelerated_networking = "false"
  # use_managed_identity          = "true"

  # Required if use_managed_identity = "true" and resource_count > 0
  storage_base_uri = "https://yourstorageaccountname.blob.core.windows.net/your-container-name"
  storage_type     = "azure_blob"
}

reaper = {
  # resource_type                 = "Standard_B2s"
  # resource_root_volume_size     = "64"
  # replication_factor            = "3"
  # resource_count                = "1"
  # enable_tdagent                = "true"
  # cassandra_username            = ""
  # cassandra_password            = ""
  # enable_accelerated_networking = "false"
}
