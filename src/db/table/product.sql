-- Parse::SQL::Dia      version 0.30                              
-- Documentation        http://search.cpan.org/dist/Parse-Dia-SQL/
-- Environment          Perl 5.026001, /usr/bin/perl              
-- Architecture         x86_64-linux-gnu-thread-multi             
-- Target Database      postgres                                  
-- Input file           table.dia                                 
-- Generated at         Wed Sep 12 14:09:14 2018                  
-- Typemap for postgres not found in input file                   

-- get_constraints_drop 

-- get_permissions_drop 

-- get_view_drop

-- get_schema_drop
drop table product;

-- get_smallpackage_pre_sql 

-- get_schema_create
create table product (
   id             serial                                  not null,
   title          varchar                                 not null,
   description    varchar                                 not null,
   cost           decimal default 0                       not null,
   selling_price  decimal default 0                       not null,
   old_price      decimal default 0                       not null,
   sold_out       boolean default false                   not null,
   show_in_store  boolean default true                    not null,
   min_order      smallint default 1                      not null,
   status         boolean default true                    not null,
   category_id    integer references product_category(id) not null,
   brand_id       smallint references product_brand(id)           ,
   model_id       integer references product_model(id)            ,
   model_name     varchar                                         ,
   barcode        varchar                                         ,
   account_id     integer references account(id)          not null,
   company_id     integer references company(id)                  ,
   created_date   timestamp default current_timestamp     not null,
   published_date timestamp                                       ,
   pictures       integer[] default '{}'                  not null,
   picture_id     integer references product_picture(id)          ,
   constraint pk_product primary key (id)
)   ;

-- get_view_create

-- get_permissions_create

-- get_inserts

-- get_smallpackage_post_sql

-- get_associations_create
alter table product owner to gear_user;
