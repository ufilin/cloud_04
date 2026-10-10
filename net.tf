## Create networks

resource "yandex_vpc_network" "net" {
  name = "net"
}

resource "yandex_vpc_subnet" "public" {
  for_each       = var.public_subnets
  name           = each.key
  zone           = each.value.zone
  network_id     = yandex_vpc_network.net.id
  v4_cidr_blocks = [each.value.v4_cidr]
}

resource "yandex_vpc_subnet" "private" {
  for_each       = var.private_subnets
  name           = each.key
  zone           = each.value.zone
  network_id     = yandex_vpc_network.net.id
  v4_cidr_blocks = [each.value.v4_cidr]
}