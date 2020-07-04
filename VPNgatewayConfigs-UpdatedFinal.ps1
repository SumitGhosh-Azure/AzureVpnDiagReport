Param
(                    
    [Parameter(Mandatory = $true)]                
    $AzureVirtualNetworkGateway,
    [Parameter(Mandatory = $true)]                
    $ResourceGroup
)  

Connect-AzAccount

"`nLogging in to Azure... `n"

$VPNGateway = Get-AzVirtualNetworkGateway -Name $AzureVirtualNetworkGateway -ResourceGroupName $ResourceGroup

if(!$VPNGateway)
    {
    Write-Output "Azure VPN Gateway: $AzureVirtualNetworkGateway not found in Resource Group: $ResourceGroup `nPlease check the input parameters again."
    break 
    }

write-host "`nCreating a text file under C: Drive named AzureVPNGateway-$AzureVirtualNetworkGateway-Report.txt. Make sure script is running with Admin privileges.  `n`n"

Write-host "`nScript Execution Progress: `n"
write-host "       0% ##**************************************************## 100% "
Write-host -NoNewline " Progress ##--"

$Header = "####################################### Gateway Details ####################################################################`n `n"
$Filepath = "C:\" +"AzureVPNGateway-"+$VPNGateway.Name+ "-Details.txt"
$Header | Out-File -FilePath $Filepath 
$Output = "Azure VPN Gateway Name              :" + $VPNGateway.Name + "`nAzure VPN Gateway Resource Group    :" + $VPNGateway.ResourceGroupName + "`nAzure VPN Gateway Location          :" + $VPNGateway.Location + "`n`nConfiguration for Azure VPN Gateway:- `n"
$Output | Out-file -append $Filepath -NoClobber
$Output = "VPN Type            :" + $VPNGateway.VpnType + "`nIs Active Active    :" + $VPNGateway.ActiveActive + "`nIs BGP enabled      :" + $VPNGateway.EnableBgp
$Output | Out-file -append $Filepath -NoClobber

Write-host -NoNewline "--"

if($VPNGateway.EnableBgp -cmatch "True")
    {
    $Output = "`nBGP Settings of Azure VPN Gateway:-`n" + "`nBGP Peer IP Address :" + $VPNGateway.BgpSettings.BgpPeeringAddress + "`nBGP ASN             :" + $VPNGateway.BgpSettings.Asn + "`n"
    $Output | Out-file -append $Filepath -NoClobber
    $output = "Please make sure the same is updated on the onpremise device if BGP is enabled for the connection. `nRefer: https://docs.microsoft.com/bs-latn-ba/azure/vpn-gateway/vpn-gateway-bgp-overview `n"
    $Output | Out-file -append $Filepath -NoClobber
    }

Write-host -NoNewline "-------"

## Public Ip/Vnet of the Gateway ## 
if($vpngateway.ActiveActive -cmatch "False")
    {
    $VPNgatewayPIP = Get-AzResource -ResourceId $VPNGateway.IpConfigurations.PublicIpAddress.Id
    $Output = "`nPublic IP of Azure VPN Gateway is " + $VPNgatewayPIP.Properties.ipAddress + ". Please make sure the same is updated on your onpremise VPN devices."
    $Output | Out-file -append $Filepath -NoClobber
    $Header = "`n`n####################################### Vnet/Subnet Details ################################################################`n"
    $Header | Out-file -append $Filepath -NoClobber
    $MainString = $($VPNGateway.IpConfigurations.Subnet.Id).ToString()
    $VnetNameStringTemp= $MainString.Length - $MainString.IndexOf('/providers/Microsoft.Network/virtualNetworks/') - 45
    $EndingString = $MainString.Substring($($($MainString.IndexOf('/providers/Microsoft.Network/virtualNetworks/'))+45),$VnetNameStringTemp)
    $VnetName= $EndingString.Substring(0,$EndingString.IndexOf('/'))
    $LeftOverString = $MainString.Substring($($($Mainstring.IndexOf('/resourceGroups/'))+16),45)
    $VnetRGName = $LeftOverString.Substring(0,$LeftOverString.IndexOf('/'))
    $VnetofVPNGateway = Get-AzVirtualNetwork -Name $VnetName -ResourceGroupName $VnetRGName
    $VPNGatewaySubnetName = "GatewaySubnet"
    $output = "`n`nAzure VPN Gateway $($VPNGateway.Name) is deployed in Vnet: $($VnetofVPNGateway.Name) under Subnet: $VPNGatewaySubnetName"
    $Output | Out-file -append $Filepath -NoClobber
    $AdressRangeOfVnetOfGateway= $VnetofVPNGateway.AddressSpace.AddressPrefixes
    $output = "Address Range of Vnet $($VnetofVPNGateway.Name) : $AdressRangeOfVnetOfGateway" + ". `nMake sure the same is updated as Adress range on onpremise VPN device. "
    $Output | Out-file -append $Filepath -NoClobber
    }
