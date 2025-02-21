# Import the Active Directory module
Import-Module ActiveDirectory

# Define the number of days to check for last logon for users and computers
$userDaysThreshold = 90
$computerDaysThreshold = 180

# Get the current date
$currentDate = Get-Date

# Calculate the threshold dates
$userThresholdDate = $currentDate.AddDays(-$userDaysThreshold)
$computerThresholdDate = $currentDate.AddDays(-$computerDaysThreshold)

# Get all users who haven't logged in within the last 90 days and are not disabled
$inactiveUsers = Get-ADUser -Filter {LastLogonDate -lt $userThresholdDate -and Enabled -eq $true} -Properties LastLogonDate,Enabled

# Get all computers that haven't logged in within the last 180 days and are not disabled
$inactiveComputers = Get-ADComputer -Filter {LastLogonDate -lt $computerThresholdDate -and Enabled -eq $true} -Properties LastLogonDate,Enabled

# Display the results for inactive users
foreach ($user in $inactiveUsers) {
    Write-Host "User $($user.SamAccountName)"
}

# Display the results for inactive computers
foreach ($computer in $inactiveComputers) {
    Write-Host "Computer $($computer.Name)"
}

# Define the output file path in the same directory as the script
$outputFile = Join-Path -Path $PSScriptRoot -ChildPath "Aged Accounts.txt"

# Prepare the output content
$outputContent = @()

# Add the results for inactive users to the output
$outputContent += "Inactive Users:"
foreach ($user in $inactiveUsers) {
    $outputContent += "User $($user.SamAccountName)"
}

# Add the results for inactive computers to the output
$outputContent += "`nInactive Computers:"
foreach ($computer in $inactiveComputers) {
    $outputContent += "Computer $($computer.Name)"
}

# Export the results to the Notepad file
$outputContent | Out-File -FilePath $outputFile -Encoding UTF8

# Optional: Open the file in Notepad
Start-Process notepad.exe $outputFile