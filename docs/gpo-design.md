# GPO Design

## Overview

Group Policy is used for two purposes in this lab: security enforcement and user environment configuration. GPOs are linked at the appropriate level — domain root for broad policies, department OUs for targeted settings.

## GPO inventory

| GPO | Linked to | Type | Status |
|---|---|---|---|
| Default Domain Policy | DC=corp,DC=local | Built-in | Active |
| Security Baseline | DC=corp,DC=local | Custom | Active |
| Drive Mapping | DC=corp,DC=local | Custom | Active |
| GPO_HR_Policy | OU=HR,OU=User Accounts | Custom | Planned |
| GPO_Sales_Policy | OU=Sales,OU=User Accounts | Custom | Planned |
| GPO_IT_Policy | OU=IT,OU=User Accounts | Custom | Planned |
| GPO_Finance_Policy | OU=Finance,OU=User Accounts | Custom | Planned |

## Security Baseline GPO

Linked to domain root. Applies to all computers and users.

### Password policy

| Setting | Value |
|---|---|
| Minimum password length | 12 characters |
| Password must meet complexity requirements | Enabled |
| Maximum password age | 90 days |
| Minimum password age | 1 day |
| Enforce password history | 10 passwords |

### Account lockout policy

| Setting | Value |
|---|---|
| Account lockout threshold | 5 invalid attempts |
| Account lockout duration | 30 minutes |
| Reset account lockout counter after | 30 minutes |

### Audit policy

| Setting | Value |
|---|---|
| Audit account logon events | Success, Failure |
| Audit account management | Success, Failure |
| Audit logon events | Success, Failure |
| Audit object access | Failure |
| Audit privilege use | Failure |

## Drive Mapping GPO

Linked to domain root with item-level targeting. Applies based on group membership.

| Drive | Path | Label | Target group |
|---|---|---|---|
| H: | \\FS01\HR | HR | CORP\GG_HR |
| S: | \\FS01\Sales | Sales | CORP\GG_Sales |
| F: | \\FS01\Finance | Finance | CORP\GG_Finance |
| I: | \\FS01\IT | IT | CORP\GG_IT |

Action: Replace. Reconnect: Enabled.

## Department GPO settings (planned)

### GPO_HR_Policy and GPO_Finance_Policy
- Disable USB storage devices
- Remove Control Panel from Start Menu
- Set screen lock timeout to 10 minutes

### GPO_Sales_Policy
- Set browser homepage to intranet
- Set screen lock timeout to 15 minutes

### GPO_IT_Policy
- Allow PowerShell execution
- Allow remote management tools
- No USB restrictions

## Verification commands

```powershell
# Check GPOs applied to a machine or user
gpresult /r

# Force GPO refresh
gpupdate /force

# Check GPO links on domain
Get-GPInheritance -Target "DC=corp,DC=local" |
    Select-Object -ExpandProperty GpoLinks |
    Format-Table DisplayName, Enabled, Enforced

# List all GPOs
Get-GPO -All | Select-Object DisplayName, GpoStatus | Format-Table -AutoSize
```
