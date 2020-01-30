-- Parse::SQL::Dia      version 0.30                              
-- Documentation        http://search.cpan.org/dist/Parse-Dia-SQL/
-- Environment          Perl 5.026001, /usr/bin/perl              
-- Architecture         x86_64-linux-gnu-thread-multi             
-- Target Database      postgres                                  
-- Input file           table.dia                                 
-- Generated at         Wed Jan 30 16:41:56 2019                  
-- Typemap for postgres not found in input file                   

-- get_constraints_drop 

-- get_permissions_drop 

-- get_view_drop

-- get_schema_drop
drop table delivery_order cascade;

-- get_smallpackage_pre_sql 

-- get_schema_create
create table delivery_order (
   id                  serial                                 not null,
   tax                 smallint default 0                     not null,
   contact_number      varchar(15)                            not null,
   agent_id            integer references account(id)                 ,
   is_confirmed        boolean default false                  not null,
   confirmed_date      timestamp                                      ,
   account_id          integer references account(id)         not null,
   delivery_address_id integer references address(id)         not null,
   is_picked           boolean default false                  not null,
   picked_date         timestamp                                      ,
   pickup_address_id   integer references address(id)                 ,
   company_id          integer references company(id)                 ,
   created_date        timestamp default current_timestamp    not null,
   delivery_date       timestamp                                      ,
   is_asap             boolean default true                   not null,
   delivery_charge     decimal(4,2)                           not null,
   description         varchar                                        ,
   payment_method_id   smallint references payment_method(id)         ,
   is_delivered        boolean default false                  not null,
   delivered_date      timestamp                                      ,
   constraint pk_delivery_order primary key (id)
)   ;

-- get_view_create

-- get_permissions_create

-- get_inserts

-- get_smallpackage_post_sql

-- get_associations_create
alter table delivery_order owner to gear_user;
