# UD8. ROUTING

## El router
- Permet connectar dues xarxes diferents a nivell 3. 
- Dóna la ruta o camí per a què els paquets arribin a la seva destinació.
- Comprova l'adreça final dels paquets que li arriben i els transmet per la xarxa corresponent
- S'empren com a Gatweays o portes d'enllaç, que permeten la sortida d'una xarxa local a una més gran, com ara Internet.
- Cada port del router té assignada una IP que és la que correspon a la xarxa que connecta.


## Tipus
Els routers poden ser:
- Dispositius de xarxa
- Ordinadors amb un programari per fer de router

## Configuració
Es poden configurar de les maneres:
- Cable de consola   
En aquest cas s'empra un emulador de terminal (putty per windows, screen per Ubuntu) que ens permet connectar-mos al sistema operatiu del router i entrar en mode comandes.   
Se sol connectar per un cable serie (USB amb conversor DB9) i es configura la connexió com una connexió sèrie, configurant els paràmetres que ens indiqui el fabricant (velocitat, Bits de dades, Bits d'stop, Paritat i Control de fluix)
- Cable RJ45   
En aquest cas ens connectam al router mitjançant un navegador a la IP de configuració del mateix. Aquesta IP ve donada pel fabricant i pot variar inclús entre diferents models del mateix fabricant.

El programa *Packet Tracer* ens permet simular com si ens haguessim connectat al router mitjançant un cable de consola. És per això que, quan haguem de configurar un router CISCO, es recomana sempre de fer-ho mitjançant un cable de consola, malgrat sigui possible fer-ho per RJ45.

## Modes de treball
- Usuari
- Privilegiat
- Configuració global

### Mode usuari
El mode usuari és el més limitat del router i es deixa per aquelles persones que no tinguin accés o conneixement a bastament del router.   

Les opcions més interessants que trobam són:
- enable
- exit
- ping
- traceroute
- show version
- ssh

### Mode privilegiat
Ens permet veure la configuració del router però no fer modificacions substancials. 

Les opcions més interessants que trobam són:
- Configure terminal
- exit
- show
    - arp
    - ip

### Mode configuració global