else 
    {
    $VPNgatewayPIP1 = Get-AzResource -ResourceId $VPNGateway.IpConfigurations.PublicIpAddress.Id[0]
    $VPNgatewayPIP2 = Get-AzResource -ResourceId $VPNGateway.IpConfigurations.PublicIpAddress.Id[1]
    $Output = "`nGateway is Active-Active. Public IP's of Azure VPN Gateway are " + $VPNgatewayPIP1.Properties.ipAddress + " and " + $VPNgatewayPIP2.Properties.ipAddress + ". Please make sure both the IP's are updated on your onpremise VPN devices."
    $Output | Out-file -append $Filepath -NoClobber
    $Header = "`n`n####################################### Vnet/Subnet Details ################################################################`n"
    $Header | Out-file -append $Filepath -NoClobber
    $MainString = $($VPNGateway.IpConfigurations.Subnet.Id[0]).ToString()
    $VnetNameStringTemp= $MainString.Length - $MainString.IndexOf('/providers/Microsoft.Network/virtualNetworks/') - 45
    $EndingString = $MainString.Substring($($($MainString.IndexOf('/providers/Microsoft.Network/virtualNetworks/'))+45),$VnetNameStringTemp)
    $VnetName= $EndingString.Substring(0,$EndingString.IndexOf('/'))
    $LeftOverString = $MainString.Substring($($($Mainstring.IndexOf('/resourceGroups/'))+16),45)
    $VnetRGName = $LeftOverString.Substring(0,$LeftOverString.IndexOf('/'))
    $VnetofVPNGateway = Get-AzVirtualNetwork -Name $VnetName -ResourceGroupName $VnetRGName
    $VPNGatewaySubnetName = "GatewaySubnet"
    $output = "`n`nAzure VPN Gateway $($VPNGateway.Name) is deployed in Vnet: $($VnetofVPNGateway.Name) under Subnet: $VPNGatewaySubnetName"
    $Output | Out-file -append $Filepath -NoClobber
    $AdressRangeOfVnetOfGateway= $VnetofVPNGateway.AddressSpace.AddressPrefixes
    $output = "Address Range of Vnet $($VnetofVPNGateway.Name) : $AdressRangeOfVnetOfGateway" + ". `nMake sure the same is updated as Adress range on onpremise VPN device. "
    $Output | Out-file -append $Filepath -NoClobber
    }

Write-host -NoNewline "---"
Write-host -NoNewline "-----------"


## Checking for Peerings on Gateway Vnet.##

if($VPNGatewayVnetPeerings = Get-AzVirtualNetworkPeering -VirtualNetworkName $VnetofVPNGateway.Name -ResourceGroupName $VnetRGName)
    { 
     $Output = "`n`nPeering with Gateway VNet            :True `nNumber of Peerings                   :$($VPNGatewayVnetPeerings.Count) `n"
     $Output | Out-file -append $Filepath -NoClobber
     foreach ($VPNGatewayVnetPeering in $VPNGatewayVnetPeerings)
        {
        $MainString = $($VPNGatewayVnetPeering.RemoteVirtualNetwork.Id).ToString()
        $TempLength = $($MainString.Length)-$($MainString.IndexOf('/providers/Microsoft.Network/virtualNetworks/')) - 45
        $PeeredVnetName = $MainString.Substring($($($MainString.IndexOf('/providers/Microsoft.Network/virtualNetworks/'))+45),$TempLength)
        $Output = "`n`nPeering Name                         :" + $VPNGatewayVnetPeering.Name + "`nPeered Vnet Name                     :" + $PeeredVnetName + "`nAddress range                        :" + $VPNGatewayVnetPeering.RemoteVirtualNetworkAddressSpace.AddressPrefixes + "`nVirtual network acccess              :" + $VPNGatewayVnetPeering.AllowVirtualNetworkAccess + "`nGateway Transit enabled              :" + $VPNGatewayVnetPeering.AllowGatewayTransit
        $Output | Out-file -append $Filepath -NoClobber
        $Output = "`nPlease make sure the peered Vnet $PeeredVnetName address range $($VPNGatewayVnetPeering.RemoteVirtualNetworkAddressSpace.AddressPrefixes) does not overlap with you onpremise network range. `nTo connect to the peered network from onpremise, please make sure the range $($VPNGatewayVnetPeering.RemoteVirtualNetworkAddressSpace.AddressPrefixes) is updated on your onpremise VPN device. Kindly confirm that the virtual network access to $PeeredVnetName and Gateway transit is enabled for the peering."
        $Output | Out-file -append $Filepath -NoClobber
        }
    }
