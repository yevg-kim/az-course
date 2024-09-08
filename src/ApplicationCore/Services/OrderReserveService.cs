using System.Threading.Tasks;
using Azure.Messaging.ServiceBus;
using BlazorShared;
using BlazorShared.Models;
using Microsoft.eShopWeb.ApplicationCore.Interfaces;
using Microsoft.Extensions.Azure;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace Microsoft.eShopWeb.ApplicationCore.Services;
public class OrderReserveService(IAzureClientFactory<ServiceBusClient> serviceBusClientFactory, 
     IOptions<AzureServiceBusConfiguration> configuration, ILogger<OrderReserveService> logger) : IOrderReserveService
{
    private ServiceBusSender _sender = serviceBusClientFactory.CreateClient("ReserveAsbClient").CreateSender(configuration.Value.EntityPath);
    private ILogger<OrderReserveService> _logger = logger;
    public async Task Reserve(OrderReserveRequest request)
    {
        try
        {
            await _sender.SendMessageAsync(new ServiceBusMessage(request.ToJson()));
        }
        catch (System.Exception)
        {
            _logger.LogError("Failed to send order request '{request}' to service bus", request.ToJson());
            throw;
        }
    }
}
