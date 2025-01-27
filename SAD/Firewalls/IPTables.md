L’objectiu d’aquests apunts és mostrar les opcions bàsiques d’IPTables. Mitjançant exemples i una breu explicació, veurem com podem configurar aquest tallafocs de Linux que està estès a la majoria de distribucions.

# Introducció
IPTables és una comanda que pertany al paquet netfilter, que conté més comandes i va més enllà de només el propòsit de iptables. Ens serveix per indicar al PC com ha de gestionar els paquets que entren, surten o passen a través d'un ordinador.   

Iptables funciona mitjançant l'ús d'unes taules (tables), aquestes taules contenen cadenes (chains) i aquestes cadenes contenen regles (rules). Però, què és cada cosa? Comencem per la darrera:
- Les regles: ens indiquen que hem de fer amb els paquets que arriben o surten del firewall. Què ha de cumplir un paquet per aplicar accions damunt ell. P.e. acceptar-lo, rebutjar-lo o redirigir-lo.
- Les cadenes: són els llocs on es mirarà d’aplicar les regles dels paquets. P.e. a l’entrada, a la sortida o al lloc per redireccionar.
- Les taules: defineixen les funcionalitats, com per exemple la funcionalitat de filtrar o la funcionalitat de fer NAT.

Exemples:

| Taules  | Filter, NAT          |
| ------- | -------------------- |
| Cadenes | IN, OUT, FORWARD     |
| Regles  | ACCEPT, DROP, REJECT |

La sintaxis que empra iptables per afegir les regles és la següent:
```
iptables [-t taula] -A/I cadena [opcions] -j 
```

Veim que es pot triar la taula, la cadena i que volem fer amb ella. Si no indicam cap taula, pren per defecte la taula **filter**.

Però ens hem de fixar en que hi ha les comandes **-A/I**. Això serveix per afegir (-A) la regla al final de les regles que ja hi ha a la taula seleccionada o insertar-la al principi (-I) de la mateixa. Hem de pensar que iptables és una taula de regles que tenen un ordre. Quan es fa la revisió d’un paquet i coincideix amb una regla,  aquesta s’executa i ja no se segueix més envant. És a dir, la primera regla que coincideix amb els paràmetres trobats, és la que actua i la resta són obviades. 

---
# Taules i cadenes
Iptables té per defecte 5 taules: filter, nat, mangle, raw i security. Noltros ens centrarem només en les més pràctiques pel curs que són filter i nat.
## Taula Filter
És la taula que s’encarrega de filtrar paquets. És la que més emprarem ja que és la que ens permet fer el filtratge del que volem que entri o surti del PC, sempre i quan aquest no faci funcions de router.

Primerament veurem les regles aplicades a cada cadena de la taula filter:
```
sudo iptables -t filter -L
```

 ![[Pasted image 20241213230552.png]]

Com hem dit abans, aquesta taula s'utilitza per al filtratge de paquets. Es podria dir que aquesta taula és la que dóna la connotació de firewall a iptables i si no s’especifica, es pren per defecte.

Es defineixen 3 cadenes que ens permeten tractar les dades que entren, surten o passen. Són les següents:

| Cadena  | Descripció                                                                                                      |
| ------- | --------------------------------------------------------------------------------------------------------------- |
| INPUT   | Qualsevol paquet d’entrada es tracta d’acord amb les regles escrites amb aquesta cadena                         |
| OUTPUT  | Qualsevol paquet de sortida es tracta d’acord amb les regles escrites amb aquesta cadena                        |
| FORWARD | Qualsevol paquet que passa a través de l’ordinador es tracta d’acord amb les regles escrites amb aquesta cadena |

Les cadenes (INPUT, OUTPUT i FORWARD) són la meitat de la lògica d’IPTables. El funcionament bàsic es du a terme en funció de les regles que s’apliquen a cada cadena.

**Exemple 1:**
Volem bloquejar tot el tràfic que vengui de l’ordinador 192.168.1.100 al nostre ordinador.

![[Pasted image 20241213231451.png]]

Clarament hauríem d’emprar la cadena INPUT al PC 192.168.1.10
```
iptables -A INPUT
```

Però és evident que així no bloquejam la IP, simplement indicam que la regla serà d’entrada. Per això ara introduïm una opció:
```
-s, --source <adreça>: Ens indica l'adreça d'origen
```

