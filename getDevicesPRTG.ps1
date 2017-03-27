$server = "prtg.techo-bloc.local"
$port = "10443";
$username = Read-Host 'What is your PRTG username?'
$password = Read-Host 'What is your PRTG password?'
$resource = "https://"+$server+":"+$port+"/api/table.xml?content=devices&columns=group,device,host,status&username="+$username+"&password="+$password.
Try {
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true } 
    $web = New-Object Net.WebClient
    [xml]$output = $web.DownloadString($resource)
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = $null 
}
catch [Net.WebException] {
    $_ | fl * -Force
}
Try {
    Foreach ($device in $output.devices.item){
            if([BOOL] ($device.host -as [IPADDRESS])) {
                $device.AppendChild($output.CreateElement("ip"))
                $device.ip = $device.host
            }

            else {
                $ip = [System.Net.Dns]::GetHostAddresses($device.host)
                $device.AppendChild($output.CreateElement("ip"))
                if($ip.IPAddressToString -isnot [System.Array]){
                    $device.ip = "$ip"
                    }
                else {
                    $device.ip = "$ip"
                    }
            }
    }

$output.devices.item | Export-Csv "U:\Devices.csv" -Delimiter ";"
}
catch {
    Write-Host "Error XML"
    }


