-- Parse::SQL::Dia      version 0.30                              
-- Documentation        http://search.cpan.org/dist/Parse-Dia-SQL/
-- Environment          Perl 5.026001, /usr/bin/perl              
-- Architecture         x86_64-linux-gnu-thread-multi             
-- Target Database      postgres                                  
-- Input file           table.dia                                 
-- Generated at         Fri Oct 26 11:04:23 2018                  
-- Typemap for postgres not found in input file                   

-- get_constraints_drop 

-- get_permissions_drop 

-- get_view_drop

-- get_schema_drop
drop table service;

-- get_smallpackage_pre_sql 

-- get_schema_create
create table service (
   id          smallserial           not null,
   name        varchar               not null,
   service_key varchar unique        not null,
   description varchar                       ,
   status      boolean default false not null,
   constraint pk_service primary key (id)
)   ;

-- get_view_create

-- get_permissions_create

-- get_inserts

-- get_smallpackage_post_sql

-- get_associations_create
alter table service owner to gear_user;
