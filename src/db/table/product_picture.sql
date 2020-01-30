-- Parse::SQL::Dia      version 0.30                              
-- Documentation        http://search.cpan.org/dist/Parse-Dia-SQL/
-- Environment          Perl 5.026001, /usr/bin/perl              
-- Architecture         x86_64-linux-gnu-thread-multi             
-- Target Database      postgres                                  
-- Input file           table.dia                                 
-- Generated at         Sat Dec 15 14:39:54 2018                  
-- Typemap for postgres not found in input file                   

-- get_constraints_drop 

-- get_permissions_drop 

-- get_view_drop

-- get_schema_drop
drop table product_picture cascade;

-- get_smallpackage_pre_sql 

-- get_schema_create
create table product_picture (
   id           serial                              not null,
   product_id   integer references product(id)      not null,
   title        varchar                                     ,
   url          varchar                             not null,
   account_id   integer references account(id)      not null,
   created_date timestamp default current_timestamp not null,
   constraint pk_product_picture primary key (id)
)   ;

-- get_view_create

-- get_permissions_create

-- get_inserts

-- get_smallpackage_post_sql

-- get_associations_create
alter table product_picture owner to gear_user;
