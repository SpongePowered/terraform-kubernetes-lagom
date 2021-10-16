variable "app_name" {
  type = string
  description = "The name of this lagom service application"
  validation {
    condition = trim(var.app_name) != ""
    error_message = "The configured app_name cannot be an empty string!"
  }
}

variable "lagom_service_name" {
  type = string
  description = "The name of the Lagom Service Descriptor, used for service mapping exposure to other applications"
  validation {
    condition = trim(var.lagom_service_name) != ""
    error_message = "The Service Descriptor cannot be empty string!"
  }
}
variable "app_image" {
  type = string
  description = "The image to use to deploy, including version"
  validation {
    condition = var.app_image != ""
    error_message = "The configured app_image needs to be present."
  }
}

variable "app_version" {
  type = string
  description = "The image version"
}
variable "environment" {
  type = string
}

variable "namespace" {
  type = string
}

variable "replica_count" {
  type = number
  default = 2
  description = "The count of replicas to make"

  validation {
    condition = var.replica_count > 0 && var.replica_count <= 110
    error_message = "The replica count must be a number between 1 and 110 per k8s specification of pod counts."
  }
}

variable "required_availability" {
  type = number
  default = 2
  description = "The required availability for Akka-Clustering to take place. Recommended to match replica-count according to Akka Clustering docs: https://doc.akka.io/docs/akka-management/current/bootstrap/index.html#exact_contact_point"
  validation {
    condition = var.required_availability >= 1
    error_message = "The required availability counts must be greater than 0 or less than or equal to the configured replica count."
  }
}

variable "play_secret_key" {
  type = string
  sensitive = true
  default = "play_secret_key"

  validation {
    condition = length(var.play_secret_key) >= 16
    error_message = "Play Framework requirements specify the secret key in production will need to be greater than 16 characters."
  }
}

variable "extra_config" {
  type = string
  default = ""
}

variable "extra_envs" {
  type = map(object({
    value = string
  }))
  default = {}
  description = "Extra environment variables to set by key value map. Useful for your application specific configurations"
}
variable "extra_secret_envs" {
  type = map(object({
    name = string
    key = string
  }))
  default = {}
  description = "Secret based environment variables where the map key is the environment name and the name of the secret with the key of the secret data blob."
}

variable "extra_java_opts" {
  type = string
  default = ""
  description = "Extra JVM options to starting the service with. Raw formatted interpolated into the options directly. "
}

variable "kafka_config" {
  type = object({
    service_name = string
    port_protocol = string
    port_name = string
  })
  default = {
    service_name = "lagom-kafka-kafka-brokers"
    port_protocol = "_tcp"
    port_name = "_tcp_clients"
  }
}

variable "extra_ports" {
  type = list(object({
    name = string
    port = number
    protocol = string
  }))
  default = []
}

variable "kafka_topics" {
  type = map(object({
    topic = string
  }))
  default = {}
}

variable "encryption_key" {
  type = string
  sensitive = true
}

variable "signature_key" {
  type = string
  sensitive = true
}

variable "extra_labels" {
  type = map(string)
  default = {}
}

variable "image_pull_policy" {
  type = string
  default = "Always"
  description = "The image pull policy for k8s"
  validation {
    condition = var.image_pull_policy == "Always" || var.image_pull_policy == "IfNotPresent" || var.image_pull_policy == "Never"
    error_message = "Kubernetes image pull policy does not match known values. Should be one of \"Always\", \"IfNotPresent\", or \"Never\"."
  }
}

variable "akka_http_port" {
  type = number
  default = 8080
  validation {
    condition = var.akka_http_port > 1000 && var.akka_http_port < 30000
    error_message = "Akka http port for application must be lower than default node-port ranges."
  }
}

variable "akka_management_port" {
  type = number
  default = 8558
}

variable "akka_management_port_name" {
  type = string
  default = "management"
}

variable "deployment_annotations" {
  type = map(string)
  default = {}
  description = "Deployment metadata annotations"
}

variable "enable_istio_annotations" {
  type = bool
  default = false
  description = "Istio annotations required on deployments to enable Akka-Clustering to take place. The annotations enable Akka-Cluster communication to bypass Istio's sidecar proxy."
}

variable "dependent_lagom_service_mappings" {
  type = list(string)
  description = ""
}

variable "cpu_limit" {
  type = string
  description = "The cpu limit allowed for the lagom application container"
  default = "1000m"
}

variable "mem_limit" {
  type = string
  description = "The memory limit allowed for the lagom application container. When using Java 11+ based images, the JVM will detect the upper memory limit and adjust the relative size available. See "
  default = "750Mi"
}

variable "kube_config" {
  type = string
}
