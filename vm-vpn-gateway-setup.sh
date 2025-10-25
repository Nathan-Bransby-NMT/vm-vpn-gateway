# !/bin/bash

set -e

# --- Color Definitions ---
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

clear

# Tested on Ubuntu (20.04+/22.04+) minimal server 

echo "${CYAN}${BOLD}====================================================================${RESET}"
echo "${CYAN}${BOLD}   VirtualMachine VPN Gateway Linux - Automated Installer (v1.0)    ${RESET}"
echo "${CYAN}      - Ubuntu 20.04+/22.04+ (minimal server)                              ${RESET}"
echo "${CYAN}${BOLD}--------------------------------------------------------------------${RESET}"
echo "${CYAN}   An easy, interactive installer to transform any VM running Ubuntu       ${RESET}"
echo "${CYAN}   (20.04+/22.04+) minimal server into a secure VPN router/gateway         ${RESET}"
echo "${CYAN}     - Ensuring that all connected LAN traffic on the network route        ${RESET}"
echo "${CYAN}       through a WireGuard compatible VPN server.                          ${RESET}"
echo "${CYAN}${BOLD}====================================================================${RESET}"
echo  
echo "${CYAN}${BOLD}Important:${RESET} Before, commencing, you must have:"
echo "${YELLOW}  - A commercial VPN or other WireGuard VPN subscription/credentials${RESET}"
echo "${YELLOW}  - Ability to generate/download a WireGuard .conf from your VPN Provider${RESET}"
echo
while true; do
	read -p "${BOLD}Do you wish to continue? (y/n): ${RESET}" CONT
	if [[ "${CONT,,}" == "y" ]]; then
		break
	elif [[ "${CONT,,}" == "n" ]]; then
		echo "${YELLOW}Aborted by user. No changes made.${RESET}"
		exit 0
	fi
done

echo
echo "${CYAN}${BOLD}Installing WireGuard and dependencies...${RESET}"

sudo apt update
sudo apt install -y wireguard iptables-persistent curl nano

echo
echo "${GREEN}WireGuard successfully installed!${RESET}"

echo
echo "${BOLD}Before continuing:${RESET}"
echo "${YELLOW}- Download or create your WireGuard VPN configuration file (.conf) from your VPN provider"
echo "- Place it in the direc# !/bin/bash

set -e

# --- Color Definitions ---
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

clear

# Tested on Ubuntu (20.04+/22.04+) minimal server 

echo "${CYAN}${BOLD}====================================================================${RESET}"
echo "${CYAN}${BOLD}   VirtualMachine VPN Gateway Linux - Automated Installer (v1.0)    ${RESET}"
echo "${CYAN}      - Ubuntu 20.04+/22.04+ (minimal server)                              ${RESET}"
echo "${CYAN}${BOLD}--------------------------------------------------------------------${RESET}"
echo "${CYAN}   An easy, interactive installer to transform any VM running Ubuntu       ${RESET}"
echo "${CYAN}   (20.04+/22.04+) minimal server into a secure VPN router/gateway         ${RESET}"
echo "${CYAN}     - Ensuring that all connected LAN traffic on the network route        ${RESET}"
echo "${CYAN}       through a WireGuard compatible VPN server.                          ${RESET}"
echo "${CYAN}${BOLD}====================================================================${RESET}"
echo  
echo "${CYAN}${BOLD}Important:${RESET} Before, commencing, you must have:"
echo "${YELLOW}  - A commercial VPN or other WireGuard VPN subscription/credentials${RESET}"
echo "${YELLOW}  - Ability to generate/download a WireGuard .conf from your VPN Provider${RESET}"
echo
while true; do
	read -p "${BOLD}Do you wish to continue? (y/n): ${RESET}" CONT
	if [[ "${CONT,,}" == "y" ]]; then
		break
	elif [[ "${CONT,,}" == "n" ]]; then
		echo "${YELLOW}Aborted by user. No changes made.${RESET}"
		exit 0
	fi
done

echo
echo "${CYAN}${BOLD}Installing WireGuard and dependencies...${RESET}"

sudo apt update
sudo apt install -y wireguard iptables-persistent curl nano

echo
echo "${GREEN}WireGuard successfully installed!${RESET}"

echo
echo "${BOLD}Before continuing:${RESET}"
echo "${YELLOW}- Download or create your WireGuard VPN configuration file (.conf) from your VPN provider"
echo "- Place it in the directory ${CYAN}/etc/wireguard/${RESET}"
echo

