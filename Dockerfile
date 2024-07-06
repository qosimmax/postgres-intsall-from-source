FROM alpine:3.20

WORKDIR /home/tutorial

# Add user 'postgres'
RUN set -eux; \
     adduser -D -H postgres; \
     mkdir -p /home/tutorial/pgsql13

# Install required packages
RUN apk update && \
    apk add --no-cache curl gcc make musl-dev readline-dev  zlib-dev \
    perl-dev python3-dev tcl-dev linux-headers libxml2-dev

# Download PostgreSQL source code
RUN curl -SL -o postgresql-13.7.tar.gz https://ftp.postgresql.org/pub/source/v13.7/postgresql-13.7.tar.gz

# Extract the tarball
RUN tar xzf postgresql-13.7.tar.gz

# Configure the PostgreSQL build with additional support for Kerberos, OpenSSL, OpenLDAP, PAM, zlib, Perl, Python, and Tcl
RUN /home/tutorial/postgresql-13.7/configure --prefix=/home/tutorial/pgsql13 \
 --with-pgport=5555
  #  --with-krb5 \
  #  --with-openssl \
  #  --with-ldap \
  #  --with-pam \
  #  --with-zlib \
  #  --with-perl \
  # --with-python \



  #  --with-tcl

# Build and install PostgreSQL
RUN make world /home/tutorial/postgresql-13.7 && \
    make  /home/tutorial/postgresql-13.7 install-world

# Build and install PostgreSQL extensions
RUN set -eux; \
    make world  /home/tutorial/postgresql-13.7/contrib && \
    make  /home/tutorial/postgresql-13.7/contrib install-world

# set PGDATA
ENV PGDATA /home/tutorial/pgsql13/data
RUN mkdir -p "$PGDATA" && chown -R postgres:postgres "$PGDATA" && chmod 0700 "$PGDATA"
ENV PATH /home/tutorial/pgsql13/bin:$PATH

# Change ownership of the PostgreSQL directory to the 'postgres' user
RUN chown -R postgres:postgres /home/tutorial/pgsql13

# Switch to the 'postgres' user to initialize the database
USER postgres

EXPOSE 5555

# Initialize the database
RUN /home/tutorial/pgsql13/bin/initdb -U postgres -D /home/tutorial/pgsql13/data

# Set the entrypoint to initialize and start PostgreSQL
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]


CMD ["tail", "-f", "/dev/null"]
