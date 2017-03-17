FROM debian:jessie-backports

MAINTAINER Kiwivogel

# Add the PostgreSQL PGP key to verify their Debian packages.
# It should be the same key as https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8 && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ wheezy-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && \
    apt-get -y -q install sudo python-software-properties software-properties-common \
                          postgresql-9.5 postgresql-client-9.5 postgresql-contrib-9.5

RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.5/main/pg_hba.conf && \
    echo "listen_addresses='*'" >> /etc/postgresql/9.5/main/postgresql.conf &&

ADD postgresql_bootstrap /opt/postgresql_service
WORKDIR /opt/postgresql_service

# Expose the PostgreSQL port
EXPOSE 5432

# Correct the Error: could not open temporary statistics file "/var/run/postgresql/9.5-main.pg_stat_tmp/global.tmp": No such file or directory
RUN mkdir -p /var/run/postgresql/9.5-main.pg_stat_tmp
RUN chown postgres.postgres /var/run/postgresql/9.5-main.pg_stat_tmp -R

# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

# Set the default command to bootstrap DB when starting the container
CMD ["./postgresql.sh"]
