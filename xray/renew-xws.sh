#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
MYIP=$(wget -qO- ipv4.icanhazip.com);
echo "Checking VPS"
IZIN=$( curl https://raw.githubusercontent.com/Sangarya/izin/main/ipvps | grep $MYIP )
if [ $MYIP = $IZIN ]; then
echo -e "${green}Permission Accepted...${NC}"
else
echo -e "${red}Permission Denied!${NC}";
echo "Only For Premium Users"
exit 0
fi
clear
#EDIT IZIN
clear
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/xray/vmesstls.json")
	if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
		clear
		echo ""
		echo "  Renew XRAY Vmess Account"
		echo ""
		echo "You have no existing clients!"
		exit 1
	fi

	clear
	echo ""
	echo "  Renew XRAY Vmess Account"
	echo ""
	echo "Select the existing client you want to renew"
	echo " Press CTRL+C to return"
	echo ""
	echo -e "==============================="
	grep -E "^### " "/etc/xray/vmesstls.json" | cut -d ' ' -f 2-3 | nl -s ') '
	until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
		if [[ ${CLIENT_NUMBER} == '1' ]]; then
			read -rp "Select one client [1]: " CLIENT_NUMBER
		else
			read -rp "Select one client [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
		fi
	done
read -p "Expired (days): " masaaktif
user=$(grep -E "^### " "/etc/xray/vmesstls.json" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^### " "/etc/xray/vmesstls.json" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
now=$(date +%Y-%m-%d)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(( (d1 - d2) / 86400 ))
exp3=$(($exp2 + $masaaktif))
exp4=`date -d "$exp3 days" +"%Y-%m-%d"`
sed -i "s/### $user $exp/### $user $exp4/g" /etc/xray/vmesstls.json
sed -i "s/### $user $exp/### $user $exp4/g" /etc/xray/vmessnone.json
sed -i "s/### $user $exp/### $user $exp4/g" /etc/xray/mkcp.json
service cron restart
clear
echo ""
echo " XRAY VMESS Account Was Successfully Renewed"
echo " =========================="
echo " Client Name : $user"
echo " Expired On  : $exp4"
echo " =========================="
