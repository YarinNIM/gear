#! /bin/sh
if [ "$1" != "" ]; then
    echo "======================"
    echo "Exporting data into [table/$1.sql] ..."
    echo "======================"
    parsediasql --file table.dia --db postgres > table/$1.sql
    echo "alter table $1 owner to gear_user;" >> table/$1.sql
    vim table/$1.sql
    sudo su postgres -c "psql -d gear_db -f table/$1.sql"
else
    echo "Please provide the table name to export to:"
    echo "dia2psql table_name"
fi
