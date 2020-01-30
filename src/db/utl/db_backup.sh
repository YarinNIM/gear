#!/bin/bash
echo ""
echo "========================"
echo " Database Backup"
db="/tmp/bt_$(date +'%Y%m%d')"
sudo -u postgres bash << EOF
    echo " - Backing up data...."
    pg_dump bongthom > $db
    echo " - Compressing the data file..."
    gzip $db
EOF
echo " - Storing db_backup at "
echo " [/BTNG/bongthom/resource/db/backup/bt_$(date +'%Y%m%d').gz]"
cp "$db.gz" /BTNG/bongthom/resource/db/backup/.
echo "================="
echo ""
