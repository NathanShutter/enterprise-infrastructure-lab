# New-Shares.ps1
# Creates department file shares and sets NTFS permissions via security groups
# Run on FS01 as Administrator

$shares = @(
    @{Name="HR";      Path="C:\Shares\HR";      Group="corp\GG_HR"},
    @{Name="Sales";   Path="C:\Shares\Sales";   Group="corp\GG_Sales"},
    @{Name="Finance"; Path="C:\Shares\Finance"; Group="corp\GG_Finance"},
    @{Name="IT";      Path="C:\Shares\IT";      Group="corp\GG_IT"}
)

foreach ($share in $shares) {

    # Create folder
    New-Item -ItemType Directory -Path $share.Path -Force | Out-Null

    # Create SMB share
    New-SmbShare -Name $share.Name -Path $share.Path `
        -FullAccess "corp\Domain Admins" `
        -ReadAccess "Everyone" `
        -ErrorAction SilentlyContinue

    # Set NTFS permissions
    $acl = Get-Acl $share.Path
    $acl.SetAccessRuleProtection($true, $true)

    $modifyRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        $share.Group,
        "Modify",
        "ContainerInherit,ObjectInherit",
        "None",
        "Allow"
    )

    $adminRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        "corp\Domain Admins",
        "FullControl",
        "ContainerInherit,ObjectInherit",
        "None",
        "Allow"
    )

    $acl.AddAccessRule($modifyRule)
    $acl.AddAccessRule($adminRule)
    Set-Acl -Path $share.Path -AclObject $acl

    Write-Host ("Created share and set permissions: " + $share.Name) -ForegroundColor Green
}

Write-Host ""
Write-Host "Verifying shares..." -ForegroundColor Cyan
Get-SmbShare | Where-Object {$_.Name -in @("HR","Sales","Finance","IT")} |
    Select-Object Name, Path |
    Format-Table -AutoSize

Write-Host "Verifying NTFS permissions..." -ForegroundColor Cyan
foreach ($share in $shares) {
    Write-Host ""
    Write-Host ("--- " + $share.Path + " ---") -ForegroundColor Yellow
    Get-Acl $share.Path | Select-Object -ExpandProperty Access |
        Where-Object {$_.IdentityReference -like "corp\*"} |
        Select-Object IdentityReference, FileSystemRights |
        Format-Table -AutoSize
}
