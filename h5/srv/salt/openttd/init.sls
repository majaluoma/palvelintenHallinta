unzip:
  pkg.installed
libgomp1:
  pkg.installed
ufw:
  pkg.installed
sudo ufw allow in from 192.168.0.0/24 proto tcp to any port 22:
  cmd.run:
    - unless: sudo ufw status verbose | grep 22
sudo ufw allow in from 192.168.0.0/24 proto udp to any port 3979:
  cmd.run:
    - unless: sudo ufw status verbose | grep 3979/udp
sudo ufw allow in from 192.168.0.0/24 proto tcp to any port 3979:
  cmd.run:
    - unless: sudo ufw status verbose | grep 3979/tcp
sudo ufw allow in from 192.168.0.0/24 proto udp to any port 3978:
  cmd.run:
    - unless: sudo ufw status verbose | grep 3978/udp
sudo ufw allow in from 192.168.0.0/24 proto tcp to any port 4505:
  cmd.run:
    - unless: sudo ufw status verbose | grep 4505/tcp
sudo ufw allow in from 192.168.0.0/24 proto tcp to any port 4506:
  cmd.run:
    - unless: sudo ufw status verbose | grep 4506/tcp
ufw.service:
  service.running:
    - enable: True
ufw enable:
  cmd.run:
    - unless: sudo ufw status | grep active
    - require:
      - service: ufw.service
/tmp/openttd-14.1-linux-generic-amd64.tar.xz:
  file.managed:
    - source: salt://openttd/openttd-14.1-linux-generic-amd64.tar.xz
tar -xJf /tmp/openttd-14.1-linux-generic-amd64.tar.xz -C /home/vagrant:
  cmd.run:
    - creates: /home/vagrant/openttd-14.1-linux-generic-amd64
/tmp/opengfx-7.1-all.zip:
  file.managed:
    - source: salt://openttd/opengfx-7.1-all.zip
unzip -q /tmp/opengfx-7.1-all.zip -d /home/vagrant/openttd-14.1-linux-generic-amd64/baseset:
  cmd.run:
    - creates: /home/vagrant/openttd-14.1-linux-generic-amd64/baseset/opengfx-7.1.tar
/home/vagrant/.config/openttd/openttd.cfg:
  file.managed:
    - source: salt://openttd/openttd.cfg
    - makedirs: True
/home/vagrant/openttd-14.1-linux-generic-amd64/openttd -c /home/vagrant/.config/openttd/openttd.cfg -x -f -D 192.168.56.89:3979:
  cmd.run:
    - unless: pgrep openttd