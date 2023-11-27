FROM ubuntu:latest AS base
    RUN apt update
    RUN apt upgrade -y
FROM base AS python
    RUN apt install python3 python3-pip -y
    RUN pip install ipython
FROM python AS scapy
    RUN apt install libpcap-dev -y
    RUN pip install scapy
FROM scapy AS yara
    RUN apt install libssl-dev -y
    RUN pip install yara-python
FROM yara AS finish
    RUN apt clean
    WORKDIR /home/python-scapy-yara
