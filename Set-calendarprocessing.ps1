# Connect to Exchange Online
Connect-ExchangeOnline -DelegatedOrganization -ShowProgress $true

# Import the CSV file with room mailbox names
$roomMailboxes = Import-Csv -Path "C:\Temp\RoomMailboxes.csv"

# Define the user or group you want to grant access rights to
$grantees = Import-Csv -Path "C:\Temp\grantees.csv"

# Iterate through each Grantee in the CSV file and grant the access rights
foreach ($granteename in $grantees) {
    $granteeuser = $granteename.granteename 
    #write-host $granteeuser
    
# Iterate through each room mailbox in the CSV file and grant the access rights
foreach ($roomMailbox in $roomMailboxes) {
    $roomMailboxName = $roomMailbox.RoomMailboxName
    #write-host $roomMailboxname
    
        # Set the permissions on the room mailbox
        Add-MailboxPermission -Identity $roomMailboxName -User $granteeuser -AccessRights FullAccess -AutoMapping $false
  
  	    # Set the resource delegates for the room mailbox
	    set-CalendarProcessing -Identity $roomMailboxName -ResourceDelegates User1, User2
      }
         
}

foreach ($roomMailbox in $roomMailboxes) {
    $roomMailboxName = $roomMailbox.RoomMailboxName

    Write-host Rechten voor $roomMailboxName
    Get-MailboxPermission -Identity $roommailboxname | Select-Object User,AccessRights | Where-Object {$_.User.ToString() -ne "NT AUTHORITY\SELF"}
    
    Write-host Delegate rechten voor $roomMailboxName
    Get-CalendarProcessing -Identity $roommailboxname | Select-Object -ExpandProperty ResourceDelegates
}
# Disconnect from Exchange Online
Disconnect-ExchangeOnline -Confirm:$false
