$URL = "http://m.tk-chel.ru/ServiceJSON";
$SCHEMA = "DemoCEBIT"
$userName = "demo"
$userPassword = "demo"

$c = New-Object -TypeName System.Net.WebClient;
$c.Encoding = [System.Text.Encoding]::UTF8
$c.Headers.Add("Content-Type", "text/json");
$token = $c.DownloadString("$URL/Login?UserName=$userName&Password=$userPassword").Trim("""");
$c.Headers.Add("AG-TOKEN", $token)

$schemaID = (($c.DownloadString("$URL/EnumSchemas") | ConvertFrom-Json) | where { $_.Name -eq $SCHEMA }).ID

$value = $c.DownloadString("$URL/GetDevicesInfo?schemaID=$schemaID") | ConvertFrom-Json
$result =@()
foreach($stage in $value.Stages)
{
    $obj = New-Object PSObject
    $obj | Add-Member -MemberType NoteProperty -Name "Name" -Value $stage.Name
    $obj | Add-Member -MemberType NoteProperty -Name "Parameter" -Value $stage.Parameter
    $obj | Add-Member -MemberType NoteProperty -Name "Caption" -Value $stage.Caption
    $obj | Add-Member -MemberType NoteProperty -Name "Image" -Value $stage.Image
    $result += $obj
}
$result | Export-Csv "PS_GetDevicesInfo.csv" -NoTypeInformation -Encoding UTF8

