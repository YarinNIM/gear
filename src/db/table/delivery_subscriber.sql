-- Parse::SQL::Dia      version 0.30                              
-- Documentation        http://search.cpan.org/dist/Parse-Dia-SQL/
-- Environment          Perl 5.026001, /usr/bin/perl              
-- Architecture         x86_64-linux-gnu-thread-multi             
-- Target Database      postgres                                  
-- Input file           table.dia                                 
-- Generated at         Wed Jan 23 16:12:56 2019                  
-- Typemap for postgres not found in input file                   

-- get_constraints_drop 

-- get_permissions_drop 

-- get_view_drop

-- get_schema_drop
drop table delivery_subscriber;

-- get_smallpackage_pre_sql 

-- get_schema_create
create table delivery_subscriber (
   id           serial                                not null,
   company_id   integer references company(id) unique not null,
   description  varchar                               not null,
   created_by   integer references account(id)        not null,
   created_date timestamp default current_timestamp   not null,
   status       boolean default true                  not null,
   constraint pk_delivery_subscriber primary key (id)
)   ;

-- get_view_create

-- get_permissions_create

-- get_inserts

-- get_smallpackage_post_sql

-- get_associations_create
alter table delivery_subscriber owner to gear_user;
