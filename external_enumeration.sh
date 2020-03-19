#!/bin/bash

# Script to automate some initial enumeration for external assessments
# Author: Connor McGarr

# Domain name variable
domain=$1

# Shodan API key variable
shodan_api=$2

# Error handling for lack of command line arguments
if [ -z "$domain" ]
	then
		echo "[-] No domain specified! Please specify a domain and Shodan API token."
		echo "Usage: ./external_enumeration.sh <DOMAIN.com> <SHODAN_API_TOKEN>"
	exit 1
fi

# Error handling for no Shodan API key
if [ -z "$shodan_api" ]
	then
		echo "[-] You seemed to have entered a domain- but no Shodan API token!"
		echo "Usage: ./external_enumeration.sh <DOMAIN.com> <SHODAN_API_TOKEN>"
	exit 1
fi

# Error handling for missing python-pip
if pip --version >/dev/null 2>&1
then
	echo "[+] Python-pip is installed! Continuing on..."
else
	echo "It seems as though you are missing python-pip. Please install it with sudo apt-get install python-pip"
	exit 1
fi
# Error handling for missing shodan
if shodan -h >/dev/null 2>&1
then
	echo "[+] Shodan is installed! Continuing on..."
else
	echo "[-] It seems as though you are missing shodan. Please install it with sudo pip install shodan"
	exit 1
fi

# Make direcotry for all output
echo "[+] Creating directory INITIAL_EXTERNAL_ENUMERATION in current directory..."
mkdir $PWD/INITIAL_EXTERNAL_ENUMERATION

echo "[+] All ouput files will be written to $PWD/INITIAL_EXTERNAL_ENUMERATION!"

# Sleeping for 2 seconds to inform user wher files will be written to
sleep 2

# WHOIS function
function who_is
{
	whois $domain >> $PWD/INITIAL_EXTERNAL_ENUMERATION/WHO_IS_$domain.txt
}

# Print update
echo "[+] WHOIS enumeration for $domain is done!"
who_is

# DNS records function
function get_all_dns_records
{
	dig $domain TXT >> $PWD/INITIAL_EXTERNAL_ENUMERATION/DNS_Records_$domain.txt
	dig $domain A >> $PWD/INITIAL_EXTERNAL_ENUMERATION/DNS_Records_$domain.txt
	dig $domain NS >> $PWD/INITIAL_EXTERNAL_ENUMERATION/DNS_Records_$domain.txt
	dig $domain AAAA >> $PWD/INITIAL_EXTERNAL_ENUMERATION/DNS_Records_$domain.txt
	dig $domain ALIAS >> $PWD/INITIAL_EXTERNAL_ENUMERATION/DNS_Records_$domain.txt
	dig $domain CNAME >> $PWD/INITIAL_EXTERNAL_ENUMERATION/DNS_Records_$domain.txt
	dig $domain MX >> $PWD/INITIAL_EXTERNAL_ENUMERATION/DNS_Records_$domain.txt
	dig $domain PTR >> $PWD/INITIAL_EXTERNAL_ENUMERATION/DNS_Records_$domain.txt
	dig $domain SOA >> $PWD/INITIAL_EXTERNAL_ENUMERATION/DNS_Records_$domain.txt
	dig $domain SRV >> $PWD/INITIAL_EXTERNAL_ENUMERATION/DNS_Records_$domain.txt
	grep -v "DiG" $PWD/INITIAL_EXTERNAL_ENUMERATION/DNS_Records_$domain.txt >> $PWD/INITIAL_EXTERNAL_ENUMERATION/TEST.txt
	grep "$domain." $PWD/INITIAL_EXTERNAL_ENUMERATION/TEST.txt >> $PWD/INITIAL_EXTERNAL_ENUMERATION/TEST2.txt
	grep -v ";$domain" $PWD/INITIAL_EXTERNAL_ENUMERATION/TEST2.txt >> $PWD/INITIAL_EXTERNAL_ENUMERATION/Cleaned_Up_DNS_Records_$domain.txt

	rm $PWD/INITIAL_EXTERNAL_ENUMERATION/TEST.txt
	rm $PWD/INITIAL_EXTERNAL_ENUMERATION/TEST2.txt
}

get_all_dns_records

#Print update
echo "[+] All DNS records (via dig) for $domain have been saved in DNS_Records_$domain.txt!"
echo "[+] A cleaner version of dig DNS records for $domain is located in Cleaned_Up_DNS_Records_$domain.txt"

# Shodan function
function run_shodan
{

	shodan init $shodan_api >/dev/null

	# Any easy wins?
	shodan download search "port:21,23,139,445,3389,5900" $domain easy_wins.json.gz

	# Web servers?
	shodan download search "port:80,443,8080,8443" $domain web_servers.json.gz

}

run_shodan