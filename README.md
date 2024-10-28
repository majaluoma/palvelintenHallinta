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
$ hostname -I
10.0.0.88
$ sudo salt-key -A


(Karvinen 2018)
Ensin konfiguroidaan salt-master ja toisiksi viimeisessä komennossa hyväksytään uusi salt-slave. En vielä ymmärrä artikkelin Run salt command locally roolia tehtävässä, mutta parempi jatkaa. Tällä pystyy testaamaan master-slave-yhteyden matser koneelta:
$ sudo salt '*' cmd.run 'whoami'

Nyt aloitan tekemään tehtävää h1 -viisikko. Strategiana on asentaa linux-koneita Dockerin avulla, ja katsoa jos se riittäisi saamaan tehtävät toimimaan. Eli en käytä "kokonaista" virtuaalikonetta. Yritän tehdä tämän Karvisen raportointiohjeiden (2006) mukaan  

### a) 


## Lähteet

Karvinen, Tero 2023. Run Salt Command Locally. Lähde: https://terokarvinen.com/2021/salt-run-command-locally/ (Luettu 28.10.2024)
Karvinen, Tero 2018. Salt Quickstart – Salt Stack Master and Slave on Ubuntu Linux. Lähde: https://terokarvinen.com/2018/03/28/salt-quickstart-salt-stack-master-and-slave-on-ubuntu-linux/ (Luettu 28.10.2024)
Karvinen, Tero 2006. Raportin kirjoittaminen – Salt Stack Master and Slave on Ubuntu Linux. Lähde: https://terokarvinen.com/2006/06/04/raportin-kirjoittaminen-4/ (Luettu 28.10.2024)
