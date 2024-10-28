# palvelintenHallinta
Kurssin Palvelinten hallinta kotiläksyjen verkkosivu

## h0
Tämä Github repositorio toimii tehtävän verkkosivuna. Tämä README-md tiedosto toimii tehtävänpalautusten ja raporttien päätiedostona.

## h1
### x)
Tulemme harjoittelemaan kurssilla mm. salt -komennon käyttämistä. salt'ia tyypillisesti käytetään laajojen tietokoneverkkojen hallintaan. Luin artikkelit todennäköisesti väärässä järjestyksessä. Nyt perehdyin raporttien kirjoittamistiedostoon ja siellä ohjeistettiin tarkasti kuvaamaan tapahtumia. Luulin aluksi että seuraava asennetaan hallinnoivalle koneelle:
$ sudo apt-get update
$ sudo apt-get -y install salt-minion
$ sudoedit /etc/salt/minion
master: 10.0.0.88
id: yourid
$ sudo systemctl restart salt-minion.service

Mutta todellisuudessa tuo on hallittavalle koneelle asennettava paketti. Hallinnoivalle koneelle asennetaan salt-master:
$ sudo apt-get update
$ sudo apt-get -y install salt-master
hostname -I
10.0.0.88
$ sudo salt-key -A


(Karvinen 2018)
Ensin konfiguroidaan salt-master ja toisiksi viimeisessä komennossa hyväksytään uusi salt-slave. En vielä ymmärrä artikkelin Run salt command locally roolia tehtävässä, mutta parempi jatkaa. Tällä pystyy testaamaan master-slave-yhteyden matser koneelta:
$ sudo salt '*' cmd.run 'whoami'

Nyt aloitan tekemään tehtävää h1 -viisikko. Strategiana on asentaa linux-koneita Dockerin avulla, ja katsoa jos se riittäisi saamaan tehtävät toimimaan. Eli en käytä "kokonaista" virtuaalikonetta. Yritän tehdä tämän Karvisen raportointiohjeiden (2006) mukaan  

### a) 
1420. git clone ***
1421 loin compose.yaml -tiedoston
1422 käynnistin Docker desktop -ohjelman
1423 loin master.Dockerfile-tiedoston
1225 Piti katsoa mitä komento hostname -I tekee (ChatGPT)
1428 Piti tutkia mitä -y tekee (ChatGPT)
1437 kirjoitin Dockerfilet ja yamlit pohjaksi ja tarkistin chatGPT:ltä ovatko ne oikein. AI korjasi muutaman asian (mm. docker ei tarvitse sudoa ja käytin ympäristömuuttujaa väärin)
1444 docker compose up --> Ei onnistunut
1455 Vähän selvittelyä siitä missä vika ja selvisi että valitsemani Docker image ei sisältänyt saltStack -pakettia. Turvauduin eri pakettiin ja Whiten (2018) ohjeeseen
1456 git clone https://github.com/cyface/docker-saltstack.git
1456 cd docker-saltstack
1456 docker-compose up
1501 docker-compose exec salt-master bash --> Ei toimi
1503 docker container ls
1505 docker exec -it docker-saltstack-salt-master-1 bash  --> toimi
1506 salt '*' cmd.run 'whoami' --> root root@670b257d138f:/# 
1509 docker exec -it docker-saltstack-salt-minion-1 bash -->
master: salt-master
id:  (if left commented the id will be the hostname)
1520 Nyt piti lopettaa, en ehtinyt tehdä enempää
## Lähteet

Karvinen, Tero 2023. Run Salt Command Locally. Lähde: https://terokarvinen.com/2021/salt-run-command-locally/ (Luettu 28.10.2024)
Karvinen, Tero 2018. Salt Quickstart – Salt Stack Master and Slave on Ubuntu Linux. Lähde: https://terokarvinen.com/2018/03/28/salt-quickstart-salt-stack-master-and-slave-on-ubuntu-linux/ (Luettu 28.10.2024)
Karvinen, Tero 2006. Raportin kirjoittaminen – Salt Stack Master and Slave on Ubuntu Linux. Lähde: https://terokarvinen.com/2006/06/04/raportin-kirjoittaminen-4/ (Luettu 28.10.2024)
White, Timi 2018. The Simplest Way to Learn SaltStack. https://timlwhite.medium.com/the-simplest-way-to-learn-saltstack-cd9f5edbc967 (Luettu 28.10.2024)