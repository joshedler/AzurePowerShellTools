
namespace AzurePowerShellTools
{
    internal static class Logger
    {
        public static void WriteVerbose(ICmdlet cmdlet, string message, params object[] args)
        {
            if (cmdlet != null)
            {
                if (args.Length == 0)
                {
                    cmdlet.WriteVerbose(message);
                }
                else
                {
                    cmdlet.WriteVerbose(string.Format(message, args));
                }
            }
        }
    }
}
