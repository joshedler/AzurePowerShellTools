using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace AzurePowerShellTools
{
    internal class MissingEnvironmentVariableException : Exception
    {
        public MissingEnvironmentVariableException(string name) : base(string.Format("The environment variable $0 is missing.", name)) {}
    }
}
