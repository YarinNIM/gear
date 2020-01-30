#! /usr/bin/expect
spawn ssh -v dev@192.168.0.122 "pg_dump -h localhost -d bongthom -U btuser" > $db
    expect
