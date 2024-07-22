using System.Threading.Tasks;
using BlazorShared.Models;

namespace Microsoft.eShopWeb.ApplicationCore.Interfaces;
public interface IOrderSubmitService
{
    Task SubmitForDelivery(OrderSubmitRequest request);
}
