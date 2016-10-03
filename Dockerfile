FROM debian:squeeze


#Instalacion de dependencias
ADD apt.conf /etc/apt/apt.conf
ADD sources.list /etc/apt/sources.list 

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update -qq && apt-get install -yqq --force-yes apt-utils \
    git-core \
    apache2 \
    apache2-mpm-prefork \
    libapache2-mod-perl2 \
    libgd2-xpm\
    libxpm4\
    htmldoc\
    libaspell15\
    ntpdate\
    libhttp-oai-perl\
    libxml-sax-writer-perl\
    libxml-libxslt-perl\
    libyaml-perl\
    mysql-client

RUN git clone -b 0.10.6 https://github.com/Desarrollo-CeSPI/meran.git /usr/local/share/meran/main


# Configuracion del volumen
ENV ID main

ENV DB_NAME ${DB_NAME:-meran}
ENV DB_HOST ${DB_HOST:-mysql}
ENV DB_USER ${DB_USER:-meran}
ENV DB_PASS ${DB_PASS:-meranpass}

ENV MERAN_PATH /usr/local/share/meran
ENV MERAN_CONFIG /etc/meran/meranmain.conf

ENV TPL_BASE_DB $MERAN_PATH/$ID/docs/instalador/base.sql
ENV TPL_UPDATES_DB $MERAN_PATH/$ID/docs/instalador/updates.sql
ENV TPL_PERMISOS_DB $MERAN_PATH/$ID/docs/instalador/permisosbdd.sql
ENV PERMISOS_DB /tmp/permisos_meran.sql
ENV BASE_DB /tmp/demo_meran.sql
ENV UPDATES_DB /tmp/updates_meran.sql

ENV PERL5LIB /opt/modules/Share/share/perl/5.10.1/:/opt/modules/Share/lib/perl/5.10.1/:/opt/modules/Share/share/perl/5.10/:/opt/modules/C4/Share/share/perl/5.10.1/:/opt/modules/Share/lib/perl/5.10/:/opt/modules/Share/lib/perl5/

ADD files/sphinx64.tar.gz /opt/
ADD files/jaula64.tar.gz /opt/modules
ADD files/apache-opac /opt/
ADD files/apache-ssl /opt/
ADD files/iniciandomain.pl /etc/meran/
ADD files/meranmain.conf /etc/meran/
ADD files/sphinx.conf /etc/meran/

VOLUME [ "/meran/config", "/meran/logs", "/meran/files", "/meran/apache", "/meran/ssl", "/usr/local/share/meran/" ]

EXPOSE 80
EXPOSE 443
COPY entrypoint /entrypoint
CMD  ["/entrypoint"]
