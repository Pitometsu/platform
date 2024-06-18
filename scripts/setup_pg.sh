#!/bin/sh -eu

PGADMIN_="${1:-$PGADMIN}"
PGHOST_="${2:-$PGHOST}"
PGPORT_="${3:-$PGPORT}"
PGDATA_="${4:-$PGDATA}"
LOG_PATH_="${5:-$LOG_PATH}"

PGDATA_EXIST_=`{ test -d "$PGDATA_"; echo $?; } || true`

# postgresql.conf
if [ "$PGDATA_EXIST_" -ne "0" ]
then
  echo "Creating DB..."
  mkdir -p "$LOG_PATH_"
  mkdir -p "$PGDATA_"
  initdb -U "$PGADMIN_"
  cat >> "$PGDATA_"/postgresql.conf <<EOF
unix_socket_directories = '$PGHOST_'
listen_addresses = '*'
log_directory = '$LOG_PATH_'
log_destination = 'stderr'
logging_collector = on
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_min_messages = info
log_min_error_statement = info
log_connections = on
log_statement = 'all'
port = '$PGPORT_'
EOF
  cat >> "$PGDATA_"/pg_hba.conf <<EOF
host    all             all             ::1/128                 trust
EOF
fi

# pg_ctl start
if pg_isready
then
  echo "DB is up"
  pg_ctl status
else
  echo "Starting DB..."
  pg_ctl start > /dev/null 2>&1

  timeout 15 sh -c -- "$(cat <<EOF
until pg_isready > /dev/null 2>&1
do
  sleep 1
done
EOF
)"
  if pg_isready > /dev/null 2>&1
  then
    echo "DB is up"
    pg_ctl status
  else
    echo "DB didn't start"
  fi
fi

# return false if pg data was exist
if [ "$PGDATA_EXIST_" -ne "0" ]
then
  true
else
  false
fi
