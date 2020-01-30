-- Parse::SQL::Dia      version 0.30                              
-- Documentation        http://search.cpan.org/dist/Parse-Dia-SQL/
-- Environment          Perl 5.022001, /usr/bin/perl              
-- Architecture         x86_64-linux-gnu-thread-multi             
-- Target Database      postgres                                  
-- Input file           table.dia                                 
-- Generated at         Thu Apr  5 12:53:57 2018                  
-- Typemap for postgres not found in input file                   

-- get_constraints_drop 

-- get_permissions_drop 

-- get_view_drop

-- get_schema_drop
drop table email;

-- get_smallpackage_pre_sql 

-- get_schema_create
create table email (
   id                serial                              not null,
   email             varchar                                     ,
   verified          boolean default false                       ,
   created_date      timestamp default current_timestamp         ,
   verification_code varchar                                     ,
   verified_date     timestamp                                   ,
   status            boolean default true                        ,
   constraint pk_email primary key (id)
)   ;

-- get_view_create

-- get_permissions_create

-- get_inserts

-- get_smallpackage_post_sql

-- get_associations_create
alter table email owner to gear_user;
