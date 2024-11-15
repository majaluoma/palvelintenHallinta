# Salt -komentojen testaaminen paikallisesti virtuaalikoneella

h3 Daemoni
Raportti on kirjoitettu 2024-15-06 käyttämällä Asus ROG Strix GT15 -tietokonetta, tarkemmat tiedot raportin lopussa.

Komentotyökaluna on käytetty Git Bash -työkalua, joten komennot vastaavat paremmin Linux -ympäristöjä.

Raportoinnin mallina toimii Karvisen (2018) opas raportoinnista ja raportti on tehty osana palvelintan hallinta -opintojaksoa (Karvinen 2024a).

## x) Demonien hallinta

Salt stackilla voimme rakentaa konfiguraationhallintajärjestelmän, jossa voimme hallita suuria määriä tietokoneita ja niissä pyöriviä demoneita.

Demoni (palveluprosessi) on tietokoneen käyttöjärjestelmässä taustalla pyörivä prosessi, johon käyttäjällä ei ole suoraa interaktiivista yhteyttä. Se on keskeinen osa moderneja tietokoneita, jotka voivat pyörittää monia ohjelmia rinnakkain. (Wikipedia 2024).

Kun minion koneille asennetaan uusi daemoni, hallinta etenee aina seuraavassa järjestyksessä: 

1. Ladataan paketti kohdekoneelle
2. Siirretään palveluprosessi asetustiedosto kohdekoneelle
3. Käynnistetään prosessi uudelleen uusilla asetuksilla kohdekoneessa

Esimerkiksi voimme asentaa toimivan SSH -palvelimen kohdekoneelle seuraavalla tavalla. Tämä ohje noudattelee Karvisen (2018) laatimaa ohjetta samasta asiasta

Luomme masterkonfiguraatiotiedoston, joka tullaan kopioimaan kohdekoneelle:

        $master sudoedit /srv/salt/ssh/sshd_config

Luomme master -koneelle tilan, joka lataa sshd-paketin, hyödyntää konfigurointitiedostoa sekä käynnistää demonin uudestaan. Käytämme `watch` -parametria, jotta demoni käynnistyy vain silloin uudestaan kun tiedostoa muutetaan. Näin saavutamme tilafunktiossa idempotenssin:

        $master mkdir -p /srv/salt/ssh
        $master sudoedit /srv/salt/ssh/init.sls

        #init.sls
        #CONTENTS MAY BE REPLACED AUTOMATICLY
        openssh-server:
          pkg.installed
        /etc/ssh/sshd_config:
          file.managed:
            - source: salt://sshd_config
        sshd:
          service.running
            watch:
              -file: /etc/ssh/sshd_config

Ja lisäämme sen top.sls tiedostoon

        $master sudoedit /srv/salt/top.sls
            base:
            '*':
                - ssh

Nyt voimme ajaa tilan minion -koneella, jos se on yhdistetty master -koneeseen komennolla:

        $master sudo salt '*' state.apply

Seuraavaksi tutkin saltin manuaaleja komennoilla (Karvinen 2024a):

        $minion sudo salt-call --local sys.state_doc pkg 
        $minion sudo salt-call --local sys.state_doc file
        $minion sudo salt-call --local sys.state_doc service

Pkg.installed -tilaafunktiolle voidaan antaa parametreja. Str `version`,  spesifioi version, str `fromrepo`, määrittää repositorion ohjelmalle, joka ladataan. Paketteja voi ladata useamman kerralla list `pkgs -parametrilla`. 

Jos paketin haluaa poistaa koneelta, se onnistuu komennolla ``pkg-purged`` ja sillekin voi antaa parametriksi list `pkgs`. Toisin kuin pkg.removed, positaa myös konfiguraatiotiedostot.

File -tilafunktiollakin voi tehdä aika hassuja juttuja. Monimutkaisempaan käsittelyyn, on mahdollista esimerkiksi hyödyntää list `defaults` -paramteria, jolla voi tiedostoja muokata kohdejärjestelmän mukaan. File.managedista löytyy  `source`, joka määrittää tiedoston, joka kopioidaan. Esimerkkejä:

        # minion koneelta kopiointi
        source: /home/user/index-html
        # master koneelta kopiointi
        source: salt://etc/ssh/sshd_config
        # verkosta kopiointi, tarvitsee myös hash -paramterin
        source: https://domain.org
        # vaihtoehtoisesti voit määrittää sisällön contents -parametrilla.
        contents: |
          - Rivi 1
          - Rivi 2

``user`` ja `group` -paramerit määrittävät tiedoston omistajan ja `mode` -parametri tiedoston oikeudet Linuxilla. Näitä parametreja voi käyttää myös symlinkin kanssa.

``file.absent`` poistaa aina kaikki tiedostot ja kansiot, mutta jos haluaa vain poistaa tietyn kansion sisällön, ovi antaa parametriksi `clean=True`.

``file.symlink`` Luo symbolisen linkin sijaintiin ja tarvitsee parametrikseen `target`

Prosesseja voi sulkea komennolla `service.dead` ja käynnistää komennolla ``service.running``, molemmille voi antaa parametriksi boolean ``enable``, joka määrittää käynnistyykö ohjelma tietokoneen käynnistyessä. Daemoneja voi myös laittaa käynnistymään tietokoneen käynnistyessä erillisellä tilafunktiolla `service.enabled`.

Ennen tehtävien tekoa luin myös tehtävän (Karvinen 2024a) vinkit läpi. Sieltä löytyi hyvä vinkki testaamisen prosessiin, jota halusin hyödyntää raportissa:
1. Testaa
2. Alkutilanne (taikurin hihat tyhjät)
3. Käsin tehty ja toimii
4. Poistettu käsin tehty ennen automaatiota
5. Yksi tilafunktio (esim. file) sls-tiedostossa
6. Lopputilanne, osat
7. Lopputesti - mitä käyttäjä tekisi

Testaamisessa voi käyttää avuksi netcattia demonien olemassaolon tarkistamiseen ``nc -vz 192.168.1.1 8080``, ssh-asiakasta spesifisti sshd:n konfiguraation tarkistamiseen `ssh -p 8080 minion@192.168.1.1` ja curlia esimerkiksi apachen webserverin tarkistamiseen `curl -p 8080 192.168.1.1`.



## a) Asenna Apache koneelle


## b) Asenna SSH koneelle


## c) Rakenna oma Demonia hyödyntävä moduuli


## d) Konfiguroi VirtualHost

## e) Vapaaehtoinen
## f) Vapaaehtoinen
## g) Vapaaehtoinen


## Lähteet
Karvinen, Tero 2024a. Palvelinten Hallinta - Configuration Management Systems course - 2024 autumn. Lähde: https://terokarvinen.com/palvelinten-hallinta/ (Luettu 2024.11.06)  
Karvinen, Tero 2006. Raportin kirjoittaminen – Salt Stack Master and Slave on Ubuntu Linux. Lähde: https://terokarvinen.com/2006/06/04/raportin-kirjoittaminen-4/ (Luettu 28.10.2024)
Karvinen, Tero 2018. Pkg-File-Service – Control Daemons with Salt – Change SSH Server Port. Lähde: https://terokarvinen.com/2018/04/03/pkg-file-service-control-daemons-with-salt-change-ssh-server-port/?fromSearch=karvinen%20salt%20ssh (Luettu: 15.11.2024)
Wikipedia 2024. Daemon (Computing). lähde: https://en.wikipedia.org/wiki/Daemon_(computing) (Luettu 15.11.2024)
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