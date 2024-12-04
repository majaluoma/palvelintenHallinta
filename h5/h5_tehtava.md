  graiikkojen checksum:
  928fcf34efd0719a3560cbab6821d71ce686b6315e8825360fba87a7a94d7846

  peli:
  c7648c9aac11daeb7f1bdd7a07346865ae590c07af4a6d02a5ed01fb33eba067

## OpenTTD -infra koodina
Projektin tarkoituksena oli tuottaa koodi, joka rakentaa openTTD -pelipalvelimen kohdekoneelle käyttäen hyödyksi Saltstackia. Käyn tässä raportissa läpi kaikki tarvittavat vaiheet. Halusin myös konfiguroida pelin siten, että se toimisi koko viikonlopun pituisena marathon -pelinä, jota voisi pelata muiden lanin pelien yhteydessä.

7:45 Aloitin tehtävän tekemisen.

Loin kaksi vagrant -virtuaalikonetta **master** ja **minion1** seuraavilla alkuskripteillä:  

```sh
# Copyright 2019-2021 Tero Karvinen http://TeroKarvinen.com
$tscript = <<TSCRIPT
set -o verbose
apt-get update
apt-get -y install tree
apt-get -y install curl
sudo mkdir -p /etc/apt/keyrings
sudo curl -fsSL https://packages.broadcom.com/artifactory/api/security/keypair/SaltProject>
sudo curl -fsSL https://github.com/saltstack/salt-install-guide/releases/latest/download/s>
sudo apt-get update
echo "Done - set up test environment - https://terokarvinen.com/search/?q=vagrant"
TSCRIPT

# Author: Olli
$minion = <<TSCRIPT
sudo apt-get update
sudo apt-get install -y salt-minion
echo "master: 192.168.56.88" | sudo tee /etc/salt/minion
sudo systemctl restart salt-minion
echo "Done - set up minion environment"
TSCRIPT

# Author: Olli
$master = <<TSCRIPT
sudo apt-get update
sudo apt-get install -y salt-master
sudo systemctl restart salt-master
echo "Done - set up minion environment"
TSCRIPT

```

![alt text](/images/image-11.png)

Loin openttd -moduulin saltille master -koneella ja latasin tarvittavat Openttd -tiedostot.

```sh
$vagrant@master sudo mkdir -p /srv/salt/openttd
$vagrant@master cd /serv/salt/openttd
$vagrant@master sudo curl -O https://cdn.openttd.org/openttd-releases/14.1/openttd-14.1-linux-generic-amd64.tar.xz
$vagrant@master sha256sum openttd-14.1-linux-generic-amd64.tar.xz 
```

Asensin Openttd -ohjelman master -koneelle, jotta voisin testata sitä paikallisesti ja saada konfiguraatiotiedostot käyttöön. Asensin ohjelman /opt -kansioon (Hoffman & Gloor 2024)

```sh
$vagrant@master sudo tar -xJf ./openttd-14.1-linux-generic-amd64.tar.xz -C /opt
$vagrant@master sudo cp -s /opt/openttd-14.1-linux-generic-amd64/openttd /usr/local/bin/openttd
$vagrant@master openttd --help
```
openttd: error while loading shared libraries: libgomp.so.1: cannot open shared object file: No such file or directory

```sh
$vagrant@master sudo apt install libgomp.so.1
$vagrant@master openttd --help
$vagrant@master openttd -Df

```
![alt text](/images/image.png)  
![alt text](/images/image-2.png)  

Katsotaan seuraavkasi mistä voisi löytyä konfiguraatiotiedosto `openttd.cfg`. Käytin komentoja `ls -a`, `find -name 'openttd'` ja lopulta luin openttd sivuilta, että asetustiedosto on kotihakemistossa `~/.config`. Sieltä ei kuitenkaan vielä löytynyt tiedostoa, vaikka kansio oli kyllä olemassa. Ajoin kotihakemistossa `sudo find -name 'openttd.cfg'` Eikö mitään löytynyt. No, käynnistin serverin uudestaan komennolla, jossa otin huomioon portin ja halusin pitää konsolin auki.  
```sh
$vagrant@master openttd -D localhost:3001:
```
Ja sain viestin:  

![alt text](/images/image-3.png)

