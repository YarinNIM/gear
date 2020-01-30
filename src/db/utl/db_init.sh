#!/bin/bash
echo ""
echo "========================"
echo " Database Initialization"
sudo -u postgres bash << EOF
    psql
    create database bongthom;
    create role btuser password 'user@BTNGlp-_KO)' login;
    grant all on database bongthom to btuser;
EOF
echo "======================="
