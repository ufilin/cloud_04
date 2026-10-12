###cloud vars
variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "vms_resources" {
  type = object({
    cores         = number
    memory        = number
    core_fraction = number
    boot_disk = object({
      type = string
      size = number
    })
  })

  default = {
    cores         = 2
    memory        = 2
    core_fraction = 50
    boot_disk = {
      type = "network-hdd"
      size = 20
    }
  }
}


variable "private_subnets" {
  type = map(object({
    zone    = string
    v4_cidr = string
  }))
  default = {
    private1 = { zone = "ru-central1-a", v4_cidr = "192.168.20.0/24" }
    private2 = { zone = "ru-central1-e", v4_cidr = "192.168.30.0/24" }
    private3 = { zone = "ru-central1-d", v4_cidr = "192.168.40.0/24" }
  }
  description = "Private subnets for the VPC network"
}

variable "public_subnets" {
  type = map(object({
    zone    = string
    v4_cidr = string
  }))
  default = {
    public1 = { zone = "ru-central1-a", v4_cidr = "192.168.10.0/24" }
    public2 = { zone = "ru-central1-e", v4_cidr = "192.168.11.0/24" }
    public3 = { zone = "ru-central1-d", v4_cidr = "192.168.12.0/24" }
  }
  description = "Public subnets for the VPC network"
}

variable "db_password" {
  type        = string
  description = "Password for the MySQL database user"
  sensitive   = true
}

variable "role" {
  type        = list(string)
  description = "List of IAM roles for the service account"
  default = [
    "container-registry.images.puller",
    "kms.keys.encrypterDecrypter",
    "load-balancer.admin",
    "k8s.clusters.agent",
    "vpc.publicAdmin"
  ]
}