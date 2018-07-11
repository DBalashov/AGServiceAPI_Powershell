$URL = "http://m.tk-chel.ru/ServiceJSON";
$SCHEMA = "DemoCEBIT"
$userName = "demo"
$userPassword = "demo"

# Remove-Item "*.csv" -ErrorAction SilentlyContinue

"== Prepare and Login ========================================================================"
$c = New-Object -TypeName System.Net.WebClient;
$c.Encoding = [System.Text.Encoding]::UTF8;
$c.Headers.Add("Content-Type", "text/json");
$token = $c.DownloadString("$URL/Login?UserName=$userName&Password=$userPassword").Trim("""");
$c.Headers.Add("AG-TOKEN", $token)
"Token: $token"
$token > "PS_Token.csv"

"== EnumSchemas =============================================================================="
$schemaID = "";
$schemas = $c.DownloadString("$URL/EnumSchemas") | ConvertFrom-Json
foreach($x in $schemas) {
    $x.ID+": "+$x.Name
    if($x.Name -eq $SCHEMA) {
        $schemaID = $x.ID;
    }
}
$schemas | Export-Csv "PS_Schemas.csv" -NoTypeInformation -Encoding UTF8

"== EnumDevices =============================================================================="
$devices = $c.DownloadString("$URL/EnumDevices?schemaID=$schemaID") | ConvertFrom-Json
"Groups: "+$devices.Groups.Length
"Devices: "+$devices.Items.Length
$devices.Groups | Select-Object ID,ParentID,Name | Export-Csv "PS_Devices_Groups.csv" -NoTypeInformation -Encoding UTF8
$devices.Items | Select-Object ID,ParentID,Name,Allowed,Serial | Export-Csv "PS_Devices_Devices.csv" -NoTypeInformation -Encoding UTF8

"== EnumGeofences ============================================================================"
$geofences = $c.DownloadString("$URL/EnumGeofences?schemaID=$schemaID") | ConvertFrom-Json
"Groups: "+$geofences.Groups.Length
"Devices: "+$geofences.Items.Length
$geofences.Groups | Select-Object ID,ParentID,Name | Export-Csv "PS_Geofences_Groups.csv" -NoTypeInformation -Encoding UTF8
$geofences.Items | Select-Object ID,ParentID,Name | Export-Csv "PS_Geofences_Geofences.csv" -NoTypeInformation -Encoding UTF8

"== GetOnlineInfoAll ============================================================="
$oi = $c.DownloadString("$URL/GetOnlineInfoAll?schemaID=$schemaID") | ConvertFrom-Json
"OnlineInfoItems: " + $oi.Length

$oiresult =@()

# dictionary => objects
$ids = $item.psobject.Properties.Name
for($i=0; $i -lt $ids.Length; $i++)
{
    $value = $item.psobject.Properties.Item($ids[$i]).Value

    $obj = New-Object PSObject
    $obj | Add-Member -MemberType NoteProperty -Name "ID" -Value $ids[$i]
    $obj | Add-Member -MemberType NoteProperty -Name "Name" -Value $value.Name
    if($value)
    {
        $obj | Add-Member -MemberType NoteProperty -Name "DTUTC" -Value $value.DT
        $obj | Add-Member -MemberType NoteProperty -Name "Lat" -Value $value.LastPosition.Lat
        $obj | Add-Member -MemberType NoteProperty -Name "Lng" -Value $value.LastPosition.Lng
        $obj | Add-Member -MemberType NoteProperty -Name "State" -Value $value.State
        $obj | Add-Member -MemberType NoteProperty -Name "LastData" -Value $value._LastData
    }
    else
    {
        $obj | Add-Member -MemberType NoteProperty -Name "DTUTC" -Value ""
        $obj | Add-Member -MemberType NoteProperty -Name "Speed" -Value ""
        $obj | Add-Member -MemberType NoteProperty -Name "Lat" -Value ""
        $obj | Add-Member -MemberType NoteProperty -Name "Lng" -Value ""
        $obj | Add-Member -MemberType NoteProperty -Name "State" -Value ""
        $obj | Add-Member -MemberType NoteProperty -Name "LastData" -Value ""
    }
    $oiresult += $obj
}
$oiresult | Export-Csv "PS_GetOnlineInfoAll.csv" -NoTypeInformation -Encoding UTF8

