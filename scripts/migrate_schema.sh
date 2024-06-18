#!/bin/sh -eu

PGADMIN_="${1:-$PGADMIN}"

echo "Starting migrations..."

if psql postgres "$PGADMIN_" -v ON_ERROR_STOP=on -f schema.sql
then
  echo "Migrations finished"
else
  echo "Migrations failed"
fi

echo "Populating data..."

if psql postgres "$PGADMIN_" -v ON_ERROR_STOP=on -f data.sql
then
  echo "Data populated"
else
  echo "Population failed"
fi
