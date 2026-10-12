output "k8s_cluster_id" {
  value = yandex_kubernetes_cluster.ufilin_k8s_cluster.id
}

output "mysql_address" {
  value = "c-${yandex_mdb_mysql_cluster.my_sql.id}.rw.mdb.yandexcloud.net"
}