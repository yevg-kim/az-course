using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.DependencyInjection;
using AzureFunctions.MongoDBDriver;
using ReserveFunctionApp.Extensions;
using BlazorShared;

var host = new HostBuilder()
    .ConfigureFunctionsWebApplication()
    .ConfigureServices(services => {
        services
            .AddApplicationInsightsTelemetryWorkerService()
            .ConfigureFunctionsApplicationInsights()
            .AddBlobContainerClient(Environment.GetEnvironmentVariable("AzureWebJobsStorage"))
            .AddMongoDBClient(Environment.GetEnvironmentVariable("COSMOSDB_CONNECTION_STRING"),
                              Environment.GetEnvironmentVariable("COSMOSDB_DATABASE"))
            .Configure<AzureServiceBusConfiguration>(config => config.FullConnectionString = Environment.GetEnvironmentVariable("AzureWebJobsServiceBus") ?? "");
    })
    .Build();

host.Run();
