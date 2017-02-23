FROM       ubuntu:xenial
MAINTAINER Ryann Micua <rmicua@ssd.org>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y wget

RUN bash -c 'echo "deb http://download.bareos.org/bareos/release/16.2/xUbuntu_16.04/ /" > /etc/apt/sources.list.d/bareos.list'
RUN bash -c 'wget -q http://download.bareos.org/bareos/release/16.2/xUbuntu_16.04/Release.key -O- | apt-key add -'

RUN bash -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" > /etc/apt/sources.list.d/postgres.list'
RUN bash -c 'wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O- | apt-key add -'

RUN apt-get update && apt-get install -y postgresql-client-9.6

RUN bash -c "echo 'bareos-database-common bareos-database-common/dbconfig-install boolean false' | debconf-set-selections"
RUN bash -c "echo 'bareos-database-common bareos-database-common/install-error select ignore' | debconf-set-selections"
RUN bash -c "echo 'bareos-database-common bareos-database-common/database-type select psql' | debconf-set-selections"
RUN bash -c "echo 'bareos-database-common bareos-database-common/missing-db-package-error select ignore' | debconf-set-selections"

RUN bash -c "echo 'postfix postfix/main_mailer_type select No configuration' | debconf-set-selections"

RUN apt-get install -y bareos bareos-database-postgresql

RUN tar cfvz /etc.tgz /etc/bareos/

ADD run.sh /run.sh
ADD include.conf /include.conf
RUN chmod u+x /run.sh

EXPOSE 9101

VOLUME /etc/bareos

ENTRYPOINT ["/run.sh"]
CMD ["/usr/sbin/bareos-dir", "-c", "/etc/bareos/bareos-dir.conf", "-u", "bareos", "-f"]
