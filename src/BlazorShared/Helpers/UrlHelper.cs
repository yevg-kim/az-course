using System;
using System.Linq;

namespace BlazorShared.Helpers;

public class UrlHelper
{
    private static string EmptyUrlPartErrorMessage = "A part of combined url can not be empty/null.";
    private static string TooFewPartsProvidedErrorMessage = "Number of segments to combine should be at least 2.";

    public static string Combine(string url1, string url2)
    {
        if (string.IsNullOrEmpty(url1) || string.IsNullOrEmpty(url2))
            throw new ArgumentNullException(EmptyUrlPartErrorMessage);

        url1 = url1.TrimEnd('/', '\\');
        url2 = url2.TrimStart('/', '\\');

        return string.Format("{0}/{1}", url1, url2);
    }

    public static string Combine(params string[] urls) {
        if ((urls?.Length ?? 0) < 2)
            throw new ArgumentException(TooFewPartsProvidedErrorMessage);
        
        return urls.Aggregate(Combine);
    }
}
