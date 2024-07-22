namespace BlazorShared.Models;

public class OrderItemDto(int id, string name, decimal unitPrice, int units)
{
    public int Id { get; } = id;
    public string Name { get; } = name;
    public decimal UnitPrice { get; } = unitPrice;
    public int Units { get; } = units;
}