Seguint amb l’exemple anterior, la comanda de forma molt rudimentària seria:
```
iptables -A INPUT -s 192.168.1.100
```

Pareix que així ja aconseguim algo més, però encara ens manca dir que hem de fer amb el paquet. Per això definim l’opció  -j, que li indica a IPTables que fer amb el paquet.
```
-j, --jump <target>: Ens indica què hem de fer amb el paquet
```

 Les opcions són:

- ACCEPT: Accepta el paquet
- DROP: Tira el paquet
- REJECT: Rebutja el paquet

Diferències entre DROP i REJECT:

- DROP, l’ordinador rebutja el paquet i NO avisa a la font de que ho ha fet. La font tornarà a fer reintents (si escau) en el moment en que passi el timeout.   
- REJECT, l’ordinador rebutja el paquet i avisa a la font amb un paquet ICMP de manera que l’origen està assabentat de que el paquet ha sigut rebutjat.

Així doncs, ara sí que podem crear la comanda correcta d’IPTables per tal de bloquejar la IP de l’exemple inicial:
```
iptables -A INPUT -s 192.168.1.100 -j DROP
```

Aquesta comanda està indicant que tots els paquets que arribin a l’ordinador (-A INPUT) des de la IP 192.168.1.100 (-s 192.168.1.100) han de ser rebutjats sense donar explicacions al remitent (-j DROP)

> **Recordatori**: Veim que indicam la regla amb un append (-A). Això vol dir que estam afegint una regla a les regles que ja existeixen. És a dir, la regla que introduïm es posa al final de les regles de IPTables. Si el que volem és posar-la al principi, haurem de posar -I en comptes de -A

**Exemple 2:**
Volem bloquejar tot el tràfic que vagi a l’ordinador 192.168.1.100

![[Pasted image 20241213231910.png]]

Per poder confeccionar correctament aquesta regla hem de indicar que és una regla de sortida (OUTPUT) i hem d’indicar amb l’opció -d el destí:
```
-d, --destination <adreça>: Ens indica l'adreça de destí
```

Així doncs, la regla que hauríem de confeccionar quedaria d’aquesta forma:
```
iptables -A OUTPUT -d 192.168.1.100 -j DROP
```

>**FIxa’t:** Per bloquejar una direcció de DESTINACIÓ, hem d’indicar que és de sortida (-A OUTPUT) i que la IP és de destí (-d)|

**Exemple 3:**
Volem que es bloquegin totes les connexions que es facin de la IP 192.168.1.100 al nostre ordinador, per telnet.

![[Pasted image 20241213232047.png]]

En aquest cas introduïm una nova opció, -p:
```
-p, --protocol  <protocol> -–destination-port <port>: Ens indica quin protocol volem modificar i a quin port es troba
```

El protocol pot prendre els valors:

- TCP   
- UDP
- ICMP

Per als ports més comuns, en comptes d’emprar el número podem emprar el nom: telnet, ftp, http… --

Així la regla que a confeccionar serà:
```
iptables -A INPUT -s 192.168.1.100 -p tcp --destination-port telnet -j DROP  iptables -A INPUT -s 192.168.1.100 -p tcp --dport telnet -j DROP
```
  
**Exemple 4:**
Volem que es bloquegin totes les connexions que es facin de la xarxa 192.168.1.0/24 al nostre ordinador, per telnet.

![[Pasted image 20241213232212.png]]

En aquest cas, simplement hem de saber que podem emprar la notació CDIR tant en font com destinació:
```
iptables -A INPUT -s 192.168.1.0/24 -p tcp –destination-port telnet -j DROP
```

**Exemple 5:**
Tenim un PC que fa de servidor de telnet, però està entre la xarxa local e Internet. Per això, aquest PC té dues targetes: eth0 que es connecta a la xarxa interna i eth1 que es conecta a Internet. 

![[Pasted image 20241213232333.png]]  

Volem que els ordinadors de la xarxa local puguin accedir per telnet al PC, però no puguin els ordinadors que estan a Internet. En poques paraules, se vol evitar que se connectin per telnet des de Internet.

En aquest cas introduïm les opcions, -i i -o:
```
-i, --in-interface <interfaç>: Ens indica la interfaç d’entrada<br><br>-o, --out-interface <interfaç>: Ens indica la interfaç de sortida
```

La solució seria:
```
iptables -A INPUT -p tcp –destination-port telnet -i eth1 -j DROP
```

