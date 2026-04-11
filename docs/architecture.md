# Architecture

## Overview

The enterprise infrastructure lab simulates a real-world SMB/MSP Active Directory environment. All virtual machines run on VMware Workstation Pro on a single host machine, connected via an internal-only virtual network with no NAT or internet access.

## Design goals

- Mirror a realistic small business or MSP client environment
- Follow industry best practices for AD design, RBAC, and GPO structure
- Keep everything scripted and documented for reproducibility
- Build toward full Terraform automation in Phase 6

## Network design

All VMs share a single internal VMware virtual network. No VM has internet access by design — this isolates the lab and mirrors a segmented production environment.

```
10.10.10.0/24 — Internal lab network

10.10.10.10  — DC01  (Domain Controller)
10.10.10.20  — WS01  (Windows 11 Workstation)
10.10.10.30  — FS01  (File Server)
```

IPv6 is disabled on all NICs. DNS points exclusively to DC01 (10.10.10.10) on all machines.

## Virtual machine specs

| VM | OS | RAM | CPU | Disk | Role |
|---|---|---|---|---|---|
| DC01 | Windows Server 2022 | 4GB | 2 vCPU | 60GB | Domain Controller, DNS |
| WS01 | Windows 11 | 4GB | 2 vCPU | 60GB | Domain workstation |
| FS01 | Windows Server 2022 | 2GB | 2 vCPU | 60GB | File server |

## Domain design

| Setting | Value |
|---|---|
| Domain name | corp.local |
| Forest root | corp.local |
| Domain functional level | Windows Server 2022 |
| Forest functional level | Windows Server 2022 |
| NetBIOS name | CORP |

## DNS design

DC01 hosts the DNS Server role and is the sole DNS server for the domain.

| Zone | Type | Purpose |
|---|---|---|
| corp.local | Primary forward lookup | Resolves hostnames to IPs |
| 10.10.10.in-addr.arpa | Primary reverse lookup | Resolves IPs to hostnames |

DNS health validated with:
```powershell
dcdiag /test:dns
nslookup DC01.corp.local
nslookup 10.10.10.10
```

## OU design rationale

OUs serve two purposes only: organization and GPO targeting. They play no role in permissions — that is handled entirely by security groups.

The `_Admin` OU uses a leading underscore so it sorts to the top in ADUC, making privileged accounts immediately visible.

The `Disabled` OU holds offboarded user accounts before deletion. This provides a 30-day grace period to recover access if needed.

The `Groups` OU centralizes all security groups in one place, making the full permission model visible at a glance without hunting through department OUs.

## AGDLP model

In a single-domain environment, the simplified AGDLP chain is used:

**Account → Global Group → Permission**

Users are placed in department OUs. Permissions are granted to Global Security Groups. Groups are linked to resource permissions (NTFS, share). This means:

- Moving a user between OUs does not change their access
- Removing a user from a group immediately revokes all associated access
- Adding a new resource only requires granting the existing group

## Security baseline rationale

| Policy | Setting | Reason |
|---|---|---|
| Min password length | 12 chars | NIST SP 800-63B recommendation |
| Complexity | Enabled | Prevents simple dictionary attacks |
| Max password age | 90 days | Balance security vs usability |
| Lockout threshold | 5 attempts | Prevents brute force without over-locking |
| Lockout duration | 30 minutes | Auto-unlocks, reduces helpdesk load |
| Audit logon | Success + Failure | Detects both normal use and attacks |
