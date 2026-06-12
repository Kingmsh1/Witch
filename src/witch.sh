#!/bin/bash

unsupportedPorts=()
WEBWORDLIST_PATH="/usr/share/witch/directorywordlistmedium.txt"
toolsUsed=(nmap ffuf sqlmap smbclient enum4linux)

showHelp() {

        cat << EOF

=====================================================
                        WITCH
=====================================================

About:

Witch is a tool that automates the procedure of
scanning, enumeration and basic exploitation of a
target.

Witch scans a target for open ports and services. It
then reports CVE vulnerabilities related to those
open services which could potentially be exploited.

It then enumerates open ports it finds on the target
and stores the results in individual report text
files for each tool used.

-----------------------------------------------------

Usage:

  "./script [options]"

Options:
  -h, --help            Show this help menu

Example:
  sudo ./script.sh --help

-----------------------------------------------------
EOF

exit

}



getResources() {
        if [[ $EUID -ne 0 ]]; then
                echo "[!] Tool may fail while it installs/updates dependencies because you are not running as root!"
        fi

        echo "[+] Ensuring dependencies are installed and up-to-date..."

        if [ ! -f "$WEBWORDLIST_PATH" ]; then
                echo "[+] Wordlist is missing! Please reinstall the witch package"
                exit
        fi

        for tool in "${toolsUsed[@]}"
        do
                apt install -y $tool &>/dev/null
                if [[ $? -ne 0 ]]; then
                echo "[!] $tool installation failed!"
                exit
                fi
        done
}


createProjectStructure() {
        dateandtime=$(date)
        timestamp=$(date +%y%m%d_%H%M%S)
        reportdir="report/$ip-$timestamp"
        mkdir -p $reportdir
        cd $reportdir
}

runNmapScan() {
        nmap -A --script vulners -T$SPEED $IP > nmap.txt
        if [[ $? -ne 0 ]]; then
                echo "[!] Nmap scan failed! Is the host reachable?"
                exit
        fi
}

extractOpenPorts() {
        grep -E '^[0-9]+/tcp' nmap.txt > portsandservices.txt
        awk '{print $1}' portsandservices.txt | sed "s/\/tcp//g" >> openports.txt

}



extractServices() {
        while read -r line
        do
                echo "$line" | sed -E 's/^[0-9]*\/tcp[[:space:]]+open[[:space:]]+//g' >> services.txt
        done < portsandservices.txt
}

extractCVEsAndRatings() {
        grep 'CVE' nmap.txt | awk '{print $2, $3}' > cvesandratings.txt
        while read -r line
        do
                cve=$(echo "$line" | cut -d  ' ' -f1)
                rating=$(echo "$line" | cut -d ' ' -f2)
                if (( $(echo "$rating >= 9.0" | bc -l) )); then
                        severity="[CRITICAL SEVERITY]"
                elif (( $(echo "$rating >=7.0" | bc -l) )); then
                        severity="[HIGH SEVERITY]"
                elif (( $(echo "$rating >= 4.0" | bc -l) )); then
                        severity="[MEDIUM SEVERITY]"
                else
                        severity="[LOW SEVERITY]"
                fi
                echo "$cve $severity (CVSS $rating)" >> cvepresentation.txt
        done < cvesandratings.txt
}

portEnumCategorisation() {
        web="false"
        type="unknown"
        if [[ $port == "21" ]]; then
                type="ftp"
        elif [[ $port == "80" || $port == "443" ]]; then
                type="web"
                web="true"
        elif [[ $port == "445" || $port == "139" ]]; then
                type="smb"
        elif [[ $port == "3306" || $port == "5432" ]]; then
                type="sql"
        else
                type="unknown"
                unsupportedPorts+=("$port")
                echo "$port" >> unsupportedports.txt
        fi
}

enumerateFTP() {
        echo "[+] Attempting FTP into the target ..."
        ftp $IP &> ftp.txt
                if [[ $? -ne 0 ]]; then
                        echo "[!] FTP into target failed! Is the target reachable?"
                else
                        echo "[+] Results stored in ftp.txt"
                fi
}

