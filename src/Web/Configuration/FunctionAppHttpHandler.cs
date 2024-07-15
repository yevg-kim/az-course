
namespace Microsoft.eShopWeb.Web.Configuration;

public class FunctionAppHttpHandler : DelegatingHandler
{
    private readonly string _code;

    public FunctionAppHttpHandler(string code)
    {
        _code = code;
    }

    protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
    {
        var uriBuilder = new UriBuilder(request.RequestUri!);

        uriBuilder.Query = string.IsNullOrEmpty(uriBuilder.Query) ?
            $"code={_code}" :
            $"{uriBuilder.Query}&code={_code}";

        request.RequestUri = uriBuilder.Uri;

        return base.SendAsync(request, cancellationToken);
    }
}
