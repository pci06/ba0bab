#!/bin/bash

tempfile=`(tempfile) 2>/dev/null` || tempfile=/tmp/test$$
trap "rm -f $tempfile" 0 $SIG_NONE $SIG_HUP $SIG_INT $SIG_QUIT $SIG_TERM

: ${DIALOG=dialog}
: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}
: ${DIALOG_HELP=2}
: ${DIALOG_EXTRA=3}
: ${DIALOG_ITEM_HELP=4}
: ${DIALOG_ESC=255}

: ${SIG_NONE=0}
: ${SIG_HUP=1}
: ${SIG_INT=2}
: ${SIG_QUIT=3}
: ${SIG_KILL=9}
: ${SIG_TERM=15}


encodeOrangeID () {
	local chaine=$1
	local toReturn=""
	for ((entier=0; entier<${#chaine}; entier++)); do
		toReturn="$toReturn:$(printf "%02x" "'${chaine:$entier:1}")"
	done
	echo ${toReturn#:}
}

shouldExit () {
	if [ "$1" -ne "0" ]; then
		echo $2
		exit $1
	fi
}


getNIC () {
	ip -o link | cut -d ':' -f 2 | sed -n 's,[[:space:]],,g;/^lo$/d;/^.*@.*/d;s,.*,& interface,;p' | sort -u
}

getNICnMAC() {
ip -o link | sed -n '/^[0-9]\+:[[:space:]]\+ppp[0-9]\+:/ d;/^[0-9]\+:[[:space:]]\+tap[0-9]\+:/ d;/^[0-9]\+:[[:space:]]\+tun[0-9]\+:/ d;/^[0-9]\+:[[:space:]]\+lo:/ d;s,[0-9]\+:[[:space:]]*\([^:]\+\):.*/ether[[:space:]]*\([^[:space:]]\+\)[[:space:]]\+.*,\1 \2,;p' | sort
}

$DIALOG --clear --title "Interface WAN" "$@" \
        --menu "Sélectionner l'interface WAN dans la liste ci-dessous:" \
         20 51 4 \
				$(getNICnMAC) \
				 2> $tempfile

shouldExit $? "Configuration annulée"

WANIF=$(cat $tempfile)
LANNICs=($(getNICnMAC | grep -v $WANIF | sed 's,$, off,'))

$DIALOG --backtitle "Interface LAN pour IPv6" \
	--title "" "$@" \
        --checklist "Sélectionner la ou les interfaces LAN pour lesquelles activer IPv6:
Press SPACE to toggle an option on/off\n\n\
  Quelle(s) interface(s) ?" 20 61 5 \
				${LANNICs[@]} \
        2> $tempfile

shouldExit $? "Configuration annulée"

IPv6NICs=($(cat $tempfile))

label1="fti/"
label2="Adresse MAC LiveBox:"

$DIALOG \
	  --form "Veuillez saisir les informations suivantes:" \
	20 50 0 \
	"$label1" 1 1	"" 1 ${#label2} 20 0 \
	"$label2" 2 1	"" 2 ${#label2} 20  0 \
	2> $tempfile
shouldExit $? "Configuration annulée"

eval $(sed '1 s,^,FTIID=,;2 s,^,LBMAC=,' $tempfile)

$DIALOG --title "Entrer le répertoire destination" --dselect $PWD 15 50 2> $tempfile
shouldExit $? "Configuration annulée"
destDir=$(cat $tempfile)

mkdir -p $destDir

ORANGEID=$(encodeOrangeID ${FTIID})

sedExpr="s,_WANIFACE_,$WANIF,g;"
sedExpr+="s,_LB_MACADDR_,$LBMAC,g;"
sedExpr+="s,_ORANGEID_,$ORANGEID,g;"
#sedExpr+="s,2a01:cb1d:.*,a:b:c:d,;"

for cFile in $(find original/etc/sysctl.d original/etc/radvd* original/etc/network/interfaces.d/orange original/etc/dhcp/orange/); do
	[ -d "$cFile" ] && continue
	dDir=${cFile%/*}
	dDir=${dDir#original/}
	mkdir -p $destDir/$dDir
	sed "$sedExpr" $cFile > $destDir/${cFile#original/}
done

rm -f $destDir/etc/radvd.d/*
for nic in ${IPv6NICs[@]}; do
	echo $nic >> $destDir/etc/radvd.d/radvd-interfaces
	cat > $destDir/etc/radvd.d/${nic}.conf <<_DOC
interface ${nic}
{
	AdvManagedFlag off; # no DHCPv6 server here.
#	AdvOtherConfigFlag on; # not even for options.
	AdvSendAdvert on;
	AdvDefaultPreference medium;
#	AdvLinkMTU 1280;
  AdvSendAdvert on;
  MinRtrAdvInterval 10; 
  MaxRtrAdvInterval 600;
	
	#pick one non-link-local prefix assigned to the interface and start advertising it
	prefix a:b:c:d
	{
		AdvOnLink on;
		AdvAutonomous on;
    AdvPreferredLifetime 1800;
    AdvValidLifetime 3600;                                                             
#		AdvLifetime 30;
	};

	RDNSS a:b:c:d
	{
		AdvRDNSSLifetime 900;
	};

};
_DOC
done


