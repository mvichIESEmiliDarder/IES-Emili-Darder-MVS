Para instalar y configurar un servidor DNS en Ubuntu para tu red local, usaremos **BIND9**, que es el servidor DNS más común en Linux.  

---

## **1️⃣ Instalación de BIND9**
Ejecuta en tu servidor Ubuntu:  
```bash
sudo apt update
sudo apt install bind9 -y
```

---

## **2️⃣ Configuración del servidor DNS**
### **Editar la configuración principal de BIND**
Abre el archivo de configuración de BIND:  
```bash
sudo nano /etc/bind/named.conf.local
```
Agrega esta configuración al final del archivo para definir la zona de tu dominio:

```plaintext
zone "tromeptasperez.com" {
    type master;
    file "/etc/bind/db.tromeptasperez.com";
};
```
Guarda y cierra el archivo (`CTRL + X`, luego `Y` y `ENTER`).

---

### **Crear la zona DNS**
Ahora creamos el archivo con los registros DNS:

```bash
sudo nano /etc/bind/db.tromeptasperez.com
```

Copia y pega lo siguiente, ajustando la IP de tu servidor si es necesario:

```plaintext
$TTL 86400
@   IN  SOA ns.tromeptasperez.com. admin.tromeptasperez.com. (
        2025032501 ; Serial
        3600       ; Refresh
        1800       ; Retry
        604800     ; Expire
        86400 )    ; Minimum TTL

    IN  NS  ns.tromeptasperez.com.
ns  IN  A   192.168.1.10
www IN  A   192.168.1.10
```

Guarda y cierra el archivo.

---

## **3️⃣ Configurar BIND para que escuche en la red local**
Edita el archivo de configuración de BIND9:

```bash
sudo nano /etc/bind/named.conf.options
```

Busca la sección:
```plaintext
        listen-on { 127.0.0.1; };
```
y modifícala para que escuche en todas las interfaces de red:

```plaintext
        listen-on { any; };
```

También asegúrate de permitir consultas desde tu red local. Busca:
```plaintext
        allow-query { localhost; };
```
y cámbialo a:
```plaintext
        allow-query { localhost; 192.168.1.0/24; };
```
(ajusta `192.168.1.0/24` según tu red).

Guarda y cierra el archivo.

---

## **4️⃣ Reiniciar BIND y verificar**
Ejecuta:
```bash
sudo systemctl restart bind9
sudo systemctl enable bind9
sudo systemctl status bind9
```
Si todo está bien, verás que el servicio está **activo**.

---

## **5️⃣ Probar el DNS en el servidor**
Desde el mismo servidor donde instalaste BIND9, prueba si resuelve `www.tromeptasperez.com`:

```bash
nslookup www.tromeptasperez.com 127.0.0.1
```
Debe responder con `192.168.1.10`.

---

## **6️⃣ Configurar los clientes para usar tu DNS**
En cada PC cliente, cambia la configuración de DNS en Ubuntu editando `/etc/resolv.conf`:

```bash
sudo nano /etc/resolv.conf
```

Agrega:
```plaintext
nameserver 192.168.1.10
```
Para que el cambio sea permanente en Ubuntu Desktop, edita la configuración de red o usa:

```bash
sudo nmcli con mod "nombre-de-tu-conexion" ipv4.dns 192.168.1.10
sudo nmcli con up "nombre-de-tu-conexion"
```

Si los clientes usan Windows, cambia el DNS en la configuración de la red manualmente.

---

## **7️⃣ Probar el DNS desde un cliente**
En un cliente, prueba con:

```bash
nslookup www.tromeptasperez.com 192.168.1.10
```
Si responde con `192.168.1.10`, ¡tu DNS está funcionando! 🎉

---

Así ya tienes un **DNS local** configurado para que tus PCs accedan a `www.tromeptasperez.com` en tu servidor. 🚀