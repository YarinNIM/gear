#!/bin/bash
echo ""
#echo "============================================="
#echo " Databse Restore"
#echo " Select database file: "
#read db
#dbf="/BTNG/bongthom/resource/db/backup/$db"
#echo " Decompressing data file..."
#gzip -vd $dbf.gz
sudo -u postgres bash << EOF
    echo " Drop BONGTHOM database"
    dropdb bongthom
    echo " Create BONGTHOM database"
    createdb bongthom
    psql bongthom < $1
EOF
echo "============================================="
