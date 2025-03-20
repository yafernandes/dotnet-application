using Serilog;
using Serilog.Formatting.Json;

using Serilog.Context;

using System;
using System.Threading;
using System.Collections;

var log = new LoggerConfiguration()
    .WriteTo.Console()
    .CreateLogger();

var logJSON = new LoggerConfiguration()
    .WriteTo.Console(new JsonFormatter())
    .CreateLogger();

log.Information("Starting Simple HTTP Server");
logJSON.Information("Starting Simple HTTP Server");

var builder = WebApplication.CreateBuilder(args);
var config = builder.Configuration;

var app = builder.Build();

Random random = new Random();

app.MapGet("/", () => "Hello, this is a response from your HTTP server!");

app.MapGet("/greet/{name}", (string name) => $"Hello, {name}!");

app.MapPost("/echo", async (HttpContext context) =>
{
    using var reader = new StreamReader(context.Request.Body);
    var requestBody = await reader.ReadToEndAsync();
    return Results.Json(new { message = $"You sent: {requestBody}" });
});

app.MapGet("/logging/text", (HttpContext context) =>
{
    log.Information("Logging from a request from the logging endpoint");
    int randomNumber = random.Next(1000, 9999);
    return Results.Json(new { message = $"Here is your random number: {randomNumber}" });
});

app.MapGet("/logging/json", (HttpContext context) =>
{
    logJSON.Information("Logging from a request from the JSON logging endpoint");
    int randomNumber = random.Next(1000, 9999);
    return Results.Json(new { message = $"Here is your random number: {randomNumber}" });
});

app.MapGet("/version", (HttpContext context) =>
{
    string? version = config["DD_VERSION"];
    logJSON.Information($"This is version {version}");
    return Results.Json(new { message = $"Server version {version}" });
});

app.MapGet("/environment", (HttpContext context) =>
{
    var envVars = Environment.GetEnvironmentVariables();
    var dictionary = new Dictionary<string, string>();

    foreach (DictionaryEntry entry in envVars)
    {
        dictionary[entry.Key.ToString()] = entry.Value?.ToString();
    }
    return Results.Json(dictionary.OrderBy(kvp => kvp.Key).ToDictionary(kvp => kvp.Key, kvp => kvp.Value));
});

Timer _timer = new Timer(Heartbeat, null, TimeSpan.Zero, TimeSpan.FromSeconds(1));

app.Run();

void Heartbeat(object? state)
{
    logJSON.ForContext("heartbeatTS", DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()).Information("Heartbeat");
}
