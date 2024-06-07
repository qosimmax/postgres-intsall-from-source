#!/bin/sh
set -eux

# Start PostgreSQL
/home/tutorial/pgsql13/bin/pg_ctl -D /home/tutorial/pgsql13/data -l /home/tutorial/pgsql13/logfile start

# Keep the container running
exec "$@"
