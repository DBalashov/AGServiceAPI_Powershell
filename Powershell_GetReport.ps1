$URL = "http://m.tk-chel.ru/ServiceJSON";
$SCHEMA = "DemoCEBIT"
$userName = "demo"
$userPassword = "demo"

$c = New-Object -TypeName System.Net.WebClient;
$c.Encoding = [System.Text.Encoding]::UTF8
$c.Headers.Add("Content-Type", "text/json");
$token = $c.DownloadString("$URL/Login?UserName=$userName&Password=$userPassword").Trim("""");
$c.Headers.Add("AG-TOKEN", $token)

$deviceID = "d090286c-1fd6-4ef2-ae44-8091d04408d1"  # GAZell
$parameters = $c.DownloadString("$URL/EnumReports") | ConvertFrom-Json

$reportName = $parameters | where { $_ -eq "Trips.frx" }

$schemaID = (($c.DownloadString("$URL/EnumSchemas") | ConvertFrom-Json) | where { $_.Name -eq $SCHEMA }).ID
$data = $c.DownloadData("$URL/GetReport?schemaID=$schemaID&IDs=$deviceID&reportName=$reportName&SD=20180201-0000&ED=20180210-0000&splitToTrips=0&format=1")

[System.IO.File]::WriteAllBytes("PS_Trips.pdf", $data)

