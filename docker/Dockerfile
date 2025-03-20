FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /SimpleHttpServer

# Copy everything
COPY . ./
RUN dotnet restore
RUN dotnet publish -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /SimpleHttpServer
COPY --from=build /SimpleHttpServer/out .
ENTRYPOINT ["dotnet", "SimpleHttpServer.dll"]