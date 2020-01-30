-- Parse::SQL::Dia      version 0.30                              
-- Documentation        http://search.cpan.org/dist/Parse-Dia-SQL/
-- Environment          Perl 5.026001, /usr/bin/perl              
-- Architecture         x86_64-linux-gnu-thread-multi             
-- Target Database      postgres                                  
-- Input file           table.dia                                 
-- Generated at         Wed Aug 29 16:14:33 2018                  
-- Typemap for postgres not found in input file                   

-- get_constraints_drop 

-- get_permissions_drop 

-- get_view_drop

-- get_schema_drop
drop table product_model;

-- get_smallpackage_pre_sql 

-- get_schema_create
create table product_model (
   id          serial                                  not null,
   name        varchar                                 not null,
   category_id integer references product_category(id) not null,
   brand_id    integer references product_brand(id)    not null,
   status      boolean default true                    not null,
   constraint pk_product_model primary key (id)
)   ;

-- get_view_create

-- get_permissions_create

-- get_inserts

-- get_smallpackage_post_sql

-- get_associations_create
alter table product_mdodel owner to gear_user;
