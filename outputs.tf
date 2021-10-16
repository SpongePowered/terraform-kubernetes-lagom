output "lagom_akka_discovery_mapping" {
  value = <<EOF
${var.lagom_service_name} {
  lookup = ${var.app_name}.${var.namespace}.svc.cluster.local
}
EOF
}

output "lagom_akka_k8s_svc_name" {
  depends_on = [kubernetes_service.lagom-service]
  value = kubernetes_service.lagom-service.metadata[0].name
}

output "lagom_k8s_deployment" {
  value = kubernetes_deployment.lagom-instances
}
