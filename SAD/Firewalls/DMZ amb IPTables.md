El mètode més usat per poder aïllar els serveis de la xarxa corporativa de forma que sigui segura, és emprar el model de DMZ en la xarxa. És per això que hem de conèixer com funciona aquest sistema, tenir clares les seves definicions i com podem implementar-lo . En aquests apunts veurem com es pot aixecar un firewall que compleixi amb el que hem enunciat i sigui replicable i escalable en un futur.
# Introducció

El primer que hem de fer és definir la situació teòrica: volem implementar un firewall que faci de barrera entre la xarxa externa i desconfiable i dues xarxes internes i per tant, a protegir.

La xarxa externa serà Internet o l’accés que ens dóna l’Institut a aquesta i tindrem dues xarxes més, la xarxa on tenim els nostres serveis (la DMZ) i la xarxa on tenim els nostres usuaris (la xarxa local o MZ).



![[Pasted image 20241214002304.png]]

**Contexte**

En l’Institut disposam del servidor de Proxmox que ens dóna la infraestructura tant de MVs com de xarxa. Per això el farem servir d’ell els recursos que necessitam per posar en marxa el que ens interessa:

- 1 servidor Ubuntu per fer de Firewall  
- 1 client Ubuntu Desktop per fer de client de la XL
- 1 servidor Apache per fer de servidor de la DMZ
- 1 client Windows per fer de client d’Internet

Xarxes

| Interfície | Accés       | Adreçament     |
| ---------- | ----------- | -------------- |
| vmbr0      | Internet    | 192.168.0.0/16 |
| vmbr1      | DMZ         | 10.0.1.0/24    |
| vmbr2      | Xarxa local | 10.0.2.0/24    |

Ordinadors

| Ordinador      | vmbr0       | vmbr1    | vmbr2    |
| -------------- | ----------- | -------- | -------- |
| Firewall       | 192.168.X.X | 10.0.1.1 | 10.0.2.1 |
| Apache         |             | 10.0.1.X |          |
| Windows        | 192.168.X.X |          |          |
| Ubuntu Desktop |             |          | 10.0.2.X |

----
# Configuració de xarxa del Firewall

Configurarem el Firewall a nivell de xarxa seguint l’esquema de la DMZ/MZ:
 
![[Pasted image 20241214002327.png]]

Editam el fitxer /etc/netplan/00-installer-config.yaml i el deixam com el següent:
```yml
# This is the network config written by 'subiquity'
network:
  ethernets:
    ens18:
      dhcp4: no
      addresses:
        - 192.168.66.80/16
      nameservers:
        addresses:
           - 1.1.1.1
           - 8.8.8.8      
      routes:
        - to: default
          via: 192.168.0.1
    ens19:
      dhcp4: no
      addresses:
        - 10.0.1.1/24
    ens20:
     dhcp4: no
     addresses:
       - 10.0.2.1/24
  version: 2
```

>**Important:** Confirmar que les IPs estan assignades a la interfície de xarxa adequada.

Un cop tenim configurades les IPs, activarem l’opció de NAT forwarding per a què el servidor pugui fer NAT dels paquets i routing. Per això editam el fitxer /etc/sysctl.conf, cercant la línia que diu net.ipv4.ip_forward=1 i la descomentam:

![[Pasted image 20241214002632.png]]
Guardam i executam la següent ordre per actualitzar els canvis:
```
sudo sysctl -p
```

Fet això acabam d’activar el reenviament de paquets per a IPv4 per aquest PC.

----
# Configuració d’IPTables

Ara passam a la configuració del firewall pròpiament dit. Amb aquesta disposició d'interfícies de xarxa clara, hem de saber quin objectiu hem d’aconseguir i com ho hem de fer. Veiem quines són les regles que haurien de seguir els paquets a nivell més abstracte:

**Internet - Xarxa Local**

