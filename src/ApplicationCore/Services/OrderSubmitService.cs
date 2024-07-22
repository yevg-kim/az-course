using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using BlazorShared.Helpers;
using BlazorShared.Models;
using Microsoft.eShopWeb.ApplicationCore.Interfaces;

namespace Microsoft.eShopWeb.ApplicationCore.Services;
public class OrderSubmitService(HttpClient client) : IOrderSubmitService
{
    public async Task SubmitForDelivery(OrderSubmitRequest request)
    {
        await client.SendAsync(new HttpRequestMessage (HttpMethod.Post, UrlHelper.Combine(client.BaseAddress!.ToString(), "/order")) { 
            Content = new StringContent(request.ToJson(), Encoding.UTF8, "application/json")
        });
    }
}