>Notem: D’aquesta forma tancam qualsevol paquet telnet provinent d’Internet

**Exemple 6:**
El mateix PC ara vol donar Internet als PCs de la xarxa local. Per això hem de fer que el trànsit que li arriba de la eth0 passi a la eth1. En aquest exemple, la xarxa local té un adreçament 172.16.1.0/24 i la xarxa de fora té l’adreçament 192.168.1.0/24. En el PC tenim la eth0 amb IP 172.16.1.1 i a la eth1 tenim la 192.168.1.1.  

![[Pasted image 20241213232709.png]]


La comanda que hauríem d’emprar per fer que el trànsit de la xarxa passés a través del servidor seria:
```
iptables -A FORWARD -i eth0 -j ACCEPT  <br>iptables -A FORWARD -o eth1 -j ACCEPT
```

Però aquí ens trobam amb un problema, i és que en tenir un rang d'IP diferent, el router de casa no reconeix com a propis els paquets que puguin sortir d'una màquina darrere del firewall, ja que el rang no correspon. Per resoldre això es recorre a l'emmascarament. Iptables pot donar un tractament al paquet en qüestió per fer-lo passar per un paquet propi del seu rang. D'aquesta manera qualsevol cosa que s'enviï fora serà emmascarat amb la ip pròpia de eth1. Aquí és on entra la taula NAT.

## Taula NAT

En aquest cas ens posam en la situació en que el nostre firewall és una màquina intermitja  entre el trànsit que ens arriba d’Internet i de la nostra xarxa local. La màquina firewall fa de paret entre dues xarxes diferents. 

Aquesta taula només s'ha d'utilitzar per a NAT (Network Address Translation) sobre diferents paquets. En altres paraules, només s'hauria d'utilitzar per traduir el camp d'origen o el camp de destinació del paquet.

La taula nat es fa servir principalment per implementar regles relacionades amb la traducció d'adreces (Network Address Translation – NAT); als paquets traduïts se'ls altera l'adreça IP d'acord amb les regles definides.

Es defineixen 4 cadenes que ens permeten modificar les dades que entren o surten. Són les següents:

| Cadena      | Descripció                                                                                                         |
| ----------- | ------------------------------------------------------------------------------------------------------------------ |
| PREROUTING  | La cadena és utilitzada per modificar els paquets tan aviat com arriben al tallafocs                               |
| INPUT       | No té rellevància funcional perquè la taula nat no actua sobre el trànsit que acaba al sistema local               |
| OUTPUT      | La cadena és utilitzada per alterar els paquets generats al mateix host abans que arribin a l'etapa d'encaminament |
| POSTROUTING | S'utilitza per alterar paquets que estan a punt de deixar el tallafocs                                             |
Per veure les cadenes de la taula nat feim: 
```
sudo iptables -t nat -L
```

 ![[Pasted image 20241213233051.png]]


**Exemple 1:**
Per permetre als nodes de la LAN que tenen una adreça IP privada (172.16.1.0/24) comunicar-se amb xarxes públiques externes, configuram el tallafocs per a l’emmascarament IP, la qual cosa col·loca màscares a les peticions des dels nodes LAN amb l'adreça IP del dispositiu extern del tallafocs (en aquest cas, eth1):

```
iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
```

POSTROUTING permet alterar els paquets a mesura que deixen el dispositiu extern del tallafocs. S'especifica l'objectiu de -j MASQUERADE per emmascarar l'adreça IP privada d'un node amb l'adreça IP del tallafoc/porta d'enllaç. MASQUERADE  només és vàlid a la cadena POSTROUTING. 

### Tipus de NAT

#### 1. DNAT (Destination NAT)

Canvia l’adreça o port de destinació dels paquets.  
Ús típic: Redirigir trànsit entrant cap a un altre servidor o port.
  
Exemple:
```
iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 192.168.1.10:8080
```
  
Canvia la destinació dels paquets que arriben al port 80 cap a 192.168.1.10:8080.

#### 2. SNAT (Source NAT)

Canvia l’adreça IP d’origen dels paquets.  
Ús típic: Permetre que una xarxa privada comparteixi una única IP pública.

Exemple:
```
|iptables -t nat -A POSTROUTING -o eth0 -j SNAT --to-source 203.0.113.1|
```
  
  Canvia la IP d’origen dels paquets sortints per 203.0.113.1.

