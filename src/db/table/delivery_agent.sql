-- Parse::SQL::Dia      version 0.30                              
-- Documentation        http://search.cpan.org/dist/Parse-Dia-SQL/
-- Environment          Perl 5.026001, /usr/bin/perl              
-- Architecture         x86_64-linux-gnu-thread-multi             
-- Target Database      postgres                                  
-- Input file           table.dia                                 
-- Generated at         Mon Jan 21 14:03:31 2019                  
-- Typemap for postgres not found in input file                   

-- get_constraints_drop 

-- get_permissions_drop 

-- get_view_drop

-- get_schema_drop
drop table delivery_agent;

-- get_smallpackage_pre_sql 

-- get_schema_create
create table delivery_agent (
   id           serial                                not null,
   account_id   integer references account(id) unique not null,
   is_agent     boolean default true                  not null,--  True is freelance, false is our staff
   created_date timestamp default current_timestamp   not null,
   created_by   integer references account(id)        not null,
   status       boolean default true                  not null,
   description  varchar                               not null,
   constraint pk_delivery_agent primary key (id)
)   ;

-- get_view_create

-- get_permissions_create

-- get_inserts

-- get_smallpackage_post_sql

-- get_associations_create
alter table delivery_agent owner to gear_user;