while true; do
	read -p "Press [Enter] when you have placed your WireGuard config file in the correct directory..."
	WG_CONF_EXISTS=$(ls /etc/wireguard/*.conf 2>/dev/null | wc -l)
	if [[ $WG_CONF_EXISTS -gt 0 ]]; then
		echo "${GREEN}Confirmed: WireGuard configuration file(s) detected.${RESET}"
		break
	else
		echo "${RED}No .conf files detected in /etc/wireguard/.${RESET}"
	fi
done

# List all interfaces
echo
echo "${GREEN}Detected network interfaces:${RESET}"
ip -o link show | awk -F': ' '{print " -", $2}' | grep -v lo
echo

# Auto-detect candidates (best-effort)
WAN_AUTO=$(ip -o -4 addr show | awk '{print $2, $4}' | grep -vE '127|192\.168|10\.|172\.(1[6-9]|3[0-1])' | head -n1 | awk '{print $1}')
[[ -z "$WAN_AUTO" ]] && WAN_AUTO=$(ip -o link show | awk -F': ' '{print $2}' | grep -v lo | head -n1)
LAN_AUTO=$(ip -o -4 addr show | awk '{print $2, $4}' | grep -E '192\.168|10\.|172\.(1[6-9]|2[0-9]|3[0-1]' | head -n1 | awk '{print $1}')
[[ -z "$LAN_AUTO" ]] && LAN_AUTO="$WAN_AUTO"

echo "${YELLOW}Auto-detected WAN candidate (internet-facing):${RESET} $WAN_AUTO"
echo "${YELLOW}Auto-detected LAN candidate (local-network):${RESET}   $LAN_AUTO"
echo

# Prompt user specified WAN choice
while true; do
	read -p "Enter WAN interface name [${WAN_AUTO}]: " WAN_IF
	WAN_IF=${WAN_IF:-$WAN_AUTO}
	if ip link show "$WAN_IF" >/dev/null 2>&1; then
		echo "${GREEN}Confirmed:${RESET} Interface '$WAN_IF' exists."
		break
	else
		echo "${RED}Error:${RESET} '$WAN_IF' not found. Please enter a valid network interface."
	fi
done

# Prompt user specified WAN choice
while true; do
	read -p "Enter LAN interface name [${LAN_AUTO}]" LAN_IF
	LAN_IF=${LAN_IF:-$LAN_AUTO}
	if ip link show "LAN_IF" >/dev/null 2>&1; then
		echo "${GREEN}Confirmed:${RESET} Interface '$LAN_IF' exists."
		break
	else
		echo "${RED}Error:${RESET} '$LAN_IF' not found. Please enter a valid network interface."
	fi
done

echo
echo "${CYAN}Detected WireGuard config files:${RESET}"
ls /etc/wireguard/*.conf 2>/dev/null
WG_CONF_AUTO=$(ls /etc/wireguard/*.conf 2>/dev/null | head -n1)

while true; do
	read -p "Enter path to the WireGuard configuration file that you would like to use [${WG_CONF_AUTO}]: " WG_CONF
	WG_CONF=${WG_CONF:-$WG_CONF_AUTO}
	if [[ -f "$WG_CONF" ]]; then
		echo "${GREEN}Confirmed: WireGuard configuration found at '$WG_CONF'.${RESET}"
		break
	else
		echo "${RED}Error: Configuration file '$WG_CONF' not found. Please enter a valid path.${RESET}"
	fi
done

echo 
echo "${CYAN}${BOLD}+==========================+${RESET}"
echo "${CYAN}${BOLD}| Current Settings Summary |${RESET}"
echo "${CYAN}${BOLD}+==========================+${RESET}"
echo

echo "${CYAN}------------------+--------------------------------${RESET}"
echo "${CYAN}${BOLD}      Setting     | Value ${RESET}"
echo "${CYAN}------------------+--------------------------------${RESET}"
echo "${YELLOW} WAN Interface    ${CYAN}${BOLD}|${RESET} $WAN_IF"
echo "${YELLOW} LAN Interface    ${CYAN}${BOLD}|${RESET} $LAN_IF"
echo "${YELLOW} WireGuard Config ${CYAN}${BOLD}|${RESET} $WG_CONF"
echo "${CYAN}------------------+--------------------------------${RESET}"

echo

while true; do
	read -p "${CYAN}${BOLD}Proceed with these settings? (y/n):${RESET}" YES
	if [[ "${YES,,}" == "y" ]]; then break
	elif [[ "${YES,,}" == "n" ]]; then echo "${YELLOW}Setup aborted. No changes made.${RESET}"; exit 1
	fi
done

echo "${CYAN}Enabling IP forwarding for routing...${RESET}"
sudo sed -i '/^#*net\.ipv4\.ip_forward/s/^#*/ /' /etc/sysctl.conf
sudo sed -i '/^net\.ipv4\.ip_forward/ d' /etc/sysctl.conf
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

WG_NAME=$(basename "${WG_CONF%.*}")
echo "${CYAN}Activating WireGuard tunnel ($WG_NAME)...${RESET}"
sudo chmod 600 "$WG_CONF"
sudo systemctl stop wg-quick@$WG_CONF || true
sudo wg-quick up "$WG_NAME"

echo "${CYAN}Configuring NAT (LAN traffic via WAN VPN interface)...${RESET}"
sudo iptables -t nat -A POSTROUTING -o "$WAN_IF" -j MASQUERADE
sudo netfilter-persistent save

echo
echo "${GREEN}${BOLD}Setup completed successfully!${RESET}"
echo "${CYAN}Instructions:${RESET}"
echo "  - Set your LAN devices to use this VM on $LAN_IF as their default gateway."
echo "  - Your traffic will now route through the secure VPN tunnel."
echo
echo "${BOLD}Useful commands for verification:${RESET}"
echo "  ${YELLOW}sudo wg${RESET}				# WireGuard status"
echo "  ${YELLOW}sudo iptables -t nat -L -v${RESET}		# NAT rules"
echo "  ${YELLOW}cat /proc/sys/net/ipv4/ip_forward${RESET}	# Should return '1'"	
echo
echo "${GREEN}For troubleshooting, visit the GitHub repository ... ${RESET}"
echo "${GREEN}${BOLD}  - https://github.com/Nathan-Bransby-NMT/vm-vpn-gateway${RESET}"
echo
echo "${GREEN}... or check with the docs and forums found on WireGuard (and/or) your VPN providers websites.${RESET}"
echotory ${CYAN}/etc/wireguard/${RESET}"
echo

while true; do
	read -p "Press [Enter] when you have placed your WireGuard config file in the correct directory..."
	WG_CONF_EXISTS=$(ls /etc/wireguard/*.conf 2>/dev/null | wc -l)
	if [[ $WG_CONF_EXISTS -gt 0 ]]; then
		echo "${GREEN}Confirmed: WireGuard configuration file(s) detected.${RESET}"
		break
	else
		echo "${RED}No .conf files detected in /etc/wireguard/.${RESET}"
	fi
done

# List all interfaces
echo
echo "${GREEN}Detected network interfaces:${RESET}"
ip -o link show | awk -F': ' '{print " -", $2}' | grep -v lo
echo

# Auto-detect candidates (best-effort)
WAN_AUTO=$(ip -o -4 addr show | awk '{print $2, $4}' | grep -vE '127|192\.168|10\.|172\.(1[6-9]|3[0-1])' | head -n1 | awk '{print $1}')
[[ -z "$WAN_AUTO" ]] && WAN_AUTO=$(ip -o link show | awk -F': ' '{print $2}' | grep -v lo | head -n1)
LAN_AUTO=$(ip -o -4 addr show | awk '{print $2, $4}' | grep -E '192\.168|10\.|172\.(1[6-9]|2[0-9]|3[0-1]' | head -n1 | awk '{print $1}')
[[ -z "$LAN_AUTO" ]] && LAN_AUTO="$WAN_AUTO"

echo "${YELLOW}Auto-detected WAN candidate (internet-facing):${RESET} $WAN_AUTO"
echo "${YELLOW}Auto-detected LAN candidate (local-network):${RESET}   $LAN_AUTO"
echo

# Prompt user specified WAN choice
while true; do
	read -p "Enter WAN interface name [${WAN_AUTO}]: " WAN_IF
	WAN_IF=${WAN_IF:-$WAN_AUTO}
	if ip link show "$WAN_IF" >/dev/null 2>&1; then
		echo "${GREEN}Confirmed:${RESET} Interface '$WAN_IF' exists."
		break
	else
		echo "${RED}Error:${RESET} '$WAN_IF' not found. Please enter a valid network interface."
	fi
done

# Prompt user specified WAN choice
while true; do
	read -p "Enter LAN interface name [${LAN_AUTO}]" LAN_IF
	LAN_IF=${LAN_IF:-$LAN_AUTO}
	if ip link show "LAN_IF" >/dev/null 2>&1; then
		echo "${GREEN}Confirmed:${RESET} Interface '$LAN_IF' exists."
		break
	else
		echo "${RED}Error:${RESET} '$LAN_IF' not found. Please enter a valid network interface."
	fi
done

echo
echo "${CYAN}Detected WireGuard config files:${RESET}"
ls /etc/wireguard/*.conf 2>/dev/null
WG_CONF_AUTO=$(ls /etc/wireguard/*.conf 2>/dev/null | head -n1)

while true; do
	read -p "Enter path to the WireGuard configuration file that you would like to use [${WG_CONF_AUTO}]: " WG_CONF
	WG_CONF=${WG_CONF:-$WG_CONF_AUTO}
	if [[ -f "$WG_CONF" ]]; then
		echo "${GREEN}Confirmed: WireGuard configuration found at '$WG_CONF'.${RESET}"
		break
	else
		echo "${RED}Error: Configuration file '$WG_CONF' not found. Please enter a valid path.${RESET}"
	fi
done

echo 
echo "${CYAN}${BOLD}+==========================+${RESET}"
echo "${CYAN}${BOLD}| Current Settings Summary |${RESET}"
echo "${CYAN}${BOLD}+==========================+${RESET}"
echo

echo "${CYAN}------------------+--------------------------------${RESET}"
echo "${CYAN}${BOLD}      Setting     | Value ${RESET}"
echo "${CYAN}------------------+--------------------------------${RESET}"
echo "${YELLOW} WAN Interface    ${CYAN}${BOLD}|${RESET} $WAN_IF"
echo "${YELLOW} LAN Interface    ${CYAN}${BOLD}|${RESET} $LAN_IF"
echo "${YELLOW} WireGuard Config ${CYAN}${BOLD}|${RESET} $WG_CONF"
echo "${CYAN}------------------+--------------------------------${RESET}"

echo

while true; do
	read -p "${CYAN}${BOLD}Proceed with these settings? (y/n):${RESET}" YES
	if [[ "${YES,,}" == "y" ]]; then break
	elif [[ "${YES,,}" == "n" ]]; then echo "${YELLOW}Setup aborted. No changes made.${RESET}"; exit 1
	fi
done

echo "${CYAN}Enabling IP forwarding for routing...${RESET}"
sudo sed -i '/^#*net\.ipv4\.ip_forward/s/^#*/ /' /etc/sysctl.conf
sudo sed -i '/^net\.ipv4\.ip_forward/ d' /etc/sysctl.conf
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

WG_NAME=$(basename "${WG_CONF%.*}")
echo "${CYAN}Activating WireGuard tunnel ($WG_NAME)...${RESET}"
sudo chmod 600 "$WG_CONF"
sudo systemctl stop wg-quick@$WG_CONF || true
sudo wg-quick up "$WG_NAME"

echo "${CYAN}Configuring NAT (LAN traffic via WAN VPN interface)...${RESET}"
sudo iptables -t nat -A POSTROUTING -o "$WAN_IF" -j MASQUERADE
sudo netfilter-persistent save

echo
echo "${GREEN}${BOLD}Setup completed successfully!${RESET}"
echo "${CYAN}Instructions:${RESET}"
echo "  - Set your LAN devices to use this VM on $LAN_IF as their default gateway."
echo "  - Your traffic will now route through the secure VPN tunnel."
echo
echo "${BOLD}Useful commands for verification:${RESET}"
echo "  ${YELLOW}sudo wg${RESET}				# WireGuard status"
echo "  ${YELLOW}sudo iptables -t nat -L -v${RESET}		# NAT rules"
echo "  ${YELLOW}cat /proc/sys/net/ipv4/ip_forward${RESET}	# Should return '1'"	
echo
echo "${GREEN}For troubleshooting, visit the GitHub repository: ${BOLD}https://github.com/Nathan-Bransby-NMT/vm-vpn-gateway${RESET}"
echo
echo "${GREEN}... or check with the docs and forums found on WireGuard (and/or) your VPN providers websites.${RESET}"
echo
