using BlazorShared.Helpers;
using Xunit;

namespace Microsoft.eShopWeb.UnitTests.Helpers;
public class UrlHelperTests
{

    [Theory]
    [InlineData("google.com", "hello", "google.com/hello")]
    [InlineData("google.com/", "hello", "google.com/hello")]
    [InlineData("google.com", "/hello", "google.com/hello")]
    [InlineData("google.com/", "/hello", "google.com/hello")]
    public void TwoNotNullStringsOk(string url1, string url2, string expected)
    {
        var result = UrlHelper.Combine(url1, url2);

        Assert.Equal(expected, result);
    }
    
    [Theory]
    [InlineData(null)]
    [InlineData("")]
    [InlineData("url")]
    public void OnlyOneStringThrowsError(string? url) => 
        Assert.Throws<ArgumentException>(() => UrlHelper.Combine(url));

    [Theory]
    [InlineData("google.com", "page", "1", "google.com/page/1")]
    [InlineData("google.com", "page", "/1", "google.com/page/1")]
    [InlineData("google.com", "page/", "1", "google.com/page/1")]
    [InlineData("google.com", "page/", "/1", "google.com/page/1")]

    [InlineData("google.com", "/page", "1", "google.com/page/1")]
    [InlineData("google.com", "/page", "/1", "google.com/page/1")]
    [InlineData("google.com", "/page/", "1", "google.com/page/1")]
    [InlineData("google.com", "/page/", "/1", "google.com/page/1")]

    [InlineData("google.com/", "page", "1", "google.com/page/1")]
    [InlineData("google.com/", "page", "/1", "google.com/page/1")]
    [InlineData("google.com/", "page/", "1", "google.com/page/1")]
    [InlineData("google.com/", "page/", "/1", "google.com/page/1")]

    [InlineData("google.com/", "/page", "1", "google.com/page/1")]
    [InlineData("google.com/", "/page", "/1", "google.com/page/1")]
    [InlineData("google.com/", "/page/", "1", "google.com/page/1")]
    [InlineData("google.com/", "/page/", "/1", "google.com/page/1")]
    public void ThreeStringsOk(string url1, string url2, string url3, string expected)
    {
        var result = UrlHelper.Combine(url1, url2, url3);

        Assert.Equal(expected, result);    
    }

    [Fact]
    public void TwoNullStringThrowsError() =>
       Assert.Throws<ArgumentNullException>(() => UrlHelper.Combine(null, null));

    [Theory]
    [InlineData("google.com", null)]
    [InlineData(null, "google")]
    public void OneNullStringThrowsError(string? url1, string? url2) =>
        Assert.Throws<ArgumentNullException>(() => UrlHelper.Combine(url1, url2));
   
    [Theory]
    [InlineData(null, "page", "1")]
    [InlineData("google.com", null, "1")]
    [InlineData(null, null, "1")]
    [InlineData("google.com", "page", null)]
    [InlineData(null, "page", null)]
    [InlineData("google.com", null, null)]
    [InlineData(null, null, null)]
    public void AtLeastOneStringEmptyThrowsError(string? url1, string? url2, string? url3) =>
        Assert.Throws<ArgumentNullException>(() => UrlHelper.Combine(url1, url2, url3));
}
