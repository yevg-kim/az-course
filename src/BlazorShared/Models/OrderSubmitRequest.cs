using System;
using System.Collections.Generic;
using System.Text.Json;

namespace BlazorShared.Models;

public class OrderSubmitRequest
{
    public DateTime SubmitTimestamp { get; }

    public AddressDto Address { get; }

    public IReadOnlyCollection<OrderItemDto> Items {get;}

    public decimal FinalPrice { get; }

    public OrderSubmitRequest(DateTime submitTimestamp, AddressDto address, IReadOnlyCollection<OrderItemDto> items, decimal finalPrice)
    {
        SubmitTimestamp = submitTimestamp;
        Address = address;
        Items = items;
        FinalPrice = finalPrice;
    }

    public override string ToString() => JsonSerializer.Serialize(this);
}
