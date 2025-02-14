#!/bin/bash

usage() {
    echo "Usage: $0 [-f <snmp_ip.txt>] [-c <community>] <ip_address> <list_mib.txt>"
    exit 1
}

snmp_ip_file=""
community="public"  # Valeur par défaut de la community
ip_list=""
list_mib=""

while getopts "f:c:" opt; do
    case "$opt" in
        f)
            snmp_ip_file="$OPTARG"
            ;;
        c)
            community="$OPTARG"
            ;;
        *)
            usage
            ;;
    esac
done

shift $((OPTIND - 1))

if [ -n "$snmp_ip_file" ]; then
    if [ ! -f "$snmp_ip_file" ]; then
        echo "Erreur: Le fichier $snmp_ip_file n'existe pas."
        exit 1
    fi
    ip_list=$(cat "$snmp_ip_file")
else
    if [ "$#" -lt 2 ]; then
        usage
    fi
    ip_list="$1"
    shift
fi

list_mib="$1"

if [ ! -f "$list_mib" ]; then
    echo "Erreur: Le fichier $list_mib n'existe pas."
    exit 1
fi

echo "Utilisation de la community string: $community"

for ip in $ip_list; do
    echo "Interrogation de l'IP: $ip"
    # Interroger chaque OID dans le fichier list_mib
    while IFS= read -r oid; do
        echo "  Interrogation de l'OID: $oid"
        snmpwalk -v "2c" -c "$community" -Oa "$ip" "$oid"
    done < "$list_mib"
done
