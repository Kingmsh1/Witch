# Witch

Witch is a Bash tool used to automate scanning, enumeration and early exploitation of a target in a penetration test engagement.

Its overall aim is to provide a structured workflow for engagements, helping to guide testers who are relatively new to using Linux and cybersecurity. It also removes the need to memorise different tools and their syntax as Witch automates tool usage and report generation.

The tool performs:

- Target scanning
- Service identification
- Vulnerability discovery
- CVE extraction and severity classification (CVSS-based)
- Report generation

## Features

- Automated Nmap scanning
- CVE extraction using the Vulners script
- CVSS severity classification
- FTP enumeration
- SMB enumeration
- Web enumeration
- SQLi testing
- Automated report generation
- Dependency management
- Debian package distribution

## How It Works
Witch has a modular design with different components:

- Resource acquisition
- Dependency validation
- Network scanning
- Service extraction & enumeration
- Vulnerability extraction
- Port categorisation
- Report generation

Each of these stages were implemented as independent Bash functions for maintainability and scalability purposes.

## Workflow

Target -> Nmap Scan -> Service Extraction -> CVE Extraction -> Port Categorisation -> Enumeration -> Report Generation

## Supported Services

Supported services may vary based on different versions of the tool. 

v1.0.0: Support for FTP (port 21), HTTP (port 80), HTTPS (port 443), SMB (ports 139/445), SQL (ports 3306/5432)

## Notable Features

### CVSS Severity Classification
Automatically categorises discovered CVE severity into:

- Critical
- High
- Medium
- Low

based on CVSS scores.

### Modular Design
Functionality is separated into purpose-specific functions for easier maintainability and expansion.

### Automated Workflow
Reduces manual effort by chaining scanning, enumeration and exploitation tools. Generates assessment reports automatically.

## Potential Future Improvements

Planned features:

- Active Directory enumeration support
- SSH enumeration support
- DNS enumeration support
- JSON report export
- Improved UI/UX

## Known Limitations

- Requires root privileges for some operations
- Limited protocol support
- SQL services are currently detected but the tool lacks enumeration/exploitation support

## Tools Used

- Bash shell
- Nmap
- Vulners
- FFUF
- SQLMap
- Enum4Linux
- SMBClient

## Installation
### Step 1:
```bash
git clone https://github.com/Kingmsh1/Witch.git
```
### Step 2:
```bash
cd Witch
```

### Step 3:
```bash
sudo dpkg -i witch_1.0.0.deb
```

### Step 4:
Launch with:
```bash
witch
```
