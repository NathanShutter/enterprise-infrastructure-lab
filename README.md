# Enterprise Infrastructure Lab

> Simulating a real-world SMB/MSP-style Active Directory environment on VMware Workstation — built to demonstrate enterprise infrastructure skills across identity management, Group Policy, file services, network segmentation, and infrastructure automation.

![Status](https://img.shields.io/badge/status-in%20progress-blue)
![Platform](https://img.shields.io/badge/platform-VMware%20Workstation-lightgrey)
![OS](https://img.shields.io/badge/OS-Windows%20Server%202022-0078D4)
![License](https://img.shields.io/badge/license-MIT-green)

---

## Overview

This project builds a fully functional enterprise Active Directory lab from scratch — designed to mirror the kind of environment you'd find at a small-to-medium business or MSP client. Every component is documented, scripted where possible, and tracked through GitHub Issues by phase.

The end goal is a fully reproducible lab deployable via Terraform in a single command.

---

## Environment

| Component | Details |
|---|---|
| Hypervisor | VMware Workstation Pro |
| Network | Internal only — 10.10.10.0/24 |
| Domain | corp.local |
| Domain Controller | DC01 — 10.10.10.10 |
| Workstation | WS01 — 10.10.10.20 (Windows 11) |
| File Server | FS01 — 10.10.10.30 (Windows Server 2022) |
| Firewall | pfSense *(planned)* |

---

## Progress

### Phase 1 — Foundation ✅
- [x] DC01 deployed on Windows Server 2022
- [x] Active Directory Domain Services installed
- [x] corp.local domain created and validated
- [x] DNS configured — forward and reverse lookup zones
- [x] DNS validated with `dcdiag /test:dns`
- [x] IPv6 disabled on all NICs for lab stability
- [x] Full OU structure built (AGDLP model)

### Phase 2 — Identity ✅
- [x] 9 department users created via PowerShell CSV script
- [x] 5 security groups created with GG_ naming convention
- [x] Group membership assigned per department
- [x] WS01 deployed (Windows 11), joined to corp.local
- [x] WS01 moved to Workstations OU
- [x] Security baseline GPO applied and verified with `gpresult /r`

### Phase 3 — File Services ✅
- [x] FS01 deployed (Windows Server 2022), joined to corp.local
- [x] FS01 moved to Servers OU
- [x] File and Storage Services role installed
- [x] Department shares created: HR, Sales, Finance, IT
- [x] NTFS permissions applied via security groups (inheritance disabled)
- [x] Drive mapping GPO configured with item-level targeting by security group
- [x] SID-based group targeting fixed for Windows 11 compatibility
- [x] H: drive verified mapping automatically at login for hr.david

### Phase 4 — Group Policy ✅
- [x] Department-scoped GPOs per OU (HR, Sales, IT, Finance)
- [x] Advanced audit policy configured in Security Baseline GPO
- [x] USB storage restricted for HR and Finance via GPO

### Phase 5 — Network Segmentation 🔄
- [ ] pfSense VM deployed (3-NIC)
- [ ] VLAN 10 — servers (10.10.10.0/24)
- [ ] VLAN 20 — clients (10.10.20.0/24)
- [ ] Inter-VLAN routing and firewall rules

### Phase 6 — Automation / IaC 📋
- [ ] Terraform initialized with VMware vSphere provider
- [ ] Modules: domain-controller, workstation, file-server
- [ ] Full lab deploy with `terraform apply`

### Phase 7 — Portfolio Documentation 📋
- [ ] Network topology diagram
- [ ] Portfolio case study on personal site

---

## AD Design

### OU Structure

```
corp.local
├── _Admin
│   ├── Admin Users          # privileged admin accounts (adm.firstname)
│   └── Service Accounts     # service/application accounts
├── User Accounts
│   ├── HR
│   ├── Sales
│   ├── IT
│   ├── Finance
│   └── Disabled             # offboarded users staged for deletion
├── Workstations             # all domain-joined workstations
├── Servers                  # member servers (FS01, etc)
└── Groups                   # all security groups
```

### AGDLP Permission Model

Users are never assigned permissions directly. The chain is:

```
hr.david  (User Accounts/HR OU)
    └── member of GG_HR  (Groups OU)
            └── Modify on \\FS01\HR  (NTFS)
                    └── H: drive mapped at login  (GPO, item-level targeting by SID)
```

OUs handle organization and GPO targeting. Groups handle permissions.

### Security Groups

| Group | SID | Members |
|---|---|---|
| GG_HR | S-1-5-21-...-1103 | hr.david, hr.sarah |
| GG_Sales | S-1-5-21-...-1104 | sales.james, sales.emily |
| GG_IT | S-1-5-21-...-1105 | it.ryan, it.laura |
| GG_Finance | S-1-5-21-...-1106 | finance.mark, finance.jessica |
| GG_IT_Admins | — | it.ryan |

---

## File Share Permissions

| Share | UNC Path | Group | NTFS Permission |
|---|---|---|---|
| HR | `\\FS01\HR` | GG_HR | Modify |
| Sales | `\\FS01\Sales` | GG_Sales | Modify |
| Finance | `\\FS01\Finance` | GG_Finance | Modify |
| IT | `\\FS01\IT` | GG_IT | Modify |
| All | All shares | Domain Admins | Full Control |

---

## GPO Summary

| GPO | Linked to | Purpose |
|---|---|---|
| Default Domain Policy | Domain root | Built-in defaults |
| Security Baseline | Domain root | Password, lockout, audit policy |
| Drive Mapping | Domain root | Department drive maps (item-level targeting by SID) |
| GPO_HR_Policy | OU=HR | Department restrictions *(planned)* |
| GPO_Sales_Policy | OU=Sales | Department restrictions *(planned)* |
| GPO_IT_Policy | OU=IT | Department restrictions *(planned)* |
| GPO_Finance_Policy | OU=Finance | Department restrictions *(planned)* |

---

## Repo Structure

```
enterprise-infrastructure-lab/
├── README.md
├── docs/
│   ├── architecture.md       # VM specs, network design, design rationale
│   ├── ou-structure.md       # Full OU tree and GPO targeting table
│   ├── permissions.md        # NTFS permissions and access matrix
│   └── gpo-design.md         # GPO inventory and settings
├── scripts/
│   ├── ad/
│   │   ├── New-LabUsers.ps1  # Bulk user creation from CSV
│   │   └── users.csv         # User data
│   └── fs/
│       └── New-Shares.ps1    # Share creation and NTFS permissions
└── terraform/
    ├── main.tf               # *(planned)*
    ├── variables.tf          # *(planned)*
    └── modules/
        ├── domain-controller/
        ├── workstation/
        └── file-server/
```

---

## Notable Troubleshooting

**Drive mapping GPO not applying on Windows 11**
GPO drive map preferences require explicit SID values in the `FilterGroup` XML. Windows 11 will not resolve group names alone at login time. Fixed by patching `Drives.xml` in SYSVOL with the correct SID for each security group.

**FS01 ping timeout**
Ping to FS01 times out from DC01 and WS01 due to Windows Firewall blocking ICMP. SMB traffic works correctly — `Test-Path \\FS01\HR` returns True and shares are fully accessible.

**FS01 domain join**
Initial domain join completed on the client but the computer object was not created in AD. Resolved by removing the computer from the domain and rejoining with `Add-Computer`.

---

## Skills Demonstrated

- Active Directory design — OU structure, AGDLP RBAC model
- DNS configuration and validation (`dcdiag`, `nslookup`, reverse lookup zones)
- Group Policy — security baseline, drive mapping with SID-based item-level targeting
- File server deployment and NTFS permission management
- PowerShell automation — bulk user/group creation, share provisioning
- Real-world troubleshooting — GPO SID resolution, domain join issues, IPv6 interference
- Network segmentation — VLANs, inter-VLAN routing, firewall rules *(planned)*
- Infrastructure as Code — Terraform + VMware vSphere provider *(planned)*

---

## How to Reproduce

> Full Terraform-based reproduction coming in Phase 6.

**Manual setup (current):**
1. Install VMware Workstation Pro
2. Create an internal-only virtual network (no NAT)
3. Deploy Windows Server 2022 VM — DC01 at 10.10.10.10
4. Install AD DS, promote as DC, create corp.local
5. Follow phases 1–3 using scripts in `/scripts`

---

## Roadmap

Full task board tracked via [GitHub Issues](https://github.com/NathanShutter/enterprise-infrastructure-lab/issues) organized by phase label.

---

## Connect

**Portfolio:** [n8shutter.dev](https://n8shutter.dev)
