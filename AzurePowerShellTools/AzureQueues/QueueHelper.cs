using System;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Queue;
using Microsoft.WindowsAzure.Storage.RetryPolicies;

namespace AzurePowerShellTools.AzureQueues
{
    internal class QueueHelper
    {
        private readonly CloudQueueClient cloudQueueClient;

        public QueueHelper(Config config)
        {
            var connectionString = config.AzureConnectionString;

            CloudStorageAccount cloudStorageAccount = CloudStorageAccount.Parse(connectionString);
            cloudQueueClient = cloudStorageAccount.CreateCloudQueueClient();

            cloudQueueClient.ServerTimeout = TimeSpan.FromSeconds(config.TimeoutInSeconds);
            cloudQueueClient.RetryPolicy = new LinearRetry(TimeSpan.FromSeconds(3), config.RetryCount);
        }

        public void NewMessage(string queueName, string queueMessage)
        {
            var cqm = new CloudQueueMessage(queueMessage);

            cloudQueueClient.GetQueueReference(queueName).AddMessage(cqm);

            /*
             * Note: the AddMessage method does not populate the CloudQueueMessage
             * fields after it is finished, so there's really no use for a
             * return here.
             */
        }

        public CloudQueueMessage GetMessage(string queueName, bool remove)
        {
            var queue = cloudQueueClient.GetQueueReference(queueName);

            if (remove)
            {
                var cqm = queue.GetMessage();

                if (cqm != null)
                {
                    queue.DeleteMessage(cqm);

                    return cqm;
                }
            }
            else
            {
                var cqm = queue.PeekMessage();

                return cqm;
            }

            return null;
        }

        public int GetMessageCount(string queueName)
        {
            var queue = cloudQueueClient.GetQueueReference(queueName);

            queue.FetchAttributes();
            var count = queue.ApproximateMessageCount;

            if (!count.HasValue)
            {
                return -1;
            }

            return count.Value;
        }

        public void ClearAllMessages(string queueName)
        {
            var queue = cloudQueueClient.GetQueueReference(queueName);

            queue.Clear();
        }
    }
}
