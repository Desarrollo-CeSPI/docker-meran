FROM debian:squeeze


#Instalacion de dependencias
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update && apt-get install -yqq --force-yes apt-utils \
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



# Configuracion del volumen
ENV CONFIG_DIR /etc/meran
ENV ID main

ENV DB_NAME ${DB_NAME:-meran}
ENV DB_HOST ${DB_HOST:-mysql}
ENV DB_USER ${DB_USER:-meran}
ENV DB_PASS ${DB_PASS:-meranpass}

ENV MERAN_PATH /usr/local/share/meran
ENV MAIN_CONFIG $CONFIG_DIR/meran$ID.conf
ENV TPL_MAIN_CONFIG $MERAN_PATH/$ID/docs/instalador/meran.conf
ENV TPL_INIT_SCRIPT $MERAN_PATH/$ID/docs/instalador/iniciando.pl
ENV INIT_SCRIPT $CONFIG_DIR/iniciando$ID.pl
ENV TPL_APACHE_CONF_OPAC $MERAN_PATH/$ID/docs/instalador/debian6/apache-jaula-opac
ENV TPL_APACHE_CONF_SSL $MERAN_PATH/$ID/docs/instalador/debian6/apache-jaula-ssl
ENV APACHE_CONF_OPAC /etc/apache2/sites-enabled/opac.conf
ENV APACHE_CONF_SSL /etc/apache2/sites-enabled/ssl.conf
ENV SPHINX_CONFIG_DIR $MERAN_PATH/$ID/sphinx/etc
ENV SPHINX_BIN $MERAN_PATH/$ID/sphinx/bin
ENV SPHINX_CONFIG $SPHINX_CONFIG_DIR/sphinx.conf
ENV TPL_SPHINX_CONFIG $MERAN_PATH/$ID/docs/instalador/sphinx.conf
ENV MODULOS_JAULA $MERAN_PATH/$ID/intranet/modules/C4
ENV PERL_LIB_JAULA $MODULOS_JAULA/Share/share/perl/5.10.1/:$MODULOS_JAULA/Share/lib/perl/5.10.1/:$MODULOS_JAULA/Share/share/perl/5.10/:$MODULOS_JAULA/C4/Share/share/perl/5.10.1/:$MODULOS_JAULA/Share/lib/perl/5.10/:$MODULOS_JAULA/Share/lib/perl5/

ENV TPL_BASE_DB $MERAN_PATH/$ID/docs/instalador/base.sql
ENV TPL_UPDATES_DB $MERAN_PATH/$ID/docs/instalador/updates.sql
ENV TPL_PERMISOS_DB $MERAN_PATH/$ID/docs/instalador/permisosbdd.sql
ENV PERMISOS_DB /tmp/permisos_meran.sql
ENV BASE_DB /tmp/demo_meran.sql
ENV UPDATES_DB /tmp/updates_meran.sql











RUN git clone -b 0.10.6 https://github.com/Desarrollo-CeSPI/meran.git /usr/local/share/meran/main
RUN tar -xzvf /usr/local/share/meran/main/docs/instalador/debian6/sphinx64.tar.gz -C /usr/local/share/meran/main/ && rm -rf /usr/local/share/meran/main/sphinx/etc/sphinx.conf
RUN tar -xzvf /usr/local/share/meran/main/docs/instalador/debian6/jaula64.tar.gz -C /usr/local/share/meran/main/intranet/modules/C4/
VOLUME [ "/meran/config", "/meran/logs", "/meran/files", "/meran/apache", "/meran/ssl" ]
EXPOSE 80
EXPOSE 443
COPY entrypoint /entrypoint
ENTRYPOINT  ["/entrypoint"]
