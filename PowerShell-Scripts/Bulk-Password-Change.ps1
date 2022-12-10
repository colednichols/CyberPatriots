<#
.NOTES
  Version:        1.2
  Author:         Cole Nichols
  Creation Date:  December 11, 2021
#>

# Self-elevate script
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
 if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
  $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
  Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
  Exit
 }
}

Set-ExecutionPolicy -ExecutionPolicy unrestricted

# User list creation
Clear-Content \Users.csv
Add-Content -Path \Users.csv  -Value 'Users'
$Users = Get-Wmiobject Win32_UserAccount -filter 'LocalAccount=TRUE' | select-object -expandproperty Name
$Users | foreach { Add-Content -Path  \Users.csv -Value $_ }

# Choose password
Write-Host "Set password for all users listed in 'Users.csv'"
$SelPass = Read-Host "New Password? [Default: Password1234]"
if ($SelPass -eq '') {
	$Password = ConvertTo-SecureString -AsPlainText 'Password1234' -Force
	$DispPass = 'Password1234'
}
if ($SelPass -ne '') {
	$Password = ConvertTo-SecureString -AsPlainText $SelPass -Force
	$DispPass = $SelPass
}

# Password confirmation
Write-Host "
Password: "$DispPass
$confirmation = Read-Host "Confirm? [y/n]"
# If confirm invalid
if ($confirmation -ne 'n' -and $confirmation -ne 'y') {
	Read-Host "
	
	Invalid Input (Press ENTER to exit)"
}
# If confirm "y"
if ($confirmation -eq 'y') {
	Import-Csv "\Users.csv" | ForEach-Object {
		$User = $_."Users"
		Write-Host "------------------------------------------------------------------------------------------"
		Write-host "
		"
		Write-host "User: "$User
		Write-host "Pass: "$DispPass
		Set-LocalUser -Name $User -Password $Password -PasswordNeverExpire $false -Confirm
	}
	Write-Host "
	Passwords set to 'Password1234'
	Passwords expire
	"
}
if ($confirmation -eq 'y') {
	Read-Host "
	
	Done (Press ENTER to exit)"
}
# If confirm "n"
if ($confirmation -eq 'n') {
	Read-Host "
	
	Canceled (Press ENTER to exit)"
}
