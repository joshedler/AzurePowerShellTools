using System.Management.Automation;
using System.Text.RegularExpressions;

namespace AzurePowerShellTools
{
    [Cmdlet(VerbsDiagnostic.Test, "AzureStorageConfiguration")]
    public class TestAzureStorageConfiguration : PSCmdlet, ICmdlet
    {
        [Parameter(Mandatory = true, ParameterSetName = "Default", Position = 0, ValueFromPipeline = true)]
        public string AzureConnectionString;

        protected override void ProcessRecord()
        {
            if (!Regex.IsMatch(AzureConnectionString, Config.AzureConnectionStringPattern))
            {
                WriteObject(false);
            }
            else
            {
                WriteObject(true);                
            }
        }
    }
}