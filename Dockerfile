FROM debian:squeeze
RUN apt-get -y update && apt-get -y install git-core
RUN git clone -b 0.10.6 https://github.com/Desarrollo-CeSPI/meran.git /opt/meran

RUN apt-get update -y && apt-get -y install apache2 apache2-mpm-prefork libapache2-mod-perl2 libgd2-xpm libxpm4 htmldoc libaspell15 ntpdate libhttp-oai-perl libxml-sax-writer-perl libxml-libxslt-perl libyaml-perl mysql-client

VOLUME [ "/meran/config", "/meran/logs", "/meran/files", "/meran/apache" ]
EXPOSE 80
EXPOSE 443
copy entrypoint /entrypoint
RUN mv /opt/meran /usr/local/share
ENTRYPOINT  ["/entrypoint"]
