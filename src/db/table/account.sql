-- Parse::SQL::Dia      version 0.30                              
-- Documentation        http://search.cpan.org/dist/Parse-Dia-SQL/
-- Environment          Perl 5.022001, /usr/bin/perl              
-- Architecture         x86_64-linux-gnu-thread-multi             
-- Target Database      postgres                                  
-- Input file           table.dia                                 
-- Generated at         Fri Apr  6 01:06:27 2018                  
-- Typemap for postgres not found in input file                   

-- get_constraints_drop 

-- get_permissions_drop 

-- get_view_drop

-- get_schema_drop
drop table account;

-- get_smallpackage_pre_sql 

-- get_schema_create
create table account (
   id                   serial                              not null,
   user_name            varchar unique                              ,
   email_id             integer references email(id) unique         ,
   password             varchar(160)                                ,
   first_name           varchar(255)                                ,
   last_name            varchar(255)                                ,
   sex                  varchar(1)                                  ,
   birthdate            timestamp                                   ,
   created_date         timestamp default current_timestamp         ,
   verified             boolean default false                       ,--  To check if the account is already verified
   verified_date        timestamp                                   ,
   status               boolean default true                        ,--  once account created, set the status = true, FALSE = deleted
   verification_code    varchar(100)                                ,
   last_access          timestamp                                   ,
   is_super_system_user boolean default null                        ,
   constraint pk_account primary key (id)
)   ;

-- get_view_create

-- get_permissions_create

-- get_inserts

-- get_smallpackage_post_sql

-- get_associations_create
alter table account owner to gear_user;
