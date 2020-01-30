-- Parse::SQL::Dia      version 0.30                              
-- Documentation        http://search.cpan.org/dist/Parse-Dia-SQL/
-- Environment          Perl 5.026001, /usr/bin/perl              
-- Architecture         x86_64-linux-gnu-thread-multi             
-- Target Database      postgres                                  
-- Input file           table.dia                                 
-- Generated at         Wed Aug 22 14:10:43 2018                  
-- Typemap for postgres not found in input file                   

-- get_constraints_drop 

-- get_permissions_drop 

-- get_view_drop

-- get_schema_drop
drop table company_sale_channel;

-- get_smallpackage_pre_sql 

-- get_schema_create
create table company_sale_channel (
   id           serial                              not null,
   company_id   integer references company(id)      not null,
   name         varchar                             not null,
   status       boolean default true                not null,
   created_date timestamp default current_timestamp not null,
   description  varchar                             not null,
   constraint pk_company_sale_channel primary key (id)
)   ;

-- get_view_create

-- get_permissions_create

-- get_inserts

-- get_smallpackage_post_sql

-- get_associations_create
alter table company_sale_channel owner to gear_user;
