using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using BlazorShared.Models;
using Microsoft.eShopWeb.ApplicationCore.Entities.OrderAggregate;

namespace Microsoft.eShopWeb.ApplicationCore.Extensions;
public static class MapExtensions
{
    public static OrderSubmitRequest ToOrderSubmitRequest(this Order order)
    {
        decimal normalFinalPrice = order.OrderItems.Sum(i => i.Units * i.UnitPrice);

        return new OrderSubmitRequest(
            DateTime.Now, 
            order.ShipToAddress.ToAddressDto(),
            order.OrderItems.ToItemsDto(),
            normalFinalPrice);
    }

    private static AddressDto ToAddressDto(this Address address) =>
        new(address.Street, address.City, address.State, address.Country, address.ZipCode);

    private static IReadOnlyCollection<OrderItemDto> ToItemsDto(this IReadOnlyCollection<OrderItem> items) =>
        items.Select(i => new OrderItemDto(i.Id, i.ItemOrdered.ProductName, i.UnitPrice, i.Units)).ToList().AsReadOnly();
}
