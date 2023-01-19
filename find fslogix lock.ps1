


#Locatie OU van Servers
$OU = "ou=Virtual desktops,ou=workstations,ou=ap,DC=ambitiouspeople,DC=nl"
# Locatie van bestand online avds. 
$fileonlineavds = "c:\bsu\Find_FSLogix_Profile_Script\onlineavds.txt"
# Locatie van bestand AVD Namen.
$outputavds = "C:\bsu\Find_FSLogix_Profile_Script\avd-namen.txt"
# Locatie van Lijst met Schijven.
$avddisks = "C:\bsu\Find_FSLogix_Profile_Script\avddisks.txt"

#tijd tot het controleren van de online avds - Default 5 min
$date = (Get-Date).AddMinutes(-5)
#tijd tot het controleren van de avds - Default 8 uur
$dateavd = (Get-Date).AddMinutes(-480)

$outputonlineavds = @()
$output = @()
$outputavddisks = @()
$final = @()


$check = Get-Item $fileonlineavds | where-object {$_.LastWriteTime -gt $date}
$checkavd = get-item $outputavds | where-object {$_.LastWriteTime -gt  $dateavd} 

$avds = Get-Content $outputavds

$onlineavds = Get-Content $fileonlineavds


if($checkavd){
         Write-host "AVD Lijst niet ouder als 8 uur"
}      
else{
Write-host "AVd Lijst is ouder als 8 uur, Ik ga hem nu opnieuw bouwen"
$Computers = Get-ADComputer -SearchBase $OU -Filter *
$Computers | Select-Object -ExpandProperty Name | Out-File  $outputavds
}

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
Write-host "Ik ga nu een lijst maken met alle disks"
Foreach ($onlineavd in $onlineavds)  {
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

cls
$final
