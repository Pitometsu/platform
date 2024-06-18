#!/bin/sh -eu

PGADMIN_="${1:-$PGADMIN}"
PGUSER_="${2:-$PGUSER}"
PGDATABASE_="${3:-$PGDATABASE}"

# createuser
if [ "1" = \
     "`psql postgres \"$PGADMIN_\" -tAc "SELECT 1 FROM pg_roles \
WHERE rolname='$PGUSER_'" 2> /dev/null`" ]
then
  echo "DB role exist."
else
  if createuser -U "$PGADMIN_" -sd --no-password "$PGUSER_"
  then
    echo "Created DB role $PGUSER_"
  else
    echo "No DB role created"
  fi
fi

# createdb
if [ "1" = \
     "`psql postgres -tAc "SELECT 1 FROM pg_database \
WHERE datname='$PGDATABASE_'" 2> /dev/null`" ]
then
  echo "DB exist."
else
  if createdb "$PGDATABASE_"
  then
    echo "Created DB $PGDATABASE_"
  else
    echo "No DB created"
  fi
fi
