resource "azurerm_container_app" "app" {
  name                         = var.project
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = data.azurerm_resource_group.main.name
  revision_mode                = "Single"

  ingress {
    external_enabled           = true
    target_port                = 8080
    allow_insecure_connections = true

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  template {
    volume {
      name         = "auto-instrumentation"
      storage_type = "EmptyDir"
    }

    init_container {
      name    = "datadog-lib-dotnet-ini"
      image   = "datadog/dd-lib-dotnet-init:latest"
      command = ["/bin/sh", "-c", "--"]
      args    = ["sh copy-lib.sh /datadog-lib"]
      cpu    = 0.25
      memory = "0.5Gi"

      volume_mounts {
        name = "auto-instrumentation"
        path = "/datadog-lib"
      }
    }

    # https://docs.datadoghq.com/serverless/azure_container_apps?tab=net#sidecar-container
    container {
      name   = "datadog"
      image  = "datadog/serverless-init:latest"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "DD_AZURE_SUBSCRIPTION_ID"
        value = data.azurerm_client_config.current.subscription_id
      }
      env {
        name  = "DD_AZURE_RESOURCE_GROUP"
        value = data.azurerm_resource_group.main.name
      }
      env {
        name  = "DD_API_KEY"
        value = var.dd_api_key
      }
    }

    container {
      name   = "simple-http-server"
      image  = var.image
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "CORECLR_ENABLE_PROFILING"
        value = "1"
      }
      env {
        name  = "CORECLR_PROFILER"
        value = "{846F5F1C-F9AE-4B07-969E-05C26BC060D8}"
      }
      env {
        name  = "CORECLR_PROFILER_PATH"
        value = "/opt/datadog/apm/library/Datadog.Trace.ClrProfiler.Native.so"
      }
      env {
        name  = "DD_DOTNET_TRACER_HOME"
        value = "/opt/datadog/apm/library"
      }
      env {
        name  = "DD_LOGS_INJECTION"
        value = "true"
      }
      env {
        name  = "DD_SERVICE"
        value = "simplehttpserver"
      }
      env {
        name  = "DD_VERSION"
        value = "0.0.2"
      }

      volume_mounts {
        name = "auto-instrumentation"
        path = "/opt/datadog/apm/library"
      }
    }
  }
}
