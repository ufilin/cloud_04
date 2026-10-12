resource "yandex_mdb_mysql_cluster" "my_sql" {
  name        = "mysql-cluster"
  environment = "PRESTABLE"
  network_id  = yandex_vpc_network.net.id
  version     = "8.0"
  resources {
    disk_size          = 20
    disk_type_id       = "network-hdd"
    resource_preset_id = "c3-c2-m4"
  }

  dynamic "host" {
    for_each = yandex_vpc_subnet.private
    content {
      zone      = host.value.zone
      subnet_id = host.value.id
    }
  }
  maintenance_window {
    type = "ANYTIME"
  }

  backup_retain_period_days = 7
  deletion_protection       = true

  backup_window_start {
    hours   = 23
    minutes = 59
  }
}
resource "yandex_mdb_mysql_database" "my_sql_db" {
  cluster_id = yandex_mdb_mysql_cluster.my_sql.id
  name       = "netology_db"
}
resource "yandex_mdb_mysql_user" "my_sql_user" {
  cluster_id = yandex_mdb_mysql_cluster.my_sql.id
  name       = "netology_user"
  password   = var.db_password
  permission {
    database_name = yandex_mdb_mysql_database.my_sql_db.name
    roles         = ["ALL"]
  }
}

