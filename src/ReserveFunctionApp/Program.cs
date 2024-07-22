using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.DependencyInjection;
using AzureFunctions.MongoDBDriver;
using ReserveFunctionApp.Extensions;

var host = new HostBuilder()
    .ConfigureFunctionsWebApplication()
    .ConfigureServices(services => {
        services
            .AddApplicationInsightsTelemetryWorkerService()
            .ConfigureFunctionsApplicationInsights()
            .AddBlobContainerClient(Environment.GetEnvironmentVariable("AzureWebJobsStorage"))
            .AddMongoDBClient(Environment.GetEnvironmentVariable("COSMOSDB_CONNECTION_STRING"),
                              Environment.GetEnvironmentVariable("COSMOSDB_DATABASE"));
    })
    .Build();

host.Run();
