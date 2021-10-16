resource "kubernetes_service" "lagom-service" {
  metadata {
    name = var.app_name
    labels = {
      app = var.app_name
      "prometheus.io/scrape" = false
      environment = var.environment
    }
    namespace = var.namespace
  }
  spec {
    port {
      name = local.http_endpoint_name
      port = 80
      target_port = local.http_endpoint_name
    }
    selector = {
      app = var.app_name
      environment = var.environment
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "lagom-instances" {
  metadata {
    labels = merge(var.extra_labels, {
      app = var.app_name
      environment = var.environment
    })
    name = var.app_name
    namespace = var.namespace
  }
  spec {
    selector {
      match_labels = {
        app = var.app_name
        environment = var.environment
      }
    }
    strategy {
      rolling_update {
        max_surge = "1"
        max_unavailable = "0"
      }
      type = "RollingUpdate"
    }
    replicas = var.replica_count
    template {
      metadata {
        labels = merge(var.extra_labels, {
          app = var.app_name
          environment = var.environment
          version = var.app_version
        })
        name = var.app_name
        annotations = var.deployment_annotations
      }
      spec {
        service_account_name = kubernetes_service_account.akka-cluster-instance.metadata[0].name
        container {
          name = var.app_name
          image = var.app_image
          image_pull_policy = var.image_pull_policy

          resources {
            requests = {
              cpu = "100m"
              memory = "200Mi"
            }
            limits = {
              cpu = var.cpu_limit
              memory = var.mem_limit
            }
          }
          dynamic "env" {
            for_each = var.extra_envs
            content {
              name = env.key
              value = env.value.value
            }
          }
          dynamic "env" {
            for_each = var.extra_secret_envs
            content {
              name = env.key
              value_from {
                secret_key_ref {
                  name = env.value.name
                  key = env.value.key
                }
              }
            }
          }
          env {
            name = "AKKA_CLUSTER_BOOTSTRAP_SERVICE_NAME"
            value = var.app_name
          }

          env {
            name = "JAVA_OPTS"
            value = "-XX:+UnlockExperimentalVMOptions -Dconfig.file=${local.config_dir}/${local.config_file} ${var.extra_java_opts}"
          }
          env {
            name = "APPLICATION_SECRET"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.play_secret.metadata[0].name
                key = var.play_secret_key
              }
            }
          }
          env {
            name = local.kafka_service_env
            value = local.kafka_port
          }
          env {
            name = "HTTP_BIND_ADDRESS"
            value = "0.0.0.0"
          }

          startup_probe {
            http_get {
              path = "health/alive"
              port = var.akka_management_port_name
            }
            failure_threshold = 30
            period_seconds = 10
          }
          liveness_probe {
            http_get {
              path = "health/alive"
              port = var.akka_management_port_name
            }
            initial_delay_seconds = 20
            failure_threshold = 1
            success_threshold = 1
            period_seconds = 5
          }
          readiness_probe {
            http_get {
              port = var.akka_management_port_name
              path = "health/ready"
            }
            initial_delay_seconds = 20
            period_seconds = 5
            success_threshold = 1
            failure_threshold = 3
          }
          port {
            name = "remoting"
            container_port = 2552
            protocol = "TCP"
          }
          port {
            name = var.akka_management_port_name
            container_port = 8558
            protocol = "TCP"
          }
          port {
            name = local.http_endpoint_name
            container_port = 9000
            protocol = "TCP"
          }

          dynamic "port" {
            for_each = var.extra_ports
            content {
              name = port.value.name
              container_port = port.value.port
              protocol = port.value.protocol
            }
          }

          volume_mount {
            mount_path = local.config_dir
            name = "application-${var.app_name}-config"
            read_only = true
          }
        }
        volume {
          name = "application-${var.app_name}-config"
          secret {
            secret_name = kubernetes_secret.lagom_application_config.metadata[0].name
          }
        }
      }
    }
  }
}

