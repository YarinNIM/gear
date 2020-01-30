-- Parse::SQL::Dia      version 0.30                              
-- Documentation        http://search.cpan.org/dist/Parse-Dia-SQL/
-- Environment          Perl 5.026001, /usr/bin/perl              
-- Architecture         x86_64-linux-gnu-thread-multi             
-- Target Database      postgres                                  
-- Input file           table.dia                                 
-- Generated at         Fri Sep 28 10:09:15 2018                  
-- Typemap for postgres not found in input file                   

-- get_constraints_drop 

-- get_permissions_drop 

-- get_view_drop

-- get_schema_drop
drop table vehicle_model;

-- get_smallpackage_pre_sql 

-- get_schema_create
create table vehicle_model (
   id              serial                               not null,
   brand_id        integer references product_brand(id) not null,
   vehicle_type_id smallint references vehicle_type(id) not null,
   model_number    varchar                              not null,
   model_name      varchar                              not null,
   status          boolean default true                 not null,
   account_id      integer references account(id)       not null,
   created_date    timestamp default current_timestamp  not null,
   constraint pk_vehicle_model primary key (id)
)   ;

-- get_view_create

-- get_permissions_create

-- get_inserts

-- get_smallpackage_post_sql

-- get_associations_create
alter table vehicle_model owner to gear_user;
