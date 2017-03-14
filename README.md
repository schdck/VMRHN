# VMRHN
Virtual Machines Replication Health Notifier (VMRHN) is a simple Powershell script that sends you an e-mail when one of your Hyper-V Virtual Machines failed to replicate.

The script must run as administrator, and can be used togheter with Windows Task Scheduler.

To run the script from a BAT file, use:

    Powershell.exe -File  "[PATH TO SCRIPT]"
    
Don't forget to run the BAT with admin permissions.

## Demonstration:

![alt tag](http://i.imgur.com/mMMVAII.png)

The CSV attachment contains name, health,	mode,	primary server,	replica server, replica port and authentication type of all Virtual Machines with replica enable running on the server.
