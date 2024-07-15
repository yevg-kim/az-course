using System;
using System.Text.Json;

namespace BlazorShared.Models;

public class OrderReserveRequest
{
    public DateTime OrderTimestamp { get; }
    public int ItemId { get; }
    public int Quantity { get; }

    public OrderReserveRequest(DateTime orderTimestamp, int itemId, int quantity)
    {
        OrderTimestamp = orderTimestamp;
        ItemId = itemId;
        Quantity = quantity;
    }

    public override string ToString() => JsonSerializer.Serialize(this);
}
