# Import the Active Directory module
Import-Module ActiveDirectory

# Specify the group that should not be removed
$preservedGroup = "Domain Users"

# Get all disabled users in the domain
$disabledUsers = Get-ADUser -Filter {Enabled -eq $false} -Properties MemberOf

foreach ($user in $disabledUsers) {
    # Get the list of groups the user is a member of
    $groups = $user.MemberOf | ForEach-Object { (Get-ADGroup $_).Name }
    
    # Remove the user from all groups except the preserved group
    foreach ($group in $groups) {
        if ($group -ne $preservedGroup) {
            Remove-ADGroupMember -Identity $group -Members $user.SamAccountName -Confirm:$false
            Write-Host "Removed $($user.SamAccountName) from $group"
        }
    }
}

Write-Host "Script execution completed."