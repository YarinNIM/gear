-- Parse::SQL::Dia      version 0.30                              
-- Documentation        http://search.cpan.org/dist/Parse-Dia-SQL/
-- Environment          Perl 5.026001, /usr/bin/perl              
-- Architecture         x86_64-linux-gnu-thread-multi             
-- Target Database      postgres                                  
-- Input file           table.dia                                 
-- Generated at         Thu Jan 17 16:32:18 2019                  
-- Typemap for postgres not found in input file                   

-- get_constraints_drop 

-- get_permissions_drop 

-- get_view_drop

-- get_schema_drop
drop table delivery_company_subscription;

-- get_smallpackage_pre_sql 

-- get_schema_create
create table delivery_company_subscription (
   id            serial                              not null,
   by_account_id integer references account(id)      not null,
   is_subscribed boolean default true                not null,
   company_id    integer references company(id)      not null,
   description   varchar                             not null,--  reason
   created_date  timestamp default current_timestamp not null,
   constraint pk_delivery_company_subscription primary key (id)
)   ;

-- get_view_create

-- get_permissions_create

-- get_inserts

-- get_smallpackage_post_sql

-- get_associations_create
alter table delivery_company_subscription owner to gear_user;
