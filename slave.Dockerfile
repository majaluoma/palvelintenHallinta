FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y wget gnupg && \
    wget -O - https://repo.saltproject.io/salt/py3/ubuntu/$(lsb_release -rs)/amd64/latest/SALTSTACK-GPG-KEY.pub | apt-key add - && \
    echo "deb https://repo.saltproject.io/salt/py3/ubuntu/$(lsb_release -rs)/amd64/latest $(lsb_release -cs) main" > /etc/apt/sources.list.d/saltstack.list


RUN  apt-get update
RUN  apt-get -y install salt-minion

RUN echo "master: master" >> /etc/salt/minion
RUN echo "id: slave1"  >> /etc/salt/minion

CMD ["salt-minion", "-d"]