namespace BlazorShared.Models;

public class AddressDto(string street, string city, string state, string country, string zipcode)
{
    public string Street { get; private set; } = street;

    public string City { get; private set; } = city;

    public string State { get; private set; } = state;

    public string Country { get; private set; } = country;

    public string ZipCode { get; private set; } = zipcode;
}
