#! /bin/sh
sudo su postgres -c "psql -d bongthom -f ../table/$1.sql"
