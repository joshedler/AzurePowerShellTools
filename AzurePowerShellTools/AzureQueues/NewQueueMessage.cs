using System.Management.Automation;

namespace AzurePowerShellTools.AzureQueues
{
    [Cmdlet(VerbsCommon.New, "QueueMessage")]
    public class NewQueueMessage : PSCmdlet, ICmdlet
    {
        [Parameter(Mandatory = true, Position = 0, ParameterSetName = "Default", HelpMessage = "Queue name")]
        public string Name;

        [Parameter(Mandatory = true, Position = 1, ParameterSetName = "Default", HelpMessage = "Message string to push to the queue.")]
        public string Message;

        protected override void ProcessRecord()
        {
            var config = Settings.ReadConfigurationData(this);

            var qh = new QueueHelper(config);
            
            qh.NewMessage(Name, Message);
        }
    }
}