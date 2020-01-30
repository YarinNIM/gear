#! /bin/bash

echo "======================"
echo "% Backup from Server %"
echo "======================"

db="/tmp/bt_$(date +'%Y%m%d').sql"
ssh -v dev@192.168.0.122 "pg_dump -h localhost -d bongthom -U btuser" > $db

echo " - Database backup : $db"
sudo -u postgres bash << EOF
    echo "Drop local database"
    dropdb bongthom
    echo "Create fresh bongthom database"
    createdb bongthom
    psql bongthom < $db
EOF
