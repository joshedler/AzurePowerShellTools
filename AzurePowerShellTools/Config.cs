using System;

namespace AzurePowerShellTools
{
    public class Config
    {
        private const int BlockSizeInMB = 4;

        /// <summary>
        /// Gets the default server and client timeout (in seconds) for requests. 
        /// </summary>
        public const int DefaultTimeoutInSeconds = 1800;    // (30 min)

        /// <summary>
        /// Gets the default number of retry attempts for requests.
        /// </summary>
        public const int DefaultRetryCount = 3;

        /// <summary>
        /// Gets the standard AzureConnectionString pattern that is supported.
        /// </summary>
        public const string AzureConnectionStringPattern = @"^DefaultEndpointsProtocol=(http|https);AccountName=([a-z0-9]{3,24});AccountKey=(.+)$";

        public string AzureConnectionString = String.Empty;
        public int TimeoutInSeconds = DefaultTimeoutInSeconds;
        public int RetryCount = DefaultRetryCount;
        public int WriteBlockSizeInBytes = (1024 * 1024 * BlockSizeInMB);
    }
}
