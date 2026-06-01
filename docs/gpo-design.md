# GPO Design

## Overview

Group Policy is used for two purposes in this lab: security enforcement and user environment configuration. GPOs are linked at the appropriate level — domain root for broad policies, department OUs for targeted settings.

## GPO inventory

| GPO | Linked to | Status |
|---|---|---|
| Default Domain Policy | DC=corp,DC=local | Active (built-in) |
| Security Baseline | DC=corp,DC=local | Active |
| Drive Mapping | DC=corp,DC=local | Active |
| GPO_HR_Policy | OU=HR,OU=User Accounts | Active |
| GPO_Sales_Policy | OU=Sales,OU=User Accounts | Active |
| GPO_IT_Policy | OU=IT,OU=User Accounts | Active |
| GPO_Finance_Policy | OU=Finance,OU=User Accounts | Active |

---

## Security Baseline GPO

Linked to domain root. Applies to all computers and users in corp.local.

### Password policy

| Setting | Value |
|---|---|
| Minimum password length | 12 characters |
| Password must meet complexity requirements | Enabled |
| Maximum password age | 90 days |
| Minimum password age | 1 day |

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

---

## Drive Mapping GPO

Linked to domain root. Item-level targeting by security group SID — only members of the relevant group receive the mapped drive.

| Drive | UNC Path | Label | Target Group | SID |
|---|---|---|---|---|
| H: | \\FS01\HR | HR | GG_HR | S-1-5-21-824142876-980016438-2925638321-1103 |
| S: | \\FS01\Sales | Sales | GG_Sales | S-1-5-21-824142876-980016438-2925638321-1104 |
| I: | \\FS01\IT | IT | GG_IT | S-1-5-21-824142876-980016438-2925638321-1105 |
| F: | \\FS01\Finance | Finance | GG_Finance | S-1-5-21-824142876-980016438-2925638321-1106 |

Action: Replace. Reconnect: Enabled.

> **Note:** Windows 11 requires explicit SID values in the `FilterGroup` XML within `Drives.xml` in SYSVOL. Group name alone is not resolved at login. SIDs were patched directly into the XML after initial GPMC configuration.

---

## Department GPOs

### GPO_HR_Policy
Linked to: `OU=HR,OU=User Accounts,DC=corp,DC=local`

| Setting | Path | Value |
|---|---|---|
| All Removable Storage classes: Deny all access | User Config → Policies → Admin Templates → System → Removable Storage Access | Enabled |
| Prohibit access to Control Panel and PC Settings | User Config → Policies → Admin Templates → Control Panel | Enabled |

### GPO_Finance_Policy
Linked to: `OU=Finance,OU=User Accounts,DC=corp,DC=local`

| Setting | Path | Value |
|---|---|---|
| All Removable Storage classes: Deny all access | User Config → Policies → Admin Templates → System → Removable Storage Access | Enabled |
| Prohibit access to Control Panel and PC Settings | User Config → Policies → Admin Templates → Control Panel | Enabled |

### GPO_Sales_Policy
Linked to: `OU=Sales,OU=User Accounts,DC=corp,DC=local`

| Setting | Path | Value |
|---|---|---|
| Default browser homepage | User Config → Preferences → Windows Settings → Registry | HKCU\Software\Microsoft\Internet Explorer\Main → Start Page (REG_SZ) |

### GPO_IT_Policy
Linked to: `OU=IT,OU=User Accounts,DC=corp,DC=local`

No restrictions applied. IT staff have full access to all system tools and features. This GPO is intentionally permissive and exists to confirm correct scoping — IT users should NOT receive HR or Finance restrictions.

---

## GPO inheritance and scoping

```
corp.local (domain root)
├── Default Domain Policy      → all users and computers
├── Security Baseline          → all users and computers
├── Drive Mapping              → all users (filtered by group SID)
│
└── User Accounts
    ├── HR      → GPO_HR_Policy
    ├── Sales   → GPO_Sales_Policy
    ├── IT      → GPO_IT_Policy
    └── Finance → GPO_Finance_Policy
```

Department GPOs only apply to users in their respective OUs. A user in the HR OU receives: Default Domain Policy + Security Baseline + Drive Mapping + GPO_HR_Policy.

---

## Verification commands

```powershell
# Check GPOs applied to current user/machine
gpresult /r

# Force GPO refresh
gpupdate /force

# Generate full HTML GPO report
gpresult /h C:\temp\gpresult.html /f
start C:\temp\gpresult.html

# List all GPO links on domain
Get-GPInheritance -Target "DC=corp,DC=local" |
    Select-Object -ExpandProperty GpoLinks |
    Format-Table DisplayName, Enabled, Enforced

# List all GPOs
Get-GPO -All |
    Select-Object DisplayName, GpoStatus |
    Format-Table -AutoSize
```

---

## PowerShell to recreate GPO structure

```powershell
$domain = "DC=corp,DC=local"
$userAccounts = "OU=User Accounts,$domain"

# Create GPOs
New-GPO -Name "Security Baseline"   -Comment "Domain-wide security baseline"
New-GPO -Name "Drive Mapping"       -Comment "Department drive mapping with item-level targeting"
New-GPO -Name "GPO_HR_Policy"       -Comment "HR department policy"
New-GPO -Name "GPO_Sales_Policy"    -Comment "Sales department policy"
New-GPO -Name "GPO_IT_Policy"       -Comment "IT department policy"
New-GPO -Name "GPO_Finance_Policy"  -Comment "Finance department policy"

# Link GPOs
New-GPLink -Name "Security Baseline"   -Target $domain -Enforced Yes
New-GPLink -Name "Drive Mapping"       -Target $domain
New-GPLink -Name "GPO_HR_Policy"       -Target "OU=HR,$userAccounts"
New-GPLink -Name "GPO_Sales_Policy"    -Target "OU=Sales,$userAccounts"
New-GPLink -Name "GPO_IT_Policy"       -Target "OU=IT,$userAccounts"
New-GPLink -Name "GPO_Finance_Policy"  -Target "OU=Finance,$userAccounts"
```
