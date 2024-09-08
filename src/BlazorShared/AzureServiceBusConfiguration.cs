using System.Collections.Generic;
using System.Collections.Immutable;
using System.Collections.ObjectModel;
using System.Linq;

namespace BlazorShared;
public class AzureServiceBusConfiguration
{
    private ImmutableDictionary<string, string> _dict;
    private string _fullConnectionString;

    public string FullConnectionString
    {
        get { return _fullConnectionString; }
        set { 
            _fullConnectionString = value;
            _dict = value.Split(";").ToImmutableDictionary(p => p.Split("=")[0], p => p.Split("=")[1]);
        }
    }
    public string EntityPath => _dict[nameof(EntityPath)];

}
