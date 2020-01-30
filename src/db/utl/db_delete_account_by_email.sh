#!/bin/bash
echo ""
echo "========================"
echo " Database Initialization"
psql -Ubtuser -h localhost bongthom << EOF
    delete from account where email_id = $1;
    delete from email where id = $1;
EOF
echo "======================="
