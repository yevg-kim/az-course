using BlazorShared.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using MongoDB.Bson;
using MongoDB.Driver;

namespace Azcourse.Functions
{
    public class OrderTrigger
    {
        private readonly ILogger<OrderTrigger> _logger;
        private readonly IMongoDatabase _databaseClient;

        private readonly string _collectionName = "orders";

        public OrderTrigger(ILogger<OrderTrigger> logger, IMongoDatabase client)
        {
            _logger = logger;
            _databaseClient = client;

            if (!CollectionExists(client, _collectionName))
                _databaseClient.CreateCollection(_collectionName);
        }

        
        [Function(nameof(OrderTrigger))]
        public async Task<IActionResult> RunOrder([HttpTrigger(AuthorizationLevel.Function, "post", Route = "order")] HttpRequest req)
        {
            var requestBody = await req.ReadFromJsonAsync<OrderSubmitRequest>();

            await _databaseClient
                .GetCollection<BsonDocument>(_collectionName)
                .InsertOneAsync(requestBody.ToBsonDocument());

            return new CreatedResult();
        }

        private bool CollectionExists(IMongoDatabase databaseClient, string collectionName) =>
            databaseClient
                .ListCollectionNames(new ListCollectionNamesOptions { Filter = new BsonDocument("name", collectionName) })
                .Any();
    }
}
