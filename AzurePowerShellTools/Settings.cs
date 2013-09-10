using System;
using System.IO;
using Newtonsoft.Json;

namespace AzurePowerShellTools
{
    internal static class Settings
    {
        public static string GetConfigurationDataFilePath(ICmdlet cmdlet)
        {
            var f = Environment.GetEnvironmentVariable("APPDATA");

            if (f == null)
                throw new MissingEnvironmentVariableException("APPDATA");

            f = Path.Combine(f, "AzurePowerShellTools");

            if (!Directory.Exists(f))
            {
                Logger.WriteVerbose(cmdlet, "Data directory '{0}' not found; creating.", f);

                Directory.CreateDirectory(f);
            }

            f = Path.Combine(f, "config.json");

            if (!File.Exists(f))
            {
                Logger.WriteVerbose(cmdlet, "Data file '{0}' not found; creating.", f);

                WriteConfigurationData(f, new Config(), cmdlet);
            }

            return f;
        }

        public static Config ReadConfigurationData(ICmdlet cmdlet)
        {
            return ReadConfigurationData(GetConfigurationDataFilePath(cmdlet), cmdlet);
        }

        private static Config ReadConfigurationData(string pathToFile, ICmdlet cmdlet)
        {
            using (var fs = File.Open(pathToFile, FileMode.Open))
            {
                using (var sr = new StreamReader(fs))
                {
                    var json = sr.ReadToEnd();
                    var config = JsonConvert.DeserializeObject<Config>(json);

                    return config;
                }
            }
        }

        public static void WriteConfigurationData(Config config, ICmdlet cmdlet)
        {
            WriteConfigurationData(GetConfigurationDataFilePath(cmdlet), config, cmdlet);
        }

        private static void WriteConfigurationData(string pathToFile, Config config, ICmdlet cmdlet)
        {
            using (var fs = File.Open(pathToFile, FileMode.Create))
            {
                using (var sw = new StreamWriter(fs))
                {
                    var json = JsonConvert.SerializeObject(config);
                    sw.Write(json);
                }
            }
        }

        public static string GetAzureConnectionString(ICmdlet cmdlet)
        {
            var config = ReadConfigurationData(cmdlet);

            return config.AzureConnectionString;
        }
    }
}
