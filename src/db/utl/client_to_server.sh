#! /bin/bash

echo "======================"
echo "% Backup from Server %"
echo "======================"

db="/tmp/bt_$(date +'%Y%m%d').sql"

echo "========================"
echo " Backing up database"
sudo -u postgres bash << EOF
    pg_dump -h localhost -d bongthom -U btuser > $db
EOF

echo "======================="
# ssh -v dev@192.168.0.122 "pg_dump -h localhost -d bongthom -U btuser" > $db
psql -h 192.168.0.122 -d databasename -U dbuser < $db
