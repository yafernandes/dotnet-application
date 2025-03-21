# Simple HTTP Server

This repository aims to showcase a .NET application running on [Azure Container Apps](https://azure.microsoft.com/en-us/products/container-apps) with full observability, highlighting a streamlined and scalable approach to application deployment.

We took an alternative approach to [Datadog’s official documentation](https://docs.datadoghq.com/serverless/azure_container_apps/?tab=net), opting instead for a more standard method of handling application logs via Datadog’s Azure integration using Azure Functions. We've observed that logs can take **up to 10 minutes** to reach our Azure Function, which introduces a significant delay in log ingestion.

The application's instrumentation is based on Datadog’s approach to auto-instrumenting applications in Kubernetes deployments using [init containers](https://learn.microsoft.com/en-us/azure/container-apps/containers#init-containers).

## Build

Build the image with the command below:

```bash
docker buildx build --push -t <IMAGE> \
    --platform linux/amd64,linux/arm64 \
    -f docker/Dockerfile .
```
