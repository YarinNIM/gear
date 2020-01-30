#! /bin/sh
Fn="`date +%Y%m%d`.sql"
Bf="/tmp/$Fn"
echo "=============="
echo "| Backing Up |"
echo "=============="
echo " - Backup data to $Bf..."
sudo su postgres -c "pg_dump gear_db > $Bf"
echo " - Compressing..."
Tf=$Bf.tar.gz
tar -zcf $Tf $Bf
sudo rm -rf $Bf
echo " - Storing in to backup folder..."
mv $Tf backup/$Fn.tar.gz
