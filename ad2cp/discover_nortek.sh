#!/bin/bash


echo "Select a network interface on this machine which is on the same network segment"
echo "as the NORTEK ADCP."
echo



function select_interface()
{
    echo "Available interfaces:"
    echo "---------------------------------------------------------------------------------"
    mapfile -t interfaces < <(ip -o link show | awk -F': ' '$2 != "lo" {print $2}')

    if [[ ${#interfaces[@]} -eq 0 ]]; then
        echo "No non-loopback interfaces found." >&2
        return 1
    fi

    local display=()
    local filtered_interface=()
    local filtered_ipv4=()
    for i in "${!interfaces[@]}"; do
        local iface="${interfaces[$i]}"
        local ip4
        ip4=$(ip -4 -o addr show dev "$iface" 2>/dev/null | awk '{print $4}' | cut -d/ -f1)
        [[ -z "$ip4" ]] && continue
        filtered_interface+=("$iface")
	filtered_ipv4+=("$ip4")
        display+=("$iface  $ip4")
    done

    if [[ ${#filtered_interface[@]} -eq 0 ]]; then
        echo "No interfaces with an IPv4 address found." >&2
        return 1
    fi

    PS3="Select interface: "
    select choice in "${display[@]}"; do
        echo $choice
        [[ -n "$choice" ]] && break
        echo "Invalid selection, try again."
    done

    local idx=$((REPLY - 1))
    INTERFACE="${filtered_interface[$idx]}"
    IPADDRESS="${filtered_ipv4[$idx]}"
    echo "Selected: $INTERFACE"
}

select_interface
errorno=$?
if [[ ! $errorno -eq 0 ]]; then
    exit $errorno
fi

function get_network_segment()
{
    if [[ $# -eq 0 ]]; then
	return 2
    fi
    local ip_address=$1
    network_segment=$(echo $ip_address | sed "s/\.[0-9]*$/\.0/g")
    NETWORK_SEGMENT="${network_segment}/24"
    }

get_network_segment $IPADDRESS
errorno=$?
if [[ ! $errorno -eq 0 ]]; then
    exit $errorno
fi

function find_nortek()
{
    ID_STRING="Nortek-AS"
    local line
    line=$(sudo arp-scan --interface="$INTERFACE" -x "$NETWORK_SEGMENT" | grep ${ID_STRING} | head -1)
    if [[ -z "$line" ]]; then
        echo "No Nortek-AS device found on $NETWORK_SEGMENT." >&2
        return 1
    fi
    NORTEK_IP=$(echo "$line" | awk '{print $1}')
    echo "Found Nortek-AS at $NORTEK_IP"
}

find_nortek
errorno=$?
if [[ ! $errorno -eq 0 ]]; then
    exit $errorno
fi
