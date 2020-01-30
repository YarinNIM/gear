-- Parse::SQL::Dia      version 0.30                              
-- Documentation        http://search.cpan.org/dist/Parse-Dia-SQL/
-- Environment          Perl 5.026001, /usr/bin/perl              
-- Architecture         x86_64-linux-gnu-thread-multi             
-- Target Database      postgres                                  
-- Input file           table.dia                                 
-- Generated at         Fri Oct 26 11:43:06 2018                  
-- Typemap for postgres not found in input file                   

-- get_constraints_drop 

-- get_permissions_drop 

-- get_view_drop

-- get_schema_drop
drop table service_product;

-- get_smallpackage_pre_sql 

-- get_schema_create
create table service_product (
   id            serial                          not null,
   company_id    integer references company(id)  not null,
   product_id    integer references product(id)  not null,
   service_id    smallint references service(id) not null,
   selling_price decimal default 0.0             not null,
   status        boolean default true            not null
)   ;

-- get_view_create

-- get_permissions_create

-- get_inserts

-- get_smallpackage_post_sql

-- get_associations_create
alter table service_product owner to gear_user;
