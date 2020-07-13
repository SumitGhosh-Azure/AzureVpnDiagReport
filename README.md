# AzureVpnDiagReport
Creates a Diagnostic report on Site to Site connections for Azure VPN gateway

This script will end up creating a text file with all the details for VPN gateway, Virtual network, Local network Gateway and Connection objects.
Most of this information is available on ASC as well, but to gather that under one file is quite time consuming and involves opening a lot of hyperlinks for all related resources.
This not just saves a lot of time, but provides us with a small file with just the relevant information to understand the setup.
Moreover, I would request to use this in case we are reaching out to a Networking SME for help as these details will cover everything there is to know about the setup.

A major chunk of the VPN cases is for new VPN setup and if customers run this script, they will get an overview of their environments along with suggestions and techlinks to make their setup work.
As per gateway configuration pulled by script , technical suggestions and Microsoft techlinks would be written in the output file, so that customer can understand the misconfigurations and work on it.
This will help our new users to not just resolve their issues but understand how our VPN gateway works and its architecture, empowering them.


The Script is broken into 3 major parts:

1.	VPN Gateway details
-	Name, Resource Group and location.
-	VPN type(Route or Policy based).
-	Active-Active or not: Public IP’s for the gateway
-	BGP: If yes, BGP Peer IP’s with ASN
-	Reference documents about Active-Active gateway and configuration of BGP

2.	Vnet/Subnet Details:
-	Name of the associated Vnet and Address range of the Vnet.
-	Peerings configured with the gateway Vnet.
-	If Peerings available: Peering name, Vnet name, Address range of the Vnet along with configurations like Virtual network access and Gateway transit.
-	Reference links and suggestions on how to connect to peered network and to avoid address range overlaps.
-	Check on NSG and Route table associated with gateway subnet along with techlink referring to Microsoft’s recommendation.

3.	Connections/Local Network Gateway:
-	Number of Connections and if not any, then how to create connections.
-	If Connections available, name of connection and name of LNG associated to it.
-	Current Connection status
-	Last connection established time(UTC) for that connection
-	Pre shared key configured
-	BGP configured or not
-	Local Gateway Public IP along with OnPrem address range configured
-	Suggestions on verification of LNG configurations as per OnPrem device.
-	Suggestions based on the live connections status for LNG along with techlinks to fix the same if issue persist.

Mandatory parameters to run the script is the VPN Gateway name along with its Resource Group.
Please note: Since the script will create and auto open the created file, we need Admin privileges to run this script.
