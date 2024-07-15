using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using BlazorShared.Helpers;
using BlazorShared.Models;
using Microsoft.eShopWeb.ApplicationCore.Interfaces;

namespace Microsoft.eShopWeb.ApplicationCore.Services;
public class OrderReserveService : IOrderReserveService
{
    private readonly HttpClient _client;

    public OrderReserveService(HttpClient client)
    {
        _client = client;
    }
    public async Task Reserve(OrderReserveRequest request)
    {
        await _client.SendAsync(new HttpRequestMessage (HttpMethod.Post, UrlHelper.Combine(_client.BaseAddress!.ToString(), "/reserve")) { 
            Content = new StringContent(request.ToJson(), Encoding.UTF8, "application/json")
        });
    }
}
