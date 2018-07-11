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
$trips = $c.DownloadString("$URL/GetTrips?schemaID=$schemaID&IDs=$deviceID&SD=20180201-0000&ED=20180210-0000&tripSplitterIndex=0") | ConvertFrom-Json

$result =@()
$i = 0;
$value = $trips.psobject.Properties.Item($deviceID).Value;

foreach($trip in $value.Trips)
{
    "Trip #$i"
    
    $stage = $trip.Stages | where { $_.Name -eq "Motion" } # select "Motion" stage

    $parmDateFrom = $stage.Params.IndexOf("DateTime First")
    $parmDateTo = $stage.Params.IndexOf("DateTime Last")
    $parmTotalDuration = $stage.Params.IndexOf("TotalDuration")
    $parmMoveDuration = $stage.Params.IndexOf("MoveDuration")

    foreach($stageItem in $stage.Items)
    {
        $obj = New-Object PSObject
        $obj | Add-Member -MemberType NoteProperty -Name "TripIndex" -Value $i
        $obj | Add-Member -MemberType NoteProperty -Name "Index" -Value $stageItem.Index
        $obj | Add-Member -MemberType NoteProperty -Name "Caption" -Value $stageItem.Caption
        $obj | Add-Member -MemberType NoteProperty -Name "DateTimeFrom" -Value $stageItem.Values[$parmDateFrom]
        $obj | Add-Member -MemberType NoteProperty -Name "DateTimeTo" -Value $stageItem.Values[$parmDateTo]
        $obj | Add-Member -MemberType NoteProperty -Name "Duration" -Value $stageItem.Values[$parmTotalDuration]
        $obj | Add-Member -MemberType NoteProperty -Name "MoveDuration" -Value $stageItem.Values[$parmMoveDuration]
        $result += $obj
    }
    $i++;
}
$result | Export-Csv "PS_GetStage_Motion.csv" -NoTypeInformation -Encoding UTF8

