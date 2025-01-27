Easy Wireguard és una versió de la VPN Wireguard que té tant una instal·lació al servidor com la posterior configuració, bastant senzilla. Per aquesta activitat, farem servir docker compose que alleugereix molt la feina i com empra tecnologia de contenidors, aïlla aquest servei d'altres, poguent fer servir un mateix servidor per distints serveis.


# Instal·lació
Primerament hem d'haver instal·lat la darrera versió de docker. Revisar el document [[Instal·lació de docker a Ubuntu]] 

Un cop tenim docker instal·lat hem de crear les carpetes al home del nostre usuari iesemili:
```
mkdir docker
cd docker
mkdir wireguard
cd wireguard
```

En aquesta carpeta cream el fitxer de docker-compose:
```
nano docker-compose.yml
```

I podem enganxar el següent codi:
```yml
services:
  wg-easy:
    environment:
      # Change Language:
      # (Supports: en, ua, ru, tr, no, pl, fr, de, ca, es, ko, vi, nl, is, pt, chs, cht, it, th, hi, ja, si)
      - LANG=es
      # ⚠️ Required:
      # Change this to your host's public address
      - WG_HOST=vpn.local

      # Optional:
      # - PASSWORD_HASH=$$2y$$10$$hBCoykrB95WSzuV4fafBzOHWKu9sbyVa34GJr8VV5R/pIelfEMYyG # (needs double $$, hash of 'foobar123'; see "How_to_generate_an_bcrypt_hash.md" for>
      # - PORT=51821
      # - WG_PORT=51820
      # - WG_CONFIG_PORT=92820
      # - WG_DEFAULT_ADDRESS=10.8.0.x
      # - WG_DEFAULT_DNS=1.1.1.1
      # - WG_MTU=1420
      # - WG_ALLOWED_IPS=192.168.15.0/24, 10.0.1.0/24
      # - WG_PERSISTENT_KEEPALIVE=25
      # - WG_PRE_UP=echo "Pre Up" > /etc/wireguard/pre-up.txt
      # - WG_POST_UP=echo "Post Up" > /etc/wireguard/post-up.txt
      # - WG_PRE_DOWN=echo "Pre Down" > /etc/wireguard/pre-down.txt
      # - WG_POST_DOWN=echo "Post Down" > /etc/wireguard/post-down.txt
      # - UI_TRAFFIC_STATS=true
      # - UI_CHART_TYPE=0 # (0 Charts disabled, 1 # Line chart, 2 # Area chart, 3 # Bar chart)
      # - WG_ENABLE_ONE_TIME_LINKS=true
      # - UI_ENABLE_SORT_CLIENTS=true
      # - WG_ENABLE_EXPIRES_TIME=true
      # - ENABLE_PROMETHEUS_METRICS=false
      # - PROMETHEUS_METRICS_PASSWORD=$$2a$$12$$vkvKpeEAHD78gasyawIod.1leBMKg8sBwKW.pQyNsq78bXV3INf2G # (needs double $$, hash of 'prometheus_password'; see "How_to_generat>

    image: ghcr.io/wg-easy/wg-easy
    container_name: wg-easy
    volumes:
      - /home/iesemili/docker/wireguard:/etc/wireguard
    ports:
      - "51820:51820/udp"
      - "51821:51821/tcp"
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
      # - NET_RAW # ⚠️ Uncomment if using Podman
    sysctls:
      - net.ipv4.ip_forward=1
      - net.ipv4.conf.all.src_valid_mark=1
```

Per a entorns en producció, és recomanable **posar una contrasenya** per gestionar els usuaris o peers. Per això hauríem d'habilitar l'opció *PASSWORD_HASH* tal i com s'indica que s'ha de fer a la [pàgina de github](https://github.com/wg-easy/wg-easy/blob/master/How_to_generate_an_bcrypt_hash.md).

Un cop tenim creats les carpetes i el docker-compose.yml, l'aixecam:
```
docker compose up -d
```

Si tenim ben configurada la configuració de xarxa i podem accedir a Internet, ens baixarà els paquets i el posarà en marxa:

![[Pasted image 20241214161535.png]]

Per accedir al configurador de la VPN, és exclusiu per web, amb la qual cosa haurem de redirigir un port del firewall al servidor de la VPN al port d'administració que és el 51821.
```
iptables -t nat -A PREROUTING -i ens18 -p tcp --dport 51821 -j DNAT --to 10.0.1.103:51821
iptables -t nat -A POSTROUTING -o ens19 -p tcp --dport 51821 -d 10.0.1.103 -j SNAT --to-source 10.0.1.101
```

Si accedim a la IP del Firewall al port de configuració de la VPN, ens toca sortir la pàgina de gestió de la VPN.

![[Pasted image 20241214162033.png]]

# Fonts:

- [Github wg-easy](https://github.com/wg-easy/wg-easy/blob/master/docker-compose.ymlhttps://github.com/wg-easy/wg-easy/blob/master/docker-compose.yml)
