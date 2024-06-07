FROM alpine:3.20

# Install required packages
RUN apk update && \
    apk add --no-cache curl gcc make musl-dev readline-dev  zlib-dev \
    perl-dev python3-dev tcl-dev

WORKDIR /home/tutorial

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

EXPOSE 5555
CMD ["tail", "-f", "/dev/null"]
