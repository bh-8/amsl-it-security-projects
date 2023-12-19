FROM ubuntu:latest AS base
    RUN apt update
    RUN apt upgrade -y
FROM base AS python
    RUN apt install python3 python3-pip git -y
    RUN pip install ipython
FROM python AS scapy
    RUN apt install libpcap-dev -y
    RUN pip install scapy
FROM scapy AS yara
    #RUN apt install libssl-dev -y
    #RUN pip install yara-python
    #RUN pip install bitarray
    RUN git clone --recursive https://github.com/VirusTotal/yara-python
    COPY ./modules_patch/numeric /yara-python/yara/libyara/modules/numeric
    RUN echo "MODULE(numeric)" >> /yara-python/yara/libyara/modules/module_list
    COPY ./modules_patch/Makefile.am /yara-python/yara/Makefile.am

    RUN cd /yara-python && python3 setup.py build
    RUN cd /yara-python && python3 setup.py install
FROM yara AS finish
    RUN apt clean
    WORKDIR /home/python-scapy-yara
    COPY ./app/ .
    ENTRYPOINT [ "python3", "-u", "./prototype.py" ]
