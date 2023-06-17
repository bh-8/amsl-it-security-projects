FROM node:lts-bullseye AS dependencies
    #install additional requirements for edps
    RUN apt update

    RUN apt install libnss3-dev -y
    RUN apt install libatk1.0-0 -y
    RUN apt install libatk-bridge2.0-0 -y
    RUN apt install libcups2 -y
    RUN apt install libdrm-dev -y
    RUN apt install libxcomposite-dev -y
    RUN apt install libxdamage1 -y
    RUN apt install libxrandr-dev -y
    RUN apt install libgbm-dev -y
    RUN apt install libxkbcommon-dev -y
    RUN apt install libasound2 -y
    RUN apt install bsdmainutils -y
    RUN apt install dnsutils -y

    #optional
    RUN apt install libgconf-2-4 -y
    RUN apt install libxshmfence-dev -y

    WORKDIR /home/wec
    RUN useradd -ms /bin/bash wec
    RUN chown -R wec /home/wec

    USER wec

FROM dependencies as testssl
    RUN git clone https://github.com/drwetter/testssl.sh.git

    RUN chmod +x /home/wec/testssl.sh/testssl.sh

FROM testssl AS edps
    RUN git clone https://github.com/EU-EDPS/website-evidence-collector.git

    WORKDIR /home/wec/website-evidence-collector
    RUN npm install
    
    USER root
    RUN echo 'kernel.unprivileged_userns_clone=1' > /etc/sysctl.d/userns.conf
    USER wec

    WORKDIR /home/wec

    ADD browser-session.js /home/wec/website-evidence-collector/collector/browser-session.js

FROM edps AS main
    USER root
    ADD entrypoint.sh /home/wec/website-evidence-collector/entrypoint.sh
    RUN chmod +x /home/wec/website-evidence-collector/entrypoint.sh

    USER wec
    WORKDIR /home/wec/website-evidence-collector

    ENTRYPOINT ["./entrypoint.sh"]
