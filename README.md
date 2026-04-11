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
| Workstation | WS01 — 10.10.10.20 |
| File Server | FS01 — 10.10.10.30 |
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

### Phase 3 — File Services 🔄
- [x] FS01 deployed (Windows Server 2022), joined to corp.local
- [x] FS01 moved to Servers OU
- [x] File and Storage Services role installed
- [x] Department shares created: HR, Sales, Finance, IT
- [x] NTFS permissions applied via security groups
- [ ] Drive mapping GPO with item-level targeting
- [ ] Cross-department access denial tested and documented

### Phase 4 — Group Policy 📋
- [ ] Department-scoped GPOs per OU
- [ ] Advanced audit policy on file shares
- [ ] AppLocker / software restriction policy

### Phase 5 — Network Segmentation 📋
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
- [ ] Comprehensive README (this file — ongoing)
- [ ] Portfolio case study

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
sales.james  (User Accounts/Sales OU)
    └── member of GG_Sales  (Groups OU)
            └── Modify on \\FS01\Sales  (NTFS)
                    └── S: drive mapped at login  (GPO)
```

OUs handle organization and GPO targeting. Groups handle permissions. Keeping them separate makes both easier to manage.

### Security Groups

| Group | Members | Purpose |
|---|---|---|
| GG_HR | hr.david, hr.sarah | Access to \\FS01\HR |
| GG_Sales | sales.james, sales.emily | Access to \\FS01\Sales |
| GG_IT | it.ryan, it.laura | Access to \\FS01\IT |
| GG_Finance | finance.mark, finance.jessica | Access to \\FS01\Finance |
| GG_IT_Admins | it.ryan | Elevated IT admin access |

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

## Repo Structure

```
enterprise-infrastructure-lab/
├── README.md
├── docs/
│   ├── architecture.md
│   ├── network-diagram.png
│   ├── ou-structure.md
│   ├── permissions.md
│   └── gpo-design.md
├── scripts/
│   ├── ad/
│   │   ├── New-LabUsers.ps1
│   │   └── users.csv
│   └── fs/
│       └── New-Shares.ps1
└── terraform/
    ├── main.tf
    ├── variables.tf
    └── modules/
        ├── domain-controller/
        ├── workstation/
        └── file-server/
```

---

## Scripts

| Script | Location | Purpose |
|---|---|---|
| `New-LabUsers.ps1` | `scripts/ad/` | Bulk-creates AD users from CSV |
| `users.csv` | `scripts/ad/` | User data for New-LabUsers.ps1 |
| `New-Shares.ps1` | `scripts/fs/` | Creates shares and NTFS permissions on FS01 |

---

## Skills Demonstrated

- Active Directory design — OU structure, AGDLP RBAC model
- DNS configuration and validation (`dcdiag`, `nslookup`)
- Group Policy — security baseline, department scoping, drive mapping
- File server deployment and NTFS permission management
- PowerShell automation — bulk user/group creation, share provisioning
- Network segmentation — VLANs, inter-VLAN routing, firewall rules *(planned)*
- Infrastructure as Code — Terraform + VMware vSphere provider *(planned)*
- Technical documentation and version-controlled runbooks

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
