-- Parse::SQL::Dia      version 0.30                              
-- Documentation        http://search.cpan.org/dist/Parse-Dia-SQL/
-- Environment          Perl 5.026001, /usr/bin/perl              
-- Architecture         x86_64-linux-gnu-thread-multi             
-- Target Database      postgres                                  
-- Input file           table.dia                                 
-- Generated at         Mon Aug 20 20:35:21 2018                  
-- Typemap for postgres not found in input file                   

-- get_constraints_drop 

-- get_permissions_drop 

-- get_view_drop

-- get_schema_drop
drop table product_specification;

-- get_smallpackage_pre_sql 

-- get_schema_create
create table product_specification (
   id          serial                         not null,
   name_en     varchar unique                 not null,
   name_kh     varchar                                ,
   description varchar                        not null,
   account_id  integer references account(id) not null,
   status      boolean default true           not null,
   constraint pk_product_specification primary key (id)
)   ;

-- get_view_create

-- get_permissions_create

-- get_inserts

-- get_smallpackage_post_sql

-- get_associations_create
alter table product_specification owner to gear_user;
