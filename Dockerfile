FROM alpine:3.20

WORKDIR /home/tutorial

# Add user 'postgres'
RUN set -eux; \
     adduser -D -H postgres; \
     mkdir -p /home/tutorial/pgsql13; \
     chown -R postgres:postgres /home/tutorial/pgsql13

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
RUN make  /home/tutorial/postgresql-13.7 && \
    make  /home/tutorial/postgresql-13.7 install

# set PGDATA
ENV PGDATA /home/tutorial/pgsql13/data
RUN mkdir -p "$PGDATA" && chown -R postgres:postgres "$PGDATA" && chmod 0700 "$PGDATA"
ENV PATH /home/tutorial/pgsql13/bin:$PATH

# Switch to the 'postgres' user to initialize the database
USER postgres
# initdb
RUN initdb -U postgres -k -D /home/tutorial/pgsql13/data

EXPOSE 5555

# Switch back to root to set the CMD
USER root
CMD ["tail", "-f", "/dev/null"]
