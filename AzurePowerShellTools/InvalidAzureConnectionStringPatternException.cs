using System;

namespace AzurePowerShellTools
{
    public class InvalidAzureConnectionStringPatternException : Exception
    {
        public InvalidAzureConnectionStringPatternException(string pattern) 
            : base("'AzureConnectionString' contains an unexpected or invalid pattern. Valid connection strings are in the form '" + pattern + "'.") {}
    }
}