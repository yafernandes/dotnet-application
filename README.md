# Simple HTTP Server

Build the image with the command below:

```bash
docker buildx build --push -t <IMAGE> \
    --platform linux/amd64,linux/arm64 \
    -f docker/Dockerfile .
```
