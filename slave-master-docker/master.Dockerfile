FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y wget gnupg && \
    wget -O - https://repo.saltproject.io/salt/py3/ubuntu/$(lsb_release -rs)/amd64/latest/SALTSTACK-GPG-KEY.pub | apt-key add - && \
    echo "deb https://repo.saltproject.io/salt/py3/ubuntu/$(lsb_release -rs)/amd64/latest $(lsb_release -cs) main" > /etc/apt/sources.list.d/saltstack.list

RUN apt-get update
RUN apt-get --yes install salt-master
RUN salt-key --yes -A

CMD ["/bin/bash" "-c", "service salt-master start"]