enumerateWeb() {
echo "[+] Attempting FFUF enumeration..."
                        ffuf -w "$WEBWORDLIST_PATH" -u http://$IP/FUZZ &> ffuf.txt
                                if [[ $? -ne 0 ]]; then
                                        echo "[!] FFUF analysis failed! Is the target reachable?"
                                else
                                        echo "[+] Results stored in ffuf.txt"
                                fi
                        echo "[+] Attempting web-based SQLi..."
                        sqlmap -u "http://$ip" --dbs &> sqlmap.txt
                                if [[ $? -ne 0 ]]; then
                                        echo "[!] SQLi failed! Is the target reachable?"
                                else
                                        echo "[+] Results stored in sqlmap.txt"
                                fi
                        webenumcomplete="True"
}

enumerateSMB() {
read -p "Do you have valid credentials? (y/n): " hasCredentials
                        if [[ $hasCredentials == "y" || $hasCredentials == "Y" ]]; then
                                read -p "Enter username: " username
                                read -sp "Enter password: " password
                                echo "[+] Attempting authenticated SMB enumeration..."
                                smbclient --ip-address=$IP --user=$username%$password &> smbclient.txt
                                enum4linux -u $username -p $password -a $IP &> enum4linux.txt
                                if [[ $? -ne 0 ]]; then
                                        echo "[!] SMB enumeration failed! Is the target reachable?"
                                else
                                        echo "[+] Results stored in smbclient.txt and enum4linux.txt"
                                fi
                        else
                                echo "[+] Attempting anonymous SMB enumeration..."
                                smbclient -L //$IP &> smbclient.txt
                                enum4linux -a $IP &> enum4linux.txt
                                if [[ $? -ne 0 ]]; then
                                        echo "[!] SMB enumeration failed! Is the target reachable?"
                                else
                                        echo "[+] Results stored in smbclient.txt and enum4linux.txt"
                                fi
                        fi
                        smbenumcomplete="True"
}

portEnum() {
        webenumcomplete="False"
        smbenumcomplete="False"
        while read -r port
        do
                portEnumCategorisation
                if [[ $type == "ftp" ]]; then
                        enumerateFTP
                elif [[ $type == "web" && $webenumcomplete == "False" ]]; then
                        enumerateWeb
                elif [[ $type == "smb" && $smbenumcomplete == "False" ]]; then
                        enumerateSMB
                elif [[ $type == "sql" ]]; then
                        echo "[+] Database service detected on port $port"

                elif [[ $type == "unknown" ]]; then
                        echo "[+] Sorry, failed to enumerate port $port because it isn't accounted for by this tool"

                fi
                done < openports.txt

}



generateReport() {
        cat > report.txt << EOF

=============== Vulnerability Report ================

Target: $IP
Time: $dateandtime

-----------------------------------------------------

Open Ports:

$(cat openports.txt)

Ports Not Scanned (No Support):

$(cat unsupportedports.txt)

Available Services:

$(cat services.txt)


CVEs to Potentially Exploit:

$(cat cvepresentation.txt)


**Note**

Detailed enumeration reports for each tool
can be found in the $reportdir directory

-----------------------------------------------------

EOF


}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
                showHelp
        fi

main () {

        cat << EOF
=====================================================

WITCH - Automated Enumeration Framework
Version 1.0.0 (12-06-26)
By: Kingmsh1

=====================================================
EOF

        getResources
        read -p "Enter IP address to run Nmap against: " IP
        read -p "Enter speed of Nmap scan (1-5): " SPEED

        createProjectStructure

        echo ""
        echo "[+] Running Nmap scan against target..."

        runNmapScan

        echo "[+] Checking for open ports with Nmap..."

        extractOpenPorts


        echo "[+] Extracting service information on ports..."

        extractServices

        echo "[+] Extracting CVE information ..."

        extractCVEsAndRatings

        echo "[+] Enumerating open ports ..."
        portEnum

        echo "[+] Generating vulnerability report..."
        generateReport
        cat report.txt

        rm -f cvepresentation.txt
        rm -f cvesandratings.txt
        rm -f openports.txt
        rm -f portsandservices.txt
        rm -f services.txt
        rm -f unsupportedports.txt

}

main