Alternativa: Masquerade  
Utilitzat quan la IP d’origen pot canviar dinàmicament, com en connexions PPPoE.
```
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```

#### 3. Redirecció local (Local redirect)

Redirigeix paquets entrants a un port local.  
Ús típic: Proxies o servidors transparents.

Exemple:
```
iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 3128
```

Redirigeix el trànsit del port 80 al port 3128 en la mateixa màquina.
#### Ressenya

- Quan feim peticions que són tan entrants com sortints, però que no especifiquen cap servei ni client, és un NATs genèric i no s’ha d’especificar res.
- Quan volem fer peticions cap a serveis externs (feim de client). Quan enviam peticions cap a serveis externs, el firewall ha de fer el que es coneix com SNAT o Source NAT.
- Quan ens fan peticions als nostres serveis interns (feim de servidor). Quan rebem peticions cap als nostres serveis, el firewall ha de fer el que es coneix com DNAT o Destination NAT.  


![[Pasted image 20241213233008.png]]

---
# Manipulació de regles

Per manipular les regles que estan donades d’alta a IPTables tenim les següents opcions:
- -L: Llista les regles
  
![[Pasted image 20241213234906.png]]

- -L -v: Llista les regles i dóna més informació 

![[Pasted image 20241213234934.png]]

  - -L --line-numbers: Llista les regles i les numera

![[Pasted image 20241213235016.png]]

- -S: Una altra forma de llistar de regles

![[Pasted image 20241213235057.png]]

- -A: Afegeix una regla (ja s’ha vist)
- -I: Inserta una regla al principi del llistat de regles

![[Pasted image 20241213235200.png]]

- -D: Esborra una regla

![[Pasted image 20241213235226.png]]

- -F: Esborra totes les regles

![[Pasted image 20241213235301.png]]

- -P: Canvia la política per defecte. En aquest cas hem d’especificar de quina taula, quina cadena i que ha de fer per defecte. P.e. normalment, la taula filter té les 3 cadenes en ACCEPT per defecte. Si volem fer que la cadena INPUT estigui tancada per defecte, és a dir, que no s’accepti cap paquet de fora, emprariem:

![[Pasted image 20241213235901.png]]

- Guardar les regles a un fitxer:
```
iptables-save > /root/firewall.rules
```

- Restaurar les regles d’un fitxer:
```
iptables-restore < /root/firewall.rules
```

- Guardar les regles de forma persistent:

Hem d’instal·lar iptables-persistent:
```
sudo apt install iptables-persistent
```

Cada pic que vulguem guardar les regles farem:
```
sudo netfilter-persistent save
```

---
# Opcions de iptables

| Comanda | Descripció                                                                                              |
| ------- | ------------------------------------------------------------------------------------------------------- |
| -s      | ip/xarxa d’origen                                                                                       |
| -d      | ip/xarxa de destí                                                                                       |
| -i      | interfície d’entrada                                                                                    |
| -o      | interfície de sortida                                                                                   |
| -m      | mòdul amb opcions de mòdul                                                                              |
| -p      | protocol: tcp/udp<br><br> --dport: port de destinació<br><br> --sport: pot d’origen<br><br> --tcp-flags |

---
# Mòduls interessants
- -m limit
   -  --limit: Estableix el nombre de coincidències per a un interval de temps en particular
   - --limit-burst: Estableix un límit en la quantitat de paquets que poden coincidir en una regla a l’hora
  
Exemple:
```
sudo iptable -A INPUT -p tcp -m limit --limit 60/s --limit-burst 20 -j ACCEPT
```
  
En aquest cas acceptam les connexions entrants per tcp amb un límit de 60 per segon però com a molt, en ràfegues de 20.
- -m state
   - --state: Filtra pels estats de connexió d’un paquet: NEW, ESTABLISHED, RELATED, INVALID

| Estat       | Descripció                                                                                                         |
| ----------- | ------------------------------------------------------------------------------------------------------------------ |
| NEW         | El paquet està creant una connexió nova o forma part d'una connexió bidireccional que no s'havia vist anteriorment |
| ESTABLISHED | El paquet s'associa amb altres paquets en una connexió establerta                                                  |
| RELATED     | El paquet està iniciant una connexió nova relacionada d'alguna manera amb una connexió existent                    |
| INVALID     | El paquet no es pot lligar a una connexió coneguda                                                                 |