Openttdtä ei ilmeisesti kannattaisi ajaa roottina. Ehkä ohjelma pitäisi asentaa käyttäjälle? ( Planetmaker https://www.tt-forums.net/viewtopic.php?t=70615)

Purin ohjelman kotihakemistoon ja ajoin sieltä ja nyt valitti taas grafiikkasetistä. Jotain kuitenkin tapahtui ja yritin komennoilla `ps` ja `top` selvittää oliko ohjelma päällä, mielestäni ei (Ayodeji 2024).

![alt text](/images/image-4.png)
![alt text](/images/image-5.png)

Luin openttd --help komentoa vähän tarkemmin ja olin ainakin laittanut komentoja väärään järjestykseen. Kokeilin seuraavaksi `openttd -f -D localhost:3001`

![alt text](/images/image-6.png)

`ps -x` Ei kuitenkaan näyttänyt vieläkään mitään. Menin kotihakemistoon ja `find -name '*log*'` löysin logitiedoston ja tsekkasin sitä. Noo sama grafiikkaongelma. Menin lukemaan openttd manuaaleja. ajattelin että ohjelma pitäisi onnistua käynnistämään ilman graafista liittymää.

No siellähän luki että "OpenTTD needs some additional graphics and sound files to run." Tätä en muistanutkaan, mutta eikun asentamaan. Manuaalista löyty pari ilmaista grafiikkakirjastoa. Kastoin Openttd asennusopasta.

Latasin grafiikat suoraan moduuliin, koska tarvitsisin niitä myöhemmin minionin kanssa:

```sh
$vagrant@master sudo curl -O https://cdn.openttd.org/opengfx-releases/7.1/opengfx-7.1-all.zip'
$vagrant@master sha256sum ./opengfx-7.1-all.zip 
$vagrant@master tar -xf opengfx-7.1-all.zip -C /tmp/openttdGfx
# Virhe: tar: This does not look like a tar archive
$vagrant@master sudo apt install unzip
$vagrant@master sudo unzip -q opengfx-7.1-all.zip 
$vagrant@master sudo tar -xf opengfx-7.1.tar -C /tmp
```

Sitten menin lukemaan tuon grafiikkasetin manuaaleja. Taria ei olisi tarvinnut purkaa. `sudo rm -r -f  opengfx-7.1/`  

![alt text](/images/image-7.png)

No, laitoin tämän nyt sitten kansioon (koitan nyt ensiksi /opt/ -kansiota) ja sain seuraavan errorin:  

![alt text](/images/image-8.png)

Ja kielikansiossa on kyl kamaa...  

![alt text](/images/image-9.png)

Ongelma oli siinä, että käytin komentoa ympäristömuuttujan kautta. Kun käynniskin komennon suoraan kansiosta `./openttd` homma lähti toimimaan. Himmeä mäihä että tajuisin tuon.

![alt text](/images/image-12.png)
![alt text](/images/image-13.png)

Hypoteesini oli, että kun peli  startattu, myös asetustiedosto löytyisi ja tämä piti paikkansa. `sudo find -name 'openttd.cfg'` Kopioin koko asetustiedoston tiedoston saltin moduuliin `sudo cp openttd.cfg /srv/salt/openttd/`

![alt text](/images/image-15.png)

Ennen kuin muutan muita asetuksia, niin yritän saada tämän toimimaan minionilla. Porttikonfiguroinnin teen vasta kun tämä kaikki toimii. 

```sh
$vagrant@master sudoedit init.sls
```
```yaml
unzip:
  pkg.installed
libgomp1:
  pkg.installed
/tmp/openttd-14.1-linux-generic-amd64.tar.xz:
  file.managed:
    - source: salt://openttd/openttd-14.1-linux-generic-amd64.tar.xz
tar -xJf /tmp/openttd-14.1-linux-generic-amd64.tar.xz -C /opt:
  cmd.run:
    - creates: /opt/openttd-14.1-linux-generic-amd64
/tmp/opengfx-7.1-all.zip:
  file.managed:
    - source: salt://openttd/opengfx-7.1-all.zip
unzip -q /tmp/opengfx-7.1-all.zip -d /opt/openttd-14.1-linux-generic-amd64/baseset:
  cmd.run:
    - creates: /opt/openttd-14.1-linux-generic-amd64/opengfx-7.1.tar
/home/vagrant/.config/openttd/openttd.cfg:
  file.managed:
    - source: salt://openttd/openttd.cfg
/home/vagrant/openttd-14.1-linux-generic-amd64/openttd -f -D localhost:3979:
  cmd.run
```

Hyväksyin minionin avaimet
```sh
$vagrant@master sudo salt-key -A
$vagrant@master sudo salt '*' state.apply openttd

```
Yhteys ei toiminut ja sama juttu `sudo salt '*' ping`
![alt text](image.png)


Eiköhän aloiteta alusta. Tuhosin virtuaalikoneet ja pistin ne uusiksi päälle. Hyväksyin avaimet, testasin pingin. 11:00 ruokatauko.

![alt text](image-1.png)

11.15 jatkuu

```sh
$vagrant@master sudo salt-key -A -y
$vagrant@master sudo salt '*' test.ping 
$vagrant@master sudo mkdir -p /srv/salt/openttd
$vagrant@master cd /srv/salt/openttd/
$vagrant@master sudo curl -O https://cdn.openttd.org/opengfx-releases/7.1/opengfx-7.1-all.zip
$vagrant@master sha256sum ./opengfx-7.1-all.zip 
$vagrant@master sudo curl -O https://cdn.openttd.org/openttd-releases/14.1/openttd-14.1-linux-generic-amd64.tar.xz
$vagrant@master sha256sum ./openttd-14.1-linux-generic-amd64.tar.xz
$vagrant@master sudoedit init.sls
$vagrant@master sudoedit openttd.cfg
$vagrant@master sudo salt '*' state.apply openttd
```
graiikkojen checksum:
928fcf34efd0719a3560cbab6821d71ce686b6315e8825360fba87a7a94d7846
peli:
c7648c9aac11daeb7f1bdd7a07346865ae590c07af4a6d02a5ed01fb33eba067


Sain jonkin tosi mysteerisen salt -virheen. Aaoitan poistamalla rivit init.sls:stä ja suorittamalla ne yksi kerrallaan. Samalla tulee tsekattua idempotenssi.

Aloin ajamaan ohjelmaa yksi rivi kerrallaan ja kaikki meni loistavasti ja idempotentisti. Menin jossain välissä tarkistamaan minionilta että tapahtuuko siellä mitään:

![alt text](image-2.png)

Korjasin ennen konfiguraatiokohdan ajamista vielä:

```sh
/home/vagrant/.config/openttd/openttd.cfg:
  file.managed:
    - source: salt://openttd/openttd.cfg
    - makedirs: True
```
![alt text](image-3.png)  

Lopulta koko init.sls oli kasassa ja toimi: Vielä ennen lopullisen idempotenssin testaamista, pitäisi viimeiseen run -komentoon keksiä jotain. Olisi myös siistimpää käyttää service.running tilafunktiota, mutta en tiedä miten saisin selville openttd demonin nimen. Luin vähän systemctl manuaaleja ja Saltin manuaaleja liittyen service.running -funktioon. En kuitenkaan keksinyt miten asiaa lähtisi lähestymään. Kysyin ChatGPT:ltä suuntaa.

![alt text](image-4.png)

ChatGPT ohjasi minut komennon pgrep openttd äärelle. Sitä kautta pystyn löytämään prosessin pid -numeron komennolla `pgrep openttd`. Lisäsin tämän tarkistamisen cmd.run -komentoon. ChatGPT:ltä opin myös että ilmeisimmin tällaisista prosesseista voi luoda myös demonit, joita voisi ajaa service.running -funktiolla. En kuitenkaan ymmärtänyt asiaa kovin syvällisesti, niin päätin käyttää cdm.run -komentoa. (Luin asioista lisää Linuxize 2024, Salt Project 2024).

Em. komennolla saavutin idempotenssin: 
![alt text](image-5.png)

Viimeisenä vielä pitäisi tarkistaa että peliserveriin saa yhteyden. Openttd -sivusto kertoi että seruaavat portit kannattaa avata:

3979 UDP
3979 TCP

```sh
Lisäsin nämä rivit:
ufw:
  pkg.installed
ufw.service:
  service.running
sudo ufw allow in on wlo1 from 192.168.0.0/24 proto udp to any port 3979:
  cmd.run:
    - unless: sudo ufw status verbose | grep 3979/udp
sudo ufw allow in on wlo1 from 192.168.0.0/24 proto tcp to any port 3979:
  cmd.run:
    - unless: sudo ufw status verbose | grep 3979/tcp
sudo ufw allow in on wlo1 from 192.168.0.0/24 proto udp to any port 3978:
  cmd.run:
    - unless: sudo ufw status verbose | grep 3978/udp

```
![alt text](image-8.png)


Suljin vahingossa saltin portit ja lisäsin ne stateen (ensin suoritin komennot minionilla)


```sh
sudo ufw allow in on wlo1 from 192.168.56.88 proto tcp to any port 4505:
  cmd.run:
    - unless: sudo ufw status verbose | grep 4505/tcp
sudo ufw allow in on wlo1 from 192.168.56.88 proto tcp to any port 4506:
  cmd.run:
    - unless: sudo ufw status verbose | grep 4506/tcp
```
Katsoin host -koneelta, saanko yhteyden minioniin ja mitkä portit ovat auki `netstat 192.168.56.89` ja `netstat 192.168.56.89 | grep 3979`. Kokeilin myös `ping 192.168.56.89 3979`.

![alt text](image-6.png)

Peli ei kuitenkaan näy:

![alt text](image-7.png)  

Muistelin että konffeihin piti vielä laittaa joitain spesifejä juttuja ja näin olikin. Muokkasin pari asetusta. Muokkasin nämä ja välissä tuhosin openttd serverin `sudo kill 4380`

Testailin aina yhteyttä näillä komennoilla:
```sh
$vagrant@minion sudo ufw status verbose
$host sudo nmap -sU -p 3979 192.168.56.89
$host telnet 192.168.56.89 3979
```

![alt text](image-9.png)

![alt text](image-10.png)

Minulla oli sitten suria ongelmia saada tätä toimimaan ja tein paljon kaikenlaista, mitä en raportoinut. Kokeilin käytännössä eri opentTTD -konfiguraatioita. Huomasin lopulta ettei konfiguraatiotiedosto edes lataudu peliin, sillä logit valittivat ettei server_name ollut määritelty.

![alt text](image-11.png)

Etsimällä löysin kolme eri cfg -tiedostoa koneelta. Seuraavaksi muokkasin näitä, mutta muokkaukseni ylikirjoittautuivat.

Kokeilin käynnistää openttd -sovelluksen eri parametreilla. Lisäsin nämä komentoon:

  -x                  = Never save configuration changes to disk
  -c config_file      = Use 'config_file' instead of 'openttd.cfg'

config -tiedostona käytin openttd -kansioon luomaani ja master-koneelta tuomaami konfiguraatiotiedostoa.

Lopulta huomasin että sen lisäksi ette ikonfiguraatiotiedosto aukea, serveri kuuntelee vain osoitetta 127.0.0.1. eli localhost.

Lopulta hostaaminen onnistui kun muutin parametrin -D argumenttia localhost --> 192.168.56.89

![alt text](image-15.png)

![alt text](image-16.png)

Tähän lopetin työskentelyn. Projektiin jäi vielä keskeneräistä puuhailtavaa ja tässä muutama ongelma:
- konfiguraatiotiedostoa ei käytetä ohjelman käynnistyessä.
- kun konfiguraatiotiedosto muuttuu demoni ei käynnisty uudestaan.
- serverillä ei ole modeja käytössä

Kello 14.26 lopetin tehtävän, ei ole enempää aikaa selvittää em. asioita.


## Lähteet
Karvinen, Tero 2024a. Palvelinten Hallinta - Configuration Management Systems course - 2024 autumn. Lähde: https://terokarvinen.com/palvelinten-hallinta/ (Luettu 2024.11.06)  
Karvinen, Tero 2006. Raportin kirjoittaminen – Salt Stack Master and Slave on Ubuntu Linux. Lähde: https://terokarvinen.com/2006/06/04/raportin-kirjoittaminen-4/ (Luettu 28.10.2024)  
Chris Hoffman & Jordan Gloor 2024. https://www.howtogeek.com/117435/htg-explains-the-linux-directory-structure-explained/ (Luettu 4.12.2024)  
Openttd 2024: https://wiki.openttd.org/en/Manual/Dedicated%20server (Luettu 4.12.2024)  
Openttd 2024: https://wiki.openttd.org/en/Archive/Manual/Settings/Openttd.cfg (Luettu 4.12.2024)  
Bolaji Ayodeji 2024. https://www.freecodecamp.org/news/linux-list-processes-how-to-check-running-processes/ (Luettu 4.12.2024)  
Openttd 2024. How to Zip or Unzip Files From the Linux Terminal https://wiki.openttd.org/en/Manual/Installation (4.12.2024)  
McKay, Dave 2024. https://www.howtogeek.com/414082/how-to-zip-or-unzip-files-from-the-linux-terminal/ (Luettu 4.12.2024)  
Salt Project 2024. salt.states.cmd https://docs.saltproject.io/en/latest/ref/states/all/salt.states.cmd.html (Luettu 4.12.2024)  
Linuxize 2024. https://linuxize.com/post/pgrep-command-in-linux/ (Luettu 4.12.2024)  
## Käytettyjen laitteiden tekniset tiedot

Asus ROG Strix GT15 

-   Suoritin: Intel® Core™ i5-10400F -6-ydinsuoritin, 2,9-4,3 GHz, 12 Mt välimuisti
-   Piirisarja: Intel® B460
-   Keskusmuisti: 16 Gt DDR4 2933 MHz
-   Tallennustila: 512 Gt M.2 NVMe PCIe 3.0 SSD
-   Näytönohjain: NVIDIA® GeForce® GTX 1660 6GB (1x HDMI, 1x DP, 1 x DVI)
-   Ääni: SupremeFX S1220A Codec
-   Verkko: Gigabit Ethernet, Intel WiFi 6 (802.11ax), Bluetooth 5.0
-   Käyttöjärjestelmä: Windows 10 Home 64-bit

Tätä dokumenttia saa kopioida ja muokata GNU General Public License (versio 2 tai uudempi) mukaisesti. http://www.gnu.org/licenses/gpl.html

Pohjautuu Palvelinten hallinta -kurssin tehtävään: https://terokarvinen.com/palvelinten-hallinta/