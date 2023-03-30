#Locatie OU van Servers
$OU = "Klant specifiek"
# Check if folder bestaat zo niet aanmaken.
$path = ".\Find_FSLogix_Profile_Script"
If(!(test-path -PathType container $path))
{
      New-Item -ItemType Directory -Path $path
}
# Locatie van bestand online avds. 
$fileonlineavds = ".\Find_FSLogix_Profile_Script\onlineavds.txt"
# Locatie van bestand AVD Namen.
$outputavds = ".\Find_FSLogix_Profile_Script\avd-namen.txt"
# Locatie van Lijst met Schijven.
$avddisks = ".\Find_FSLogix_Profile_Script\avddisks.txt"

#tijd tot het controleren van de online avds - Default 5 min
$date = (Get-Date).AddMinutes(-5)
#tijd tot het controleren van de avds - Default 8 uur
$dateavd = (Get-Date).AddMinutes(-480)

$outputonlineavds = @()
$output = @()
$outputavddisks = @()
$final = @()


$checkavd = get-item $outputavds | where-object {$_.LastWriteTime -gt  $dateavd} 


if($checkavd){
         Write-host "AVD Lijst niet ouder als 8 uur"
}      
else{
Write-host "AVd Lijst is ouder als 8 uur, Ik ga hem nu opnieuw bouwen"
$Computers = Get-ADComputer -SearchBase $OU -Filter *
$Computers | Select-Object -ExpandProperty Name | Out-File  $outputavds
}


$avds = Get-Content $outputavds
$check = Get-Item $fileonlineavds | where-object {$_.LastWriteTime -gt $date}

if($check){
         Write-host "AVD Online Lijst niet ouder als 5 min"
}      
else{
Write-host "AVD Online Lijst is ouder als 5 min, ik ga deze nu opnieuw bouwen"
foreach($avd in $avds) {
    $pingtest = Test-Connection -ComputerName $avd -Quiet -Count 1 -ErrorAction SilentlyContinue
    if($pingtest){
         $outputonlineavds +="$avd"
         Write-host "$avd is online"}
     }
     $outputonlineavds | Out-File $fileonlineavds
     }
     
Write-host "AVD Online Lijst is gebouwd"
$onlineavds = Get-Content $fileonlineavds
Write-host "Ik ga nu een lijst maken met alle disks"
Foreach ($onlineavd in $onlineavds)  {
Write-host "Disks ophalen van $onlineavd ..."
    $test = (get-volume -CimSession $onlineavd -ErrorAction SilentlyContinue | Select-Object FileSystemLabel, PsComputerName)
        if($test){
        $outputavddisks += $test
       }
}
$outputavddisks | Out-file $avddisks


$find = Read-Host -Prompt 'username'
Foreach ($outputavddisk in $outputavddisks) {
        $final += $outputavddisk | Where-Object {($_ -like "*$find*")}
}

$final
