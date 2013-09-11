AzurePowerShellTools
====================

About
-----

**AzurePowerShellTools** are a set of Cmdlets that add functionality to the standard 
[Windows Azure Management Cmdlets][1].

For now, the added functionality is around Pushing, Peeking, Counting, and Popping messages
to and from an Azure queue. In the future more functionality may be added.

Configuration
-------------

_Disclaimer: I was unable to reliably retrieve the full connection-related information from
the standard [Windows Azure Management Cmdlets][1]. If anyone has any suggestions, I'm interested.
For now, these tools implement their own Azure Storage-related configuration._

To initially set your configuration, use the following example:

    Set-AzureStorageConfiguration -AzureConnectionString 'DefaultEndpointsProtocol=https;AccountName=abc123;AccountKey=xxxYYYzzz'

Replace `abc123` with your actual storage account name, and `xxxYYYzzz` with your actual storage 
account key. Also, you may specify either `http` or `https` as the protocol.

You can also:

    Get-AzureStorageConfiguration
    
This will show you what your current configuration is. If you don't have one, defaults will be
created.

Usage
-----

You can use the [Windows Azure Management Cmdlets][1] to create, remove, and list queues:

    New-AzureStorageQueue my-queue
    Remove-AzureStorageQueue my-queue
    Get-AzureStorageQueue
    
Use these **AzurePowerShellTools** to Push, Peek, Count, and Pop messages to and from the queue:

    New-QueueMessage my-queue 'my message'
    Get-QueueMessage my-queue
    Get-QueueMessageCount my-queue
    Get-QueueMessage my-queue -Remove



[1]: http://msdn.microsoft.com/en-us/library/jj152841.aspx    "Windows Azure Management Cmdlets"
