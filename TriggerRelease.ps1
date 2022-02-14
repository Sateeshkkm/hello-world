write-host "Hello World !"

function CreateJsonBody
{
    $value = @"
{
 "definitionId":2,
 "isDraft":false,
 "manualEnvironments":[]
}
"@
 return $value
}

$uri = "https://vsrm.dev.azure.com/sateeshkkm/exampleapp/_apis/release/releases?api-version=5.0"
$json = CreateJsonBody
$header = @{Authorization = 'Basic ' +[Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$(PAT)")) }
$result = Invoke-RestMethod -Uri $uri -Body $json -Method Post -Header $header -ContentType "application/json"
write-host "Newly created release id is : " $result.id

while($TRUE){
	$release = "https://vsrm.dev.azure.com/sateeshkkm/exampleapp/_apis/release/releases/"+ $result.id + "?api-version=6.0"
	$res = Invoke-RestMethod -Uri $release -Method Get -Header $header -ContentType "application/json"
	Write-Host "Release status is : "  $res.environments[0].status
	if(($res.environments[0].status -eq 'succeeded') -OR ($res.environments[0].status -eq 'rejected')){
		write-host "condition-satisfied"
		write-host $res.environments[0].status
		break;
	}
	Start-Sleep -s $(PollingFrequencyInSeconds)
}
