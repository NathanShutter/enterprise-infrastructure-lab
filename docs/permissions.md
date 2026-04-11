# Permissions

## Model

Permissions follow a simplified AGDLP model:

```
User Account → Global Security Group → NTFS Permission → Resource
```

Users are never granted permissions directly. All access is managed through group membership.

## Security groups

| Group | SAMAccountName | Scope | Members |
|---|---|---|---|
| GG_HR | GG_HR | Global Security | hr.david, hr.sarah |
| GG_Sales | GG_Sales | Global Security | sales.james, sales.emily |
| GG_IT | GG_IT | Global Security | it.ryan, it.laura |
| GG_Finance | GG_Finance | Global Security | finance.mark, finance.jessica |
| GG_IT_Admins | GG_IT_Admins | Global Security | it.ryan |

All groups reside in: `OU=Groups,DC=corp,DC=local`

## File share permissions

### Share-level permissions

| Share | Path on FS01 | UNC Path | Share Permission |
|---|---|---|---|
| HR | C:\Shares\HR | \\FS01\HR | Domain Admins — Full Control |
| Sales | C:\Shares\Sales | \\FS01\Sales | Domain Admins — Full Control |
| Finance | C:\Shares\Finance | \\FS01\Finance | Domain Admins — Full Control |
| IT | C:\Shares\IT | \\FS01\IT | Domain Admins — Full Control |

> Share-level permissions are intentionally restrictive. NTFS permissions control actual access.

### NTFS permissions

| Share | Identity | Permission | Inherited |
|---|---|---|---|
| HR | CORP\GG_HR | Modify | No |
| HR | CORP\Domain Admins | Full Control | No |
| Sales | CORP\GG_Sales | Modify | No |
| Sales | CORP\Domain Admins | Full Control | No |
| Finance | CORP\GG_Finance | Modify | No |
| Finance | CORP\Domain Admins | Full Control | No |
| IT | CORP\GG_IT | Modify | No |
| IT | CORP\Domain Admins | Full Control | No |

Inheritance is disabled on all share folders. Permissions are set explicitly.

## Drive mappings

| Drive Letter | Share | Mapped via | Targeting |
|---|---|---|---|
| H: | \\FS01\HR | Drive Mapping GPO | GG_HR member |
| S: | \\FS01\Sales | Drive Mapping GPO | GG_Sales member |
| F: | \\FS01\Finance | Drive Mapping GPO | GG_Finance member |
| I: | \\FS01\IT | Drive Mapping GPO | GG_IT member |

## Access matrix

| User | HR | Sales | Finance | IT |
|---|---|---|---|---|
| hr.david | ✅ Modify | ❌ Denied | ❌ Denied | ❌ Denied |
| hr.sarah | ✅ Modify | ❌ Denied | ❌ Denied | ❌ Denied |
| sales.james | ❌ Denied | ✅ Modify | ❌ Denied | ❌ Denied |
| sales.emily | ❌ Denied | ✅ Modify | ❌ Denied | ❌ Denied |
| it.ryan | ❌ Denied | ❌ Denied | ❌ Denied | ✅ Modify |
| it.laura | ❌ Denied | ❌ Denied | ❌ Denied | ✅ Modify |
| finance.mark | ❌ Denied | ❌ Denied | ✅ Modify | ❌ Denied |
| finance.jessica | ❌ Denied | ❌ Denied | ✅ Modify | ❌ Denied |
| adm.nathan | ✅ Full Control | ✅ Full Control | ✅ Full Control | ✅ Full Control |

## PowerShell to verify permissions

```powershell
# Check NTFS permissions on a share
Get-Acl "C:\Shares\HR" | Select-Object -ExpandProperty Access |
    Where-Object {$_.IdentityReference -like "corp\*"} |
    Select-Object IdentityReference, FileSystemRights |
    Format-Table -AutoSize

# Check group membership
Get-ADGroupMember -Identity "GG_HR" |
    Select-Object Name, SamAccountName |
    Format-Table -AutoSize
```