else
    {
    $output = "`n`nVnet Peering  for VNet $VnetName : False "
    $Output | Out-file -append $Filepath -NoClobber
    }

Write-host -NoNewline "----"


## Fetching NSG rules and UDR on gateway subnet ###

$Output = "`n`nNSG/Route Table on Vnet $($VnetofVPNGateway.Name) :"
$Output | Out-file -append $Filepath -NoClobber
$VPNGatewaySubnet = Get-AzVirtualNetworkSubnetConfig -Name $VPNGatewaySubnetName -VirtualNetwork $VnetofVPNGateway
if($($VPNGatewaySubnet.NetworkSecurityGroup))
    {
    $Output = "`nAzure VPN Gateway Subnet is associated with a NSG: $($VPNGatewaySubnet.NetworkSecurityGroup.Name)" + ". Kindly remove the same as per Microsoft recommendations. `nPlease refer: https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpn-gateway-settings#gwsub"
    $Output | Out-file -append $Filepath -NoClobber
    }
if($($VPNGatewaySubnet.RouteTable))
    {
    $Output = "`nAzure VPN Gateway Subnet is associated with a Route Table: $($VPNGatewaySubnet.RouteTable.Name)" + ". Kindly remove the same as per Microsoft recommendations. `nPlease refer: https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpn-gateway-settings#gwsub"
    $Output | Out-file -append $Filepath -NoClobber
    }
if(!$($VPNGatewaySubnet.NetworkSecurityGroup) -and !$($VPNGatewaySubnet.RouteTable) )
    {
    $Output = "`nNo NSG and route table found associated with the Azure VPN Gateway Subnet. This aligns with Microsft recommendations. `nPlease refer: https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpn-gateway-settings#gwsub"
    $Output | Out-file -append $Filepath -NoClobber
    }

Write-host -NoNewline "----"


## Fetching Connection Objects associated to the VPN Gateway ##
$ConnectionsNameArray = @()
$ConnectionsRGArray = @()
$Connections = Get-AzResource -ResourceType Microsoft.Network/connections

$Header = "`n`n####################################### Connections/LocalNetwork Gateway #####################################################`n `n"
$Header | Out-file -append $Filepath -NoClobber

foreach($connection in $Connections)
    {
    $ConnectionObject= Get-AzVirtualNetworkGatewayConnection -Name $connection.Name -ResourceGroupName $Connection.ResourceGroupName
    $VirtualNetworkGatewaytemp = Get-AzResource -ResourceId $ConnectionObject.VirtualNetworkGateway1.Id
    
    if($VirtualNetworkGatewaytemp.Name -eq $VPNGateway.Name -and $VirtualNetworkGatewaytemp.ResourceGroupName -eq $VPNGateway.ResourceGroupName)
        {
         $ConnectionsNameArray = $ConnectionsNameArray + $ConnectionObject.Name
         $ConnectionsRGArray = $ConnectionsRGArray + $ConnectionObject.ResourceGroupName
   
        }   
    }

Write-host -NoNewline "-------"

if($ConnectionsNameArray.Count -eq "0")
    {
    $output = "`nNo Connections associated with the $($VPNGateway.Name) Azure VPN Gateway. To make connections with this gateway, please refer: https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-site-to-site-resource-manager-portal#CreateConnection"
    $Output | Out-file -append $Filepath -NoClobber
    }
else
    {
    $Output = " `nNumber of Connections associated with the $($VPNGateway.Name) Azure VPN Gateway: $($ConnectionsNameArray.Count)`n"
    $Output | Out-file -append $Filepath -NoClobber
    }


Write-host -NoNewline "----"


