FROM debian:squeeze
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update && apt-get -y --force-yes upgrade && apt-get install -y --force-yes apt-utils git-core apache2 apache2-mpm-prefork libapache2-mod-perl2 libgd2-xpm libxpm4 htmldoc libaspell15 ntpdate libhttp-oai-perl libxml-sax-writer-perl libxml-libxslt-perl libyaml-perl mysql-client

RUN git clone -b 0.10.6 https://github.com/Desarrollo-CeSPI/meran.git /usr/local/share/meran/main

#Descomprime los binarios de sphinx
RUN tar -xzvf /usr/local/share/meran/main/docs/instalador/debian6/sphinx64.tar.gz -C /usr/local/share/meran/main/ && rm -rf /usr/local/share/meran/main/sphinx/etc/sphinx.conf

#Descomprime modulos precompilados
RUN tar -xzvf /usr/local/share/meran/main/docs/instalador/debian6/jaula64.tar.gz -C /usr/local/share/meran/main/intranet/modules/C4/

VOLUME [ "/meran/config", "/meran/logs", "/meran/files", "/meran/apache", "/meran/ssl" ]
EXPOSE 80
EXPOSE 443
COPY entrypoint /entrypoint
ENTRYPOINT  ["/entrypoint"]
