$csvPath = "C:\Scripts\users.csv"
$domain = "corp.local"
$users = Import-Csv $csvPath

foreach ($user in $users) {
    $upn = $user.Username + "@" + $domain

    $ouMap = @{
        "HR"          = "OU=HR,OU=User Accounts,DC=corp,DC=local"
        "Sales"       = "OU=Sales,OU=User Accounts,DC=corp,DC=local"
        "IT"          = "OU=IT,OU=User Accounts,DC=corp,DC=local"
        "Finance"     = "OU=Finance,OU=User Accounts,DC=corp,DC=local"
        "Admin Users" = "OU=Admin Users,OU=_Admin,DC=corp,DC=local"
    }

    $targetOU = $ouMap[$user.OU]
    $securePass = ConvertTo-SecureString $user.Password -AsPlainText -Force

    try {
        New-ADUser `
            -GivenName            $user.FirstName `
            -Surname              $user.LastName `
            -Name                 ($user.FirstName + " " + $user.LastName) `
            -SamAccountName       $user.Username `
            -UserPrincipalName    $upn `
            -Path                 $targetOU `
            -AccountPassword      $securePass `
            -ChangePasswordAtLogon $true `
            -Enabled              $true `
            -Department           $user.Department

        Write-Host ("Created: " + $user.Username + " in " + $targetOU) -ForegroundColor Green
    }
    catch {
        Write-Host ("Failed: " + $user.Username + " -- " + $_) -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Done. Verifying..." -ForegroundColor Cyan

Write-Host ""
Write-Host "--- User Accounts OU ---" -ForegroundColor Yellow
Get-ADUser -Filter * -SearchBase "OU=User Accounts,DC=corp,DC=local" -Properties Department |
    Select-Object Name, SamAccountName, Department |
    Sort-Object Department |
    Format-Table -AutoSize

Write-Host "--- Admin Users OU ---" -ForegroundColor Yellow
Get-ADUser -Filter * -SearchBase "OU=Admin Users,OU=_Admin,DC=corp,DC=local" |
    Select-Object Name, SamAccountName |
    Format-Table -AutoSize
