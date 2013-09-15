using System.Management.Automation;

namespace AzurePowerShellTools.AzureQueues
{
    [Cmdlet(VerbsCommon.Get, "QueueMessage")]
    public class GetQueueMessage : PSCmdlet, ICmdlet
    {
        [Parameter(Mandatory = true, Position = 0, ParameterSetName = "Default", HelpMessage = "Queue name")]
        public string Name;

        [Parameter(Mandatory = false, ParameterSetName = "Default", HelpMessage = "Remove (pop) the message from the queue.")]
        public SwitchParameter Remove;

        protected override void ProcessRecord()
        {
            var config = Settings.ReadConfigurationData(this);

            var qh = new QueueHelper(config);

            var msg = qh.GetMessage(Name, Remove);

            WriteObject(msg);
        }
    }
}