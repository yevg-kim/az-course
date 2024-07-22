using Azure.Identity;
using Azure.Storage.Blobs;
using Microsoft.Extensions.DependencyInjection;
using MongoDB.Driver;

namespace ReserveFunctionApp.Extensions;
public static class ServiceCollectionExtentions
{
    public static IServiceCollection AddBlobContainerClient(this IServiceCollection collection, string? connectionString)
    {
        return collection.AddSingleton(new BlobServiceClient(connectionString)
                .GetBlobContainerClient("reserves"));
    }

    public static IServiceCollection AddMongoDBClient(this IServiceCollection collection, string? connectionString, string? database)
    {
        return collection.AddSingleton(new MongoClient(connectionString).GetDatabase(database));
    }
}
