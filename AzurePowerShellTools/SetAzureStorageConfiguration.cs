using System.Management.Automation;
using System.Text.RegularExpressions;

namespace AzurePowerShellTools
{
    [Cmdlet(VerbsCommon.Set, "AzureStorageConfiguration")]
    public class SetAzureStorageConfiguration : PSCmdlet, ICmdlet
    {
        [Parameter(Mandatory = false, ParameterSetName = "Set")]
        public string AzureConnectionString;

        [Parameter(Mandatory = false, ParameterSetName = "Set")]
        [ValidateRange(1,3600)]
        public int TimeoutInSeconds;

        [Parameter(Mandatory = false, ParameterSetName = ParameterSetNameSet)]
        [ValidateRange(1,5)]
        public int RetryCount;

        [Parameter(Mandatory = false, ParameterSetName = ParameterSetNameClear)]
        public SwitchParameter ClearAzureConnectionString;

        private const string ParameterSetNameClear = "Clear";
        private const string ParameterSetNameSet = "Set";

        protected override void ProcessRecord()
        {
            bool isDirty = false;

            if (!string.IsNullOrEmpty(AzureConnectionString))
            {
                if (!Regex.IsMatch(AzureConnectionString, Config.AzureConnectionStringPattern))
                {
                    var er = new ErrorRecord(new InvalidAzureConnectionStringPatternException(Config.AzureConnectionStringPattern), "InvalidAzureConnectionStringPattern", ErrorCategory.InvalidArgument, this);
                    ThrowTerminatingError(er);
                }
            }


            // this will create the config data folder and default file if needed
            var config = Settings.ReadConfigurationData(this);

            switch (ParameterSetName)
            {
                case ParameterSetNameClear:
                    config.AzureConnectionString = string.Empty;
                    isDirty = true;
                    break;

                case ParameterSetNameSet:
                    if (!string.IsNullOrEmpty(AzureConnectionString))
                    {
                        config.AzureConnectionString = AzureConnectionString;
                        isDirty = true;
                    }

                    if (TimeoutInSeconds > 0)
                    {
                        config.TimeoutInSeconds = TimeoutInSeconds;
                        isDirty = true;
                    }

                    if (RetryCount > 0)
                    {
                        config.RetryCount = RetryCount;
                        isDirty = true;
                    }
                    break;
            }

            if (isDirty)
            {
                Settings.WriteConfigurationData(config, this);
            }

            WriteObject(config);
        }
    }
}