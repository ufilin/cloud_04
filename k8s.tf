resource "yandex_iam_service_account" "ufilin_service_account" {
  name        = "k8s-service-account"
  description = "Service account for ufilin project"
}

resource "yandex_resourcemanager_folder_iam_member" "ufilin_service_account_member" {
  folder_id = var.folder_id
  for_each  = toset(var.role)
  role      = each.value
  member    = "serviceAccount:${yandex_iam_service_account.ufilin_service_account.id}"
}


resource "yandex_kubernetes_cluster" "ufilin_k8s_cluster" {
  name               = "ufilin-k8s-cluster"
  description        = "Kubernetes cluster for ufilin project"
  service_account_id = yandex_iam_service_account.ufilin_service_account.id
  depends_on         = [yandex_resourcemanager_folder_iam_member.ufilin_service_account_member]
  folder_id          = var.folder_id
  network_id         = yandex_vpc_network.net.id


  master {
    version   = "1.35"
    public_ip = true
    regional {
      region = "ru-central1"
      dynamic "location" {
        for_each = var.public_subnets
        content {
          zone      = location.value.zone
          subnet_id = yandex_vpc_subnet.public[location.key].id
        }
      }
    }
    maintenance_policy {
      auto_upgrade = true
    }
  }

  node_service_account_id = yandex_iam_service_account.ufilin_service_account.id

  kms_provider {
    key_id = yandex_kms_symmetric_key.ufilin_kms_key.id
  }
}

resource "yandex_kubernetes_node_group" "ufilin_k8s_node_group" {
  cluster_id  = yandex_kubernetes_cluster.ufilin_k8s_cluster.id
  name        = "ufilin-node-group"
  description = "Node group for ufilin project"
  version     = "1.35"

  instance_template {
    name = "ufilin-{instance.short_id}-{instance_group.id}"
    container_runtime {
      type = "containerd"
    }
    resources {
      memory        = var.vms_resources.memory
      cores         = var.vms_resources.cores
      core_fraction = var.vms_resources.core_fraction
    }
    boot_disk {
      type = var.vms_resources.boot_disk.type
      size = var.vms_resources.boot_disk.size
    }
    network_acceleration_type = "standard"
    network_interface {
      subnet_ids = [yandex_vpc_subnet.public["public1"].id]
      nat        = true
    }
    scheduling_policy {
      preemptible = true
    }
  }

  allocation_policy {
    location {
      zone = yandex_vpc_subnet.public["public1"].zone
    }
  }
  scale_policy {
    auto_scale {
      min     = 3
      max     = 6
      initial = 3
    }
  }

}