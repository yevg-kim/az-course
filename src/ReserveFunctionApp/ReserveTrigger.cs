using System.Text;
using Azure.Storage.Blobs;
using BlazorShared.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace Azcourse.Functions
{
    public class ReserveTrigger
    {
        private readonly ILogger<ReserveTrigger> _logger;
        private readonly BlobContainerClient _blobContainerClient;
        public ReserveTrigger(ILogger<ReserveTrigger> logger, BlobContainerClient blobContainerClient)
        {
            _logger = logger;
            _blobContainerClient = blobContainerClient;

            if (!_blobContainerClient.Exists())
                _blobContainerClient.Create();
        }

        [Function(nameof(ReserveTrigger))]
        public async Task<IActionResult> RunReserve([HttpTrigger(AuthorizationLevel.Function, "post", Route = "reserve")] HttpRequest req)
        {
            var requestBody = await req.ReadFromJsonAsync<OrderReserveRequest>();
            if (requestBody is null || requestBody.ItemId <= 0 || requestBody.Quantity <= 0) {
                _logger.LogInformation("Bad body provided: {body}", req.Body);
                return new BadRequestResult();
            }

            string fileName = $"{DateTime.Now.ToString("MM-dd-yyyy")}/reserve-{requestBody!.ItemId}-{Guid.NewGuid()}.txt";
            BlobClient blobClient = _blobContainerClient.GetBlobClient(fileName);
            var data = Encoding.ASCII.GetBytes(requestBody!.ToString());
            await blobClient.UploadAsync(new BinaryData(data));
            _logger.LogInformation("Uploaded blob {blobName} to container 'reserves'", fileName);
            return new CreatedResult();
        }
    }
}
