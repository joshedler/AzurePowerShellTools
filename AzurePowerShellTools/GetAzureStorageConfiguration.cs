namespace AzurePowerShellTools
{
    [System.Management.Automation.Cmdlet(System.Management.Automation.VerbsCommon.Get, "AzureStorageConfiguration")]
    public class GetAzureStorageConfiguration : System.Management.Automation.PSCmdlet, ICmdlet
    {
        protected override void ProcessRecord()
        {
            var dataFilePath = Settings.GetConfigurationDataFilePath(this);

            WriteVerbose("Data file path: " + dataFilePath);

            var config = Settings.ReadConfigurationData(this);

            WriteObject(config);
        }
    }
}