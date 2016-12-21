FROM debian:squeeze


#Instalacion de dependencias
ADD files/apt.conf /etc/apt/apt.conf
ADD files/sources.list /etc/apt/sources.list

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
    mysql-client\
    && rm -rf /var/lib/apt/lists/*



RUN git clone -b 0.10.6 https://github.com/Desarrollo-CeSPI/meran.git /usr/local/share/meran/main


# Configuracion del volumen
ENV ID main

ENV DB_NAME ${DB_NAME:-meran}
ENV DB_HOST ${DB_HOST:-mysql}
ENV DB_USER ${DB_USER:-meran}
ENV DB_PASS ${DB_PASS:-meranpass}

ENV MERAN_PATH /usr/local/share/meran
ENV MERAN_CONFIG /etc/meran/meranmain.conf
ENV SPHINX_CONFIG /etc/meran/sphinx.conf
ENV TPL_MAIN_CONFIG $MERAN_PATH/$ID/docs/instalador/meran.conf

ENV PERL5LIB /opt/modules/Share/share/perl/5.10.1/:/opt/modules/Share/lib/perl/5.10.1/:/opt/modules/Share/share/perl/5.10/:/opt/modules/C4/Share/share/perl/5.10.1/:/opt/modules/Share/lib/perl/5.10/:/opt/modules/Share/lib/perl5/

ADD files/sphinx64.tar.gz /opt/
ADD files/jaula64.tar.gz /opt/modules
ADD files/apache-opac /opt/
ADD files/apache-ssl /opt/
ADD files/iniciandomain.pl /etc/meran/
ADD files/sphinx.conf /etc/meran/

VOLUME [ "/meran/config", "/meran/logs", "/meran/files", "/meran/apache", "/meran/ssl", "/usr/local/share/meran/" ]

EXPOSE 80
EXPOSE 443
COPY entrypoint /entrypoint
CMD  ["/entrypoint"]
