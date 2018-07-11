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
$deviceID = "d090286c-1fd6-4ef2-ae44-8091d04408d1"  # GAZell
$parameters = $c.DownloadString("$URL/EnumParameters?schemaID=$schemaID&IDs=$deviceID") | ConvertFrom-Json

$value = $parameters.psobject.Properties.Item($deviceID).Value;

$result =@()
$obj = New-Object PSObject
foreach($p in $value.OnlineParams)
{
    $obj = New-Object PSObject
    $obj | Add-Member -MemberType NoteProperty -Name "Group" -Value $p.GroupName
    $obj | Add-Member -MemberType NoteProperty -Name "Name" -Value $p.Name
    $obj | Add-Member -MemberType NoteProperty -Name "ReturnType" -Value $p.ReturnType
    $obj | Add-Member -MemberType NoteProperty -Name "ValueType" -Value $p.ValueType
    $obj | Add-Member -MemberType NoteProperty -Name "Unit" -Value $p.Unit
    $obj | Add-Member -MemberType NoteProperty -Name "Format" -Value $p.Format
    $result += $obj
}
$result | Export-Csv "PS_EnumParameters_OnlineParams.csv" -NoTypeInformation -Encoding UTF8

$result=@()
foreach($p in $value.TripsParams)
{
    $obj = New-Object PSObject
    $obj | Add-Member -MemberType NoteProperty -Name "Group" -Value $p.GroupName
    $obj | Add-Member -MemberType NoteProperty -Name "Name" -Value $p.Name
    $obj | Add-Member -MemberType NoteProperty -Name "ReturnType" -Value $p.ReturnType
    $obj | Add-Member -MemberType NoteProperty -Name "ValueType" -Value $p.ValueType
    $obj | Add-Member -MemberType NoteProperty -Name "Unit" -Value $p.Unit
    $obj | Add-Member -MemberType NoteProperty -Name "Format" -Value $p.Format
    $result += $obj
}
$result | Export-Csv "PS_EnumParameters_TripParams.csv" -NoTypeInformation -Encoding UTF8

$result=@()
foreach($p in $value.FinalParams)
{
    $obj = New-Object PSObject
    $obj | Add-Member -MemberType NoteProperty -Name "Group" -Value $p.GroupName
    $obj | Add-Member -MemberType NoteProperty -Name "Name" -Value $p.Name
    $obj | Add-Member -MemberType NoteProperty -Name "ReturnType" -Value $p.ReturnType
    $obj | Add-Member -MemberType NoteProperty -Name "ValueType" -Value $p.ValueType
    $obj | Add-Member -MemberType NoteProperty -Name "Unit" -Value $p.Unit
    $obj | Add-Member -MemberType NoteProperty -Name "Format" -Value $p.Format
    $result += $obj
}
$result | Export-Csv "PS_EnumParameters_FinalParams.csv" -NoTypeInformation -Encoding UTF8