for($i=0; $i -lt $($ConnectionsNameArray.Count);$i++ )
    {
    $ConnName = $ConnectionsNameArray[$i]
    $connRG= $ConnectionsRGArray[$i]
    $VPNGatewayConnection = Get-AzVirtualNetworkGatewayConnection -Name $ConnName -ResourceGroupName $ConnRg
    $LNGString= $($VPNGatewayConnection.LocalNetworkGateway2.Id).ToString()
    $LNGNameStringtemp= $LNGString.Length - $LNGString.IndexOf('/providers/Microsoft.Network/localNetworkGateways/') - 50
    $LNGName = $LNGString.Substring($($($LNGString.IndexOf('/providers/Microsoft.Network/localNetworkGateways/'))+50),$LNGNameStringtemp)
    $LNGRgNameTemp = $LNGString.Substring($($($LNGString.IndexOf('/resourceGroups/'))+16),30)
    $LNGRgName = $LNGRgNameTemp.Substring(0,$LNGRgNameTemp.IndexOf('/'))
    $LNG = Get-AzLocalNetworkGateway -Name $LNGName -ResourceGroupName $LNGRgName
    

    if($($ConnectionsNameArray.Count) -eq "1")
        {
        }
    else
        {
        $Output = "`nConnection no.: " + $($i +1) + "`n"
        $Output | Out-file -append $Filepath -NoClobber
        }
    
    $output = "Connection Name                      :$ConnName " + "`nConnection Status                    :$($VPNGatewayConnection.ConnectionStatus)   "
    $Output | Out-file -append $Filepath -NoClobber
    if($VPNGatewayConnection.TunnelConnectionStatus)
        {
        $Output = "Last Connection Established time(UTC):$($VPNGatewayConnection.TunnelConnectionStatus.LastConnectionEstablishedUTCTime) "
        $Output | Out-file -append $Filepath -NoClobber
        }
    $output = "Pre-shared Key                       :$($VPNGatewayConnection.SharedKey) " + "`nLocal Network Gateway                :$LNGName "
    $Output | Out-file -append $Filepath -NoClobber
    $output = "Local Network Gateway IP             :$($LNG.GatewayIpAddress) " + "`nLocal Network Gateway Address Range  :$($LNG.LocalNetworkAddressSpace.AddressPrefixes)"
    $Output | Out-file -append $Filepath -NoClobber
    if($LNG.BgpSettings)
        {
        $Output = "BGP configuration                    :True"
        $Output | Out-file -append $Filepath -NoClobber
        }
    else
        {
        $Output = "BGP configuration                    :False"
        $Output | Out-file -append $Filepath -NoClobber
        }
    
    $Output = "`nAs per Azure Gateway the onpremise gateway device IP is $($LNG.GatewayIpAddress) and the onpremise network range is $($LNG.LocalNetworkAddressSpace.AddressPrefixes) "
    $Output | Out-file -append $Filepath -NoClobber
    $output = "The Shared key used for the connection is:- $($VPNGatewayConnection.SharedKey)" + ". Please confirm the same on your onprem device.`n"
    $Output | Out-file -append $Filepath -NoClobber
    if($($VPNGatewayConnection.ConnectionStatus) -eq "Connected")
        {
        $Output = "Status is Connected for this connection. If you are still facing any connectivity issues that means your main mode for the tunnel is up but quick mode is failing. Please check for IPSEC/IKE policies configured on the onpremise device.`nRefer: https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpn-devices `n`n"
        $Output | Out-file -append $Filepath -NoClobber
        }
    else
        {
        $output = "Status is not connected for this connection. Please check the following: `nAzure Gateway Public IP and Vnet Address range is updated on the onpremise VPN device.`nOnpremise VPN device's Public IP and network Address range is updated on Azure Local Network Gateway.`nPlease check that the right Pre-shared key is updated on both Azure and onpremise gateway. `nValidate the IPSEC/IKE policies configured on the onpremise device: https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpn-devices `n`n "
        $Output | Out-file -append $Filepath -NoClobber
        }
    }

$Output = "`n################################################################################################################################################# `n"
$Output | Out-file -append $Filepath -NoClobber

Write-host -NoNewline "------## 100% "
write-host ""
Write-host "`nScript Execution Completed. Opening file AzureVPNGateway-$AzureVirtualNetworkGateway-Report.txt"

Start-Sleep -Milliseconds 500
Invoke-Item $Filepath
