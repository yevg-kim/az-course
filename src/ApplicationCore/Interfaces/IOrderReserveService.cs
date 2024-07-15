using System.Threading.Tasks;
using BlazorShared.Models;

namespace Microsoft.eShopWeb.ApplicationCore.Interfaces;
public interface IOrderReserveService
{
    Task Reserve(OrderReserveRequest request);
}
