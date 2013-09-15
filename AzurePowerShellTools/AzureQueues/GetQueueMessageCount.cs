using System.Management.Automation;

namespace AzurePowerShellTools.AzureQueues
{
    [Cmdlet(VerbsCommon.Get, "QueueMessageCount")]
    public class GetQueueMessageCount : PSCmdlet, ICmdlet
    {
        [Parameter(Mandatory = true, Position = 0, ParameterSetName = "Default", HelpMessage = "Queue name")]
        public string Name;

        protected override void ProcessRecord()
        {
            var config = Settings.ReadConfigurationData(this);

            var qh = new QueueHelper(config);
            var count = qh.GetMessageCount(Name);

            WriteObject(count);
        }
    }
}