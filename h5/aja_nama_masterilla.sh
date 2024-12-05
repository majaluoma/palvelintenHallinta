sudo salt-key -A -y
sudo salt '*' test.ping 
sudo mkdir -p /srv/salt/openttd
cd /srv/salt/openttd/
sudo curl -O https://cdn.openttd.org/opengfx-releases/7.1/opengfx-7.1-all.zip
sha256sum ./opengfx-7.1-all.zip 
sudo curl -O https://cdn.openttd.org/openttd-releases/14.1/openttd-14.1-linux-generic-amd64.tar.xz
sha256sum ./openttd-14.1-linux-generic-amd64.tar.xz
sudoedit init.sls
sudoedit openttd.cfg
sudo salt '*' state.apply openttd

#grafiikkojen checksum:
#928fcf34efd0719a3560cbab6821d71ce686b6315e8825360fba87a7a94d7846

#peli:
#c7648c9aac11daeb7f1bdd7a07346865ae590c07af4a6d02a5ed01fb33eba067