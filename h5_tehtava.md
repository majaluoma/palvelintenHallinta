/tmp/openttd-14.1-linux-generic-amd64.tar.xz:
  file.managed:
    - source: https://cdn.openttd.org/openttd-releases/14.1/openttd-14.1-linux-generic-amd64.tar.xz
    - source_hash: sha256=c7648c9aac11daeb7f1bdd7a07346865ae590c07af4a6d02a5ed01fb33eba067
tar -xJf /tmp/openttd-14.1-linux-generic-amd64.tar.xz:
  cmd.run:
    - creates: /tmp/openttd-14.1-linux-generic-amd64
/usr/local/bin/openttd:
  file.symlink:
    - target: /tmp/openttd-14.1-linux-generic-amd64/openttd
    - force: True
libgomp1:
  pkg.installed
openttd -D localhost:3001:
  cmd.run

