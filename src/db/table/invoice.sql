-- Parse::SQL::Dia      version 0.30                              
-- Documentation        http://search.cpan.org/dist/Parse-Dia-SQL/
-- Environment          Perl 5.026001, /usr/bin/perl              
-- Architecture         x86_64-linux-gnu-thread-multi             
-- Target Database      postgres                                  
-- Input file           table.dia                                 
-- Generated at         Wed Nov  7 10:44:38 2018                  
-- Typemap for postgres not found in input file                   

-- get_constraints_drop 

-- get_permissions_drop 

-- get_view_drop

-- get_schema_drop
drop table invoice cascade;

-- get_smallpackage_pre_sql 

-- get_schema_create
create table invoice (
   id                  serial                              not null,
   invoice_no          integer                                     ,
   service_id          integer references service(id)              ,
   invoice_type        varchar                             not null,--  type of invoice( Tax, Com, Normal)
   company_id          integer references company(id)              ,--  Company invoice issued under
   account_id          integer references account(id)      not null,--  Account that issued the invoice
   customer_id         integer references account(id)      not null,--  customer as person to subscribe
   customer_company_id integer references company(id)              ,--  Company which the invoice is billed to
   discount            smallint default 0                  not null,
   description         varchar                                     ,--  say sth about the invoice
   invoice_date        date default current_date           not null,
   created_date        timestamp default current_timestamp not null,
   status              boolean default true                not null,
   constraint pk_invoice primary key (id)
)   ;

-- get_view_create

-- get_permissions_create

-- get_inserts

-- get_smallpackage_post_sql

-- get_associations_create
alter table invoice owner to gear_user;
