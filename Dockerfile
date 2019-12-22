FROM ubuntu:20.04
ENV DEBIAN_FRONTEND noninteractive
RUN apt update && \
    apt upgrade -y && \
    apt full-upgrade -y && \
    apt auto-remove -y && \
    apt auto-clean && \
    apt clean
RUN apt update && \
    apt install -y openjdk-14-jdk ssh git figlet jq && \
    apt clean

WORKDIR /opt/
RUN git clone https://github.com/hktr92/mcpanel.git
WORKDIR /mcpanel

RUN chmod +x /bin/mcpanel

EXPOSE 25565 22
VOLUME ["/mcpanel/"]

#CMD /bin/mcpanel enable-module build
#CMD /bin/mcpanel enable-module server
#CMD /bin/mcpanel build new
#CMD /bin/mcpanel server start