Exemple:
```
sudo iptables -A INPUT -i eth0 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
```

En aquest cas, acceptam les noves connexions i les que ja estan establertes, que venguin per tcp amb destinació el port 22.

---
# DMZ

Es poden establir regles iptables per encaminar el trànsit a certes màquines, com ara un servidor HTTP o FTP dedicat, en una zona desmilitaritzada (DMZ) — una subxarxa local especial dedicada a proporcionar serveis en un transportador públic com Internet. 

Per exemple, per configurar una regla per a l'encaminament de totes les peticions HTTP entrants a un servidor HTTP dedicat a l'adreça 10.0.4.2 (fora de l'interval 192.168.1.0/24 de la LAN), la traducció d'adreces de xarxa (NAT) crida a una taula PREROUTING per reenviar els paquets a la destinació correcta:

```
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j DNAT     --to-destination 10.0.4.2:80
```
  
Amb aquesta comanda, totes les connexions HTTP al port 80 des de fora de la LAN són encaminades al servidor HTTP en una xarxa separada de la resta de la xarxa interna. Aquesta forma de segmentació de la xarxa és més segura que permetre connexions HTTP a una màquina a la xarxa. Si el servidor HTTP és configurat per acceptar connexions segures, també hem redirigir el port 443.

Podem veure amb més detall en aquest document com se configura una [[DMZ amb IPTables]]

---
# Port Forwarding

El port forwarding ens serveix per redirigir el trànsit que arriba al Firewall per la targeta exposada a Internet, cap un un servidor (habitualment a la DMZ) que hagi de donar servei a l'exterior.

Podem veure amb més detall en aquest document, com se configura el [[Port Forwarding amb IPTables]]

---

# Script IPTABLES

```bash
#!/bin/bash
echo "Començam..."

# INTERFACES
INET="ens18"
DMZ="ens20"
MZ="ens19"

IP_INET = "192.168.1.1"
IP_DMZ = "10.0.1.1"
IP_MZ = "10.0.2.1"
IP_APACHE="10.0.1.10"

SUBNET_DMZ = "10.0.1.0/24"
SUBNET_MZ = "10.0.2.0/24"

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
iptables -t nat -A POSTROUTING -o $INET -s $SUBNET_DMZ -j MASQUERADE
iptables -t nat -A POSTROUTING -o $INET -s $SUBNET_MZ -j MASQUERADE
iptables -t nat -A PREROUTING -i $INET -p tcp --dport 80 -j DNAT --to-destination $IP_APACHE:80
iptables -t nat -A PREROUTING -i $INET -p tcp --dport 443 -j DNAT --to-destination $IP_APACHE:443
iptables -t nat -A POSTROUTING -o $DMZ -p tcp -d $IP_APACHE --dport 80 -j SNAT --to-source IP_DMZ
iptables -t nat -A POSTROUTING -o $DMZ -p tcp -d $IP_APACHE --dport 443 -j SNAT --to-source $IP_DMZ
echo "Regles de NAT assignades"

echo "Fi de la configuració"
```

---

# Fonts emprades

| Descripció                                | URL                                                                                                                                               |
| ----------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| IPTABLES Red Hat                          | https://web.mit.edu/rhel-doc/4/RH-DOCS/rhel-rg-en-4/s1-iptables-options.html                                                                      |
| Forward i NAT                             | https://web.mit.edu/rhel-doc/4/RH-DOCS/rhel-sg-es-4/s1-firewall-ipt-fwd.html                                                                      |
| NAT                                       | https://elbinario.net/2019/03/18/iptables-para-torpes/                                                                                            |
| NAT netfilter                             | https://netfilter.org/documentation/HOWTO/es/NAT-HOWTO.html                                                                                       |
| 30 Most Popular IPTABLES Command in Linux | https://www.cyberithub.com/iptables-command-in-linux/                                                                                             |
| Iptables com funciona                     | https://behacker.pro/que-es-iptables-y-como-funciona/                                                                                             |
| Manual iptables                           | https://linux.die.net/man/8/iptables                                                                                                              |
| Prerouting                                | https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/security_guide/sect-security_guide-forward_and_nat_rules-prerouting |
| IPTABLES Cyberithub                       | https://www.cyberithub.com/iptables-command-in-linux/                                                                                             |
| El baul del programador                   | https://elbauldelprogramador.com/20-ejemplos-de-iptables-para-sysadmins/                                                                          |
