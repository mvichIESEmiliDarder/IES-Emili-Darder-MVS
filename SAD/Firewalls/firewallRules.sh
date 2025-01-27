#!/bin/bash
echo "Començam..."

# INTERFACES
INET="ens18"
DMZ="ens20"
MZ="ens19"

# DELETE PREVIOUS RULES
iptables -t filter -F
iptables -t nat -F
 echo "Regles esborrades"

# DEFAULT POLICY (DROP)
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -P FORWARD DROP
echo "Polítiques per defecte assignades"

# LOOPBACK
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
echo "Regles de loopback assignades"

# ALLOW TCP & UDP PROTOCOLS
iptables -A INPUT -p tcp --dport 22 -j ACCEPT  # SSH
iptables -A INPUT -p tcp --dport 80 -j ACCEPT  # HTTP
iptables -A INPUT -p tcp --dport 443 -j ACCEPT  # HTTPS
iptables -A INPUT -p tcp --dport 51821 -j ACCEPT  # WireGuard Conf
iptables -A INPUT -p udp --dport 51820 -j ACCEPT  # Wireguard trafic
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
echo "Regles de FILTER assignades"

# ALLOW FORWARD
iptables -A FORWARD -i $MZ -o $INET  -j ACCEPT
iptables -A FORWARD -i $DMZ -o $INET -j ACCEPT
iptables -A FORWARD -i $INET -o $MZ -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i $INET -o $DMZ -j ACCEPT
echo "Regles de FORWARD assignades"

# ALLOW NAT
#iptables -t nat -A POSTROUTING -j MASQUERADE
iptables -t nat -A POSTROUTING -o $INET -s 10.0.1.0/24 -j MASQUERADE
iptables -t nat -A POSTROUTING -o $INET -s 10.0.2.0/24 -j MASQUERADE
iptables -t nat -A PREROUTING -i $INET -p tcp --dport 80 -j DNAT --to-destination 10.0.2.3:80
iptables -t nat -A PREROUTING -i $INET -p tcp --dport 443 -j DNAT --to-destination 10.0.2.3:443
iptables -t nat -A POSTROUTING -o $DMZ -p tcp -d 10.0.2.3 --dport 80 -j SNAT --to-source 10.0.2.1
iptables -t nat -A POSTROUTING -o $DMZ -p tcp -d 10.0.2.3 --dport 443 -j SNAT --to-source 10.0.2.1
echo "Regles de NAT assignades"

echo "Fi de la configuració"
