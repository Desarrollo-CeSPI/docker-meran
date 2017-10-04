# Imagen docker de Meran 

Simplifica la instalación del sistema
[Meran](git@github.com:Desarrollo-CeSPI/docker-meran.git).

## Instalar docker

En Ubuntu ejecutar:

```
curl -sSL https://get.docker.com/ | sh
```

Para otros sistemas operativos verificar la [Guía de instalación de
Docker](https://docs.docker.com/installation/).

# Guía de inicio rápido

Si no quiere leer todo este README y simplemente desea probar Meran rápidamente:

## Iniciar un contenedor con MySQL:

```
docker run --name=mysql-meran -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=meran -e MYSQL_USER=meran \
  -e MYSQL_PASSWORD=meranpass -d mysql:5.5
```

## Iniciar un contenedor con Meran ligado al MySQL creado

```
docker run -e DB_NAME=meran -e DB_USER=meran \
  -e DB_PASS=meranpass -e DB_HOST=mysql -v /tmp/meran/config:/meran/config  \
  -v /tmp/meran/logs:/meran/logs -v /tmp/meran/files:/meran/files  \
  -v /tmp/meran/apache:/meran/apache  -v /tmp/meran/ssl:/meran/ssl  \
   --name=meran --link mysql-meran:mysql -p 8000:80 -p 4443:443 -it cespi/meran
```

## Acceder al sistema

El OPAC estará disponible ingresando a la URL: http://localhost:8000 y la Intranet ingresando a la URL: https://localhost:4443. El usuario por defecto es *meranadmin* y su contraseña de acceso *meranadmin123*).

# Guía detallada

A continuación se explica en detalle lo que se mostró anteriormente. Si se tiene
corriendo un contenedor llamado *meran* el siguiente comando dará error
porque ya se creó una instancia con ese nombre. Deberá pararla y eliminarla
antes de seguir adelante.

Para iniciar un contenedor con Meran se utiliza el comando:

```
docker run \
    -e DB_NAME=meran \
    -e DB_USER=meran \
    -e DB_PASS=meranpass \
    -v /tmp/meran/config:/meran/config \
    -v /tmp/meran/logs:/meran/logs \
    -v /tmp/meran/files:/meran/files \
    -v /tmp/meran/apache:/meran/apache \
    -v /tmp/meran/ssl:/meran/ssl \
    --name=meran \
    -p 8000:80 \
    -p 4443:443 \
    -it \
    cespi/meran
```
 "/meran/config", "/meran/logs", "/meran/files", "/meran/apache", "/meran/ssl"
Esto creará el contenedor que instala la última versión de Meran. Las opciones
del comando anterior especifican:

* *DB_XXX:* datos de conexión a la base de datos. La primera vez que se ejecuta
  el comando, configura la DB con estos datos.
* *Mapeo de volúmenes:* los datos del contenedor se manejan en cinco volúmenes
  Docker:
  * `/meran/config`: mantiene los archivos de configuración de Meran.
  * `/meran/logs`: mantiene los logs generados por Meran.
  * `/meran/files`: mantiene los archivos generados por Meran: uploads de archivos, tapas de registros, portadas de OPAC, logos de la biblioteca, etc.
  * `/meran/apache`: contienen los archivos de configuración de Apache para Meran.
  * `/meran/ssl`: contienen el certificado utilizado por Apache para la Intranet de Meran.

* *Nombre del contenedor:* el contenedor en este caso se llamará meran y nos
  permitirá referenciarlo fácilmente en otros comandos Docker.
* *Mapeo de puertos:* el contenedor escuchará en los puertos 8000 y 4443, mapeando estos al 80 y 443 del contenedor respectivamente. Esto significa que Meran quedará accesible
  directamente en los puertos 8000 y 4443 de la máquina donde se corre Docker.
* *Correr en modo interactivo o detached:* las opciones `-it` corren el contenedor en modo
  interactivo y permiten así cancelar la ejecución del contenedor con utilizando
  `Ctrl+C`. Si se desea evitar este modo, omitir las opciones `-it` y utilizar
  `-d`

Una vez completado el comando anterior, quedará funcionando Meran en los
puertos 8000 y 4443.


## Usar MySQL en un contenedor

Podemos correr MySQL en un contenedor de la siguiente forma:

```
docker run \
  --name=mysql-meran \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=meran \
  -e MYSQL_USER=meran \
  -e MYSQL_PASSWORD=meranpass \
  -d mysql:5.5 
```

Una vez corriendo, debemos iniciar nuestra instancia de Meran de esta forma:

```
docker run \
    -e DB_NAME=meran \
    -e DB_USER=meran \
    -e DB_PASS=meranpass \
    -e DB_HOST=mysql \
    -v /tmp/meran/config:/meran/config \
    -v /tmp/meran/logs:/meran/logs \
    -v /tmp/meran/files:/meran/files \
    -v /tmp/meran/apache:/meran/apache \
    -v /tmp/meran/ssl:/meran/ssl \
    --name=meran \
    --link mysql-meran:mysql \
    -p 8000:80 \
    -p 4443:443 \
    -it \
    cespi/meran
```

*Si ya existía un contenedor Docker con el nombre meran, deberá antes
pararlo y eliminarlo: `docker stop meran && docker rm meran`*

## Iniciar y parar el contenedor

Una vez creado el contenedor como se explica en el punto anterior, se está
creando un contenedor *llamado meran*. Este nombre podemos usarlo para:

* *Parar el contenedor:* `docker stop meran`.
* *Iniciar el contenedor:* `docker start meran`.
* *Ver los logs:* `docker logs -f meran`.

## Conexión a la base de datos

Dado que el contenedor corre en un segmento de red diferente, la base de datos
deberá admitir conexiones desde la red. Es por ello que si existen problemas de
conexión a la base de datos, deberá verificar que la configuración sea la adecuada:

* Que los datos de nombre de base de datos, host, usuario y contraseña sean los
  esperados.
  * Los archivos de configuración pueden verse en el volumen montado por Docker
    bajo `/meran/config`.
* Que se disponga de permisos para conectarse desde la red de Docker.
  * Si el problema es de permisos accediendo desde otro host, verificar que:
    * El servidor de MySQL esté escuchando en una IP válida (no en 127.0.0.1).
    * Que el usuario tenga permisos de acceso:

```
GRANT ALL PRIVILEGES ON meran.* to meran@'%' identidied by 'meranpass';`
```

## Los volúmenes

El contenedor de Meran provee cinco volúmenes:

* `/meran/config/`: configuración de meran. Aquí se mantienen:
    * `/meran/config/meranmain.conf`: configuración de Meran.
    * `/meran/config/iniciandomain.pl`: script que inicia el indexador Sphinx.
    * `/meran/config/sphinx.conf`: configuración de Sphinx.
* `/meran/logs/`: logs de Meran y archivos generados por el indexador Sphinx. Aquí se mantienen por defecto:
  * `/meran/logs/main/meran-error.log`: errores generados en la Intranet.
  * `/meran/logs/main/meran-access.log`: logs de acceso de la Intranet.
  * `/meran/logs/main/opac-error.log`: errores generados en el OPAC.
  * `/meran/logs/main/opac-access.log`: logs de acceso del OPAC.
  * `/meran/logs/main/debug_file.txt`: (si se habilita su uso en la configuración) datos de debug generados por Meran, usualmente deshabilitado por ser muy detallado.
  * `/meran/logs/main/index-rooted-meran.*`: archivos del índice de registros de Sphinx para Meran.
  * `/meran/logs/main/sugerencia-index.*`: archivos del índice de sugerencias de Sphinx para Meran (Utilizado para armar el famoso: Usted quiso decir ...).
* `/meran/files/`: mantiene los archivos generados por Meran. Aquí se mantienen:
  * `/meran/files/intranet/`: archivos generados y utilizados por la intranet, desde los documentos electrónicos asociados a registros hasta las portadas descargadas o las subidas por un usuario del sistema.
  * `/meran/files/opac/`: archivos utilizados por el OPAC, desde las imágenes de portada del sitio hasta los documentos electrónicos asociados a novedades del sistema.
* `/meran/apache/`: configuración de Apache para Meran. Aquí se mantienen por defecto:
  * `/meran/apache/ssl.conf`: configuración del virtualhost de la Intranet.
  * `/meran/apache/opac.conf`: configuración del virtualhost del OPAC.
* `/meran/ssl/`: certificado utilizado por la Intranet. Por defecto se encuentra en */meran/ssl/main/apache.pem*.

Un volumen en docker, permite persistir los datos del contenedor. Para más
información ver [la sección de Volúmenes del
manual](https://docs.docker.com/userguide/dockervolumes/).

## Interacción con el contenedor

### Acceder a un shell en el contenedor

Si se desea acceder al contenedor utilizando un shell bash como root por ejemplo:

```
docker run \
    -v /tmp/meran/config:/meran/config \
    -v /tmp/meran/logs:/meran/logs \
    -v /tmp/meran/files:/meran/files \
    -v /tmp/meran/apache:/meran/apache \
    -v /tmp/meran/ssl:/meran/ssl \
    -it \
    --rm \
    --entrypoint=bash \
    cespi/meran
```

### Tareas periódicas de Meran

Este contenedor permite correr tareas necesarias por Meran dentro de un contenedor corriendo de la siguiente forma:

```
docker exec -d CONTENEDOR  #comando# 
```
#### Actualizar índice Sphinx

Por ejemplo, para actualizar los índices de Meran de un contenedor llamado *meran* se utiliza:

```
docker exec -d meran  /cron/reindexar
```
Se recomienda realizar esta tarea lo más seguido posible para evitar búsquedas erróneas. 

#### Regenerar el índice completo 

Se utiliza:

```
docker exec -d meran  /cron/generar_indice
```

#### Descargar portadas de registros

Para descargar las portadas de los libros (utilizando su ISBN) se utiliza:

```
docker exec -d meran  /cron/portadas
```

#### Enviar recordatorios de vencimiento

Para enviar recordatorios de vencimiento de préstamos por mail a los usuarios se utiliza:

```
docker exec -d meran  /cron/mail_recordatorio_prestamos
```

#### Enviar aviso de préstamos vencidos

Para enviar aviso de préstamos vencidos por mail a los usuarios se utiliza:

```
docker exec -d meran  /cron/mail_prestamos_vencidos
```

#### Correr tareas automaticamente usando systemd timers

Dentro de la carpeta files/systemd-timers se encuentran todos los archivos para correr estas tareas automaticamente. Para esto es necesario copuar estos archivos a /etc/systemd/system/ y luego activar los timers con el siguiente comando:

```
systemctl enable {generar_indice,mail_recordatorio,mail_vencidos,portadas,reindexar}@<NOMBRE DEL CONTENEDOR>.timer
systemctl start {generar_indice,mail_recordatorio,mail_vencidos,portadas,reindexar}@<NOMBRE DEL CONTENEDOR>.timer
```

Para verificar que este funcionando se puede correr el siguiente comando:

```
systemctl list-timers
```

## Opciones al correr el contenedor

El contenedor mínimamente deberá definir el puerto en el que ejecutará el
servicio.

### Definir el puerto

Se exponen los puertos 80 y 443. La forma de asociar estos puertos con puertos
de la máquina local es con la opción `-p PTO_LOCAL:PTO_DESTINO`, por ejemplo `-d
8000:80` indica que al acceder al puerto 8000 de la PC donde se corre el
contenedor redireccionará al puerto 80 del contenedor, donde se encuentra
ejecutando Meran.

### Definir los volúmenes

Pueden utilizarse volúmenes que maneja Docker o directorios de la PC donde se
ejecuta Docker. Si se utiliza la opción:

```
    -v `pwd`/code:/code -v `pwd`/data:/data
```

Estamos asociando los directorios `/code` y `/data` del contenedor con dos
directorios de la PC local ubicados en el directorio actual (por ello pwd) con
los mismos nombres respectivamente.

### Datos de conexión a la base de datos

Pueden definirse los siguientes valores: DB_NAME, DB_HOST, DB_USER, DB_PASS

Las variables de entorno mencionadas se pasan al contenedor de la siguiente
forma:

```
    -e DB_NAME=meran_prueba
```

*Es importante destacar que una vez creados los archivos `config/databases.yml`
y `config/propel.ini` estas variables serán ignoradas. Si se desea volver a
crear estos archivos deberá eliminarlos y ejecutar nuevamente el contenedor*.

## Actualizando el contenedor

Para obtener la última versión de esta imagen ejecutar: 

```
docker pull cespi/meran
```
