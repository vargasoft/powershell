
################################################
#short ps convert csv to json for postman
################################################


#VARIABLES

$csvfile = "PROD ForAsset Afo.csv"

$jsonfile = "PROD ForAsset Afo.json"


################################################

$filename = (Get-Item -Path ".\").FullName + "\" + $csvfile
#Write-Host $filename
$outputfile = (Get-Item -Path ".\").FullName + "\" + $jsonfile
#Write-Host $outputfile

################################################
#CONVERT:
################################################

#Info: Foreach replaces "" if numers are in csv

$topicsjson = import-csv -Delimiter "`;" $filename | ConvertTo-Json -Compress | 
    Foreach {$_ -creplace '"NULL"','null' -replace ':"([0-9]+)"',':$1'} | Out-File $outputfile 

################################################
