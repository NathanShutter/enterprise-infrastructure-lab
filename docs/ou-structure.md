# OU Structure

## Full hierarchy

```
corp.local
├── _Admin
│   ├── Admin Users
│   └── Service Accounts
├── User Accounts
│   ├── HR
│   ├── Sales
│   ├── IT
│   ├── Finance
│   └── Disabled
├── Workstations
├── Servers
├── Groups
└── Domain Controllers  (default — do not modify)
```

## OU descriptions

| OU | Path | Purpose |
|---|---|---|
| _Admin | OU=_Admin,DC=corp,DC=local | Container for all privileged accounts |
| Admin Users | OU=Admin Users,OU=_Admin,DC=corp,DC=local | Named admin accounts (adm.firstname) |
| Service Accounts | OU=Service Accounts,OU=_Admin,DC=corp,DC=local | Application and service accounts |
| User Accounts | OU=User Accounts,DC=corp,DC=local | Container for all standard users |
| HR | OU=HR,OU=User Accounts,DC=corp,DC=local | HR department users |
| Sales | OU=Sales,OU=User Accounts,DC=corp,DC=local | Sales department users |
| IT | OU=IT,OU=User Accounts,DC=corp,DC=local | IT department users |
| Finance | OU=Finance,OU=User Accounts,DC=corp,DC=local | Finance department users |
| Disabled | OU=Disabled,OU=User Accounts,DC=corp,DC=local | Offboarded users pending deletion |
| Workstations | OU=Workstations,DC=corp,DC=local | All domain-joined workstations |
| Servers | OU=Servers,DC=corp,DC=local | All member servers |
| Groups | OU=Groups,DC=corp,DC=local | All security groups |

## GPO targeting

| GPO | Linked to | Scope |
|---|---|---|
| Security Baseline | DC=corp,DC=local | All computers and users in domain |
| Drive Mapping | DC=corp,DC=local | All users (item-level targeting by group) |
| GPO_HR_Policy | OU=HR,OU=User Accounts | HR users only |
| GPO_Sales_Policy | OU=Sales,OU=User Accounts | Sales users only |
| GPO_IT_Policy | OU=IT,OU=User Accounts | IT users only |
| GPO_Finance_Policy | OU=Finance,OU=User Accounts | Finance users only |

## PowerShell to rebuild OU structure

```powershell
$d = "DC=corp,DC=local"
New-ADOrganizationalUnit -Name "_Admin"           -Path $d
New-ADOrganizationalUnit -Name "Admin Users"      -Path "OU=_Admin,$d"
New-ADOrganizationalUnit -Name "Service Accounts" -Path "OU=_Admin,$d"
New-ADOrganizationalUnit -Name "User Accounts"    -Path $d
New-ADOrganizationalUnit -Name "HR"               -Path "OU=User Accounts,$d"
New-ADOrganizationalUnit -Name "Sales"            -Path "OU=User Accounts,$d"
New-ADOrganizationalUnit -Name "IT"               -Path "OU=User Accounts,$d"
New-ADOrganizationalUnit -Name "Finance"          -Path "OU=User Accounts,$d"
New-ADOrganizationalUnit -Name "Disabled"         -Path "OU=User Accounts,$d"
New-ADOrganizationalUnit -Name "Workstations"     -Path $d
New-ADOrganizationalUnit -Name "Servers"          -Path $d
New-ADOrganizationalUnit -Name "Groups"           -Path $d
```