- El trànsit que prové de la interfície ens20 cap a la interfície ens18, pot passar sense cap problema. (XL⇨INET)
- El trànsit que prové de la interfície ens18 cap a la interfície ens20, només serà permès si és trànsit de resposta a les peticions que s'han fet els clients de la xarxa local. (INET⇨XL)

**Internet - DMZ**

- El trànsit que prové de la interfície ens18 cap a la interfície ens19, pot passar sense cap problema. (INET⇨DMZ)
- El trànsit que surt de la interfície ens19 a la ens18,  pot passar sense cap problema. (DMZ⇨INET - Versió no restrictiva)
- El trànsit que surt de la interfície ens19 a la ens18, només serà si permès si és trànsit de resposta a les peticions que s’hagin fet als servidors de la DMZ. (DMZ⇨INET - Versió restrictiva no implementada)
- Les peticions al ports 80 de la interfície ens18, han de ser redirigits a ens19 (DMZ) al servidor Apache. (Port forwarding)

**Xarxa Local - DMZ**

- El trànsit que prové de la interfície ens20 cap a la interfície ens19, pot passar sense cap problema. (XL⇨DMZ)
- El trànsit que prové de la interfície ens19 cap a la interfície ens20, pot passar sempre que siguin respostes a les peticions realitzades des de la interfície ens20. (DMZ⇨XL)  

Veiem com feim la impelmentació:

- Primer preparam les taules amb la configuració neta i permetem accedir per SSH:
```
iptables -F
iptables -t nat -F
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -P INPUT DROP  
iptables -P FORWARD DROP  
iptables -P OUTPUT ACCEPT
iptables -t nat -A POSTROUTING -j MASQUERADE
```

- Permetem el trànsit XL ⇨ INET
```
iptables -A FORWARD -i ens20 -o ens18 -j ACCEPT
```

- Permetem el trànsit INET ⇨ XL de tornada
```
iptables -A FORWARD -i ens18 -o ens20 -m state --state ESTABLISHED,RELATED -j ACCEPT
```

- Permetem el trànsit INET⇨DMZ
```
iptables -A FORWARD -i ens18 -o ens19 -j ACCEPT
```

- Permetem el trànsit DMZ ⇨ INET de tornada (Versión no restrictiva)
```
iptables -A FORWARD -i ens19 -o ens18 -j ACCEPT
```

- Permetem el trànsit DMZ ⇨ INET de tornada (Versión restrictiva no implementada)
```
iptables -A FORWARD -i ens19 -o ens18 -m state --state ESTABLISHED,RELATED -j ACCEPT
```
  
  - Permetem el trànsit XL⇨DMZ
  ```
iptables -A FORWARD -i ens20 -o ens19 -j ACCEPT
```

- Permetem el trànsit DMZ ⇨ XL de tornada
```
iptables -A FORWARD -i ens19 -o ens20 -m state --state ESTABLISHED,RELATED -j ACCEPT
```  

- Feim un port forwarding al servidor Apache
```
iptables -t nat -A PREROUTING -i ens18 -p tcp --dport 80 -j DNAT --to 10.0.3.101:80
iptables -t nat -A POSTROUTING -o ens19 -p tcp --dport 80 -d 10.0.3.101 -j SNAT --to-source 10.0.3.1
```
  
Si ho hem fet correctament hem d’obtenir:

![[Pasted image 20241214144955.png]]

![[Pasted image 20241214145013.png]]

---
# Comprovacions

Des del PC de Windows, podem accedir al servidor web mitjançant la IP de la xarxa de la DMZ, però no si accedim a la IP d’Internet. Això és degut a que el Firewall ens fa de router (per tant arribam a la xarxa DMZ des de la XL) però no hem activat el NAT per la interfície ens19, que és per on entra el PC amb Windows. 

![[Pasted image 20241214145133.png]]  

Si accedim a la pàgina 192.168.66.80 des del Kali Linux, hem de trobar la pàgina correctament. Això és degut a que sí hem configurat el NAT per la interfície ens18.

![[Pasted image 20241214145201.png]]

 