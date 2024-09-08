using System.Text;
using System.Text.Json;
using Azure.Messaging.ServiceBus;
using Azure.Storage.Blobs;
using BlazorShared;
using BlazorShared.Models;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace Azcourse.Functions
{
    public class ReserveTrigger
    {
        private readonly ILogger<ReserveTrigger> _logger;
        private readonly BlobContainerClient _blobContainerClient;
        private readonly AzureServiceBusConfiguration _serviceBusConfiguration;
        public ReserveTrigger(ILogger<ReserveTrigger> logger, BlobContainerClient blobContainerClient, IOptions<AzureServiceBusConfiguration> configuration)
        {
            _logger = logger;
            _blobContainerClient = blobContainerClient;
            _serviceBusConfiguration = configuration.Value;

            if (!_blobContainerClient.Exists())
                _blobContainerClient.Create();
        }

        [Function(nameof(ReserveTrigger))]
        public async Task RunReserveServiceBus([ServiceBusTrigger("%QueueName%")] ServiceBusReceivedMessage message, 
            ServiceBusMessageActions messageActions)
        {
            try
            {
                var requestBody = JsonSerializer.Deserialize<OrderReserveRequest>(message.Body);
                if (requestBody is null || requestBody.ItemId <= 0 || requestBody.Quantity <= 0)
                {
                    _logger.LogInformation("Bad body provided: {body}", message.Body);
                    return;
                }
                
                string fileName = $"{DateTime.Now.ToString("MM-dd-yyyy")}/reserve-{requestBody!.ItemId}-{Guid.NewGuid()}.txt";
                BlobClient blobClient = _blobContainerClient.GetBlobClient(fileName);
                var data = Encoding.ASCII.GetBytes(requestBody!.ToString());
                await blobClient.UploadAsync(new BinaryData(data));
                _logger.LogInformation("Uploaded blob {blobName} to container 'reserves'", fileName);

                await messageActions.CompleteMessageAsync(message);
            }
            catch (Exception e)
            {
                _logger.LogError("Failed to process order reserve message {correlationId}. Error: {error}", message.CorrelationId, e.Message);
                throw;
            }
        }
    }
}
