-- Parse::SQL::Dia      version 0.30                              
-- Documentation        http://search.cpan.org/dist/Parse-Dia-SQL/
-- Environment          Perl 5.026001, /usr/bin/perl              
-- Architecture         x86_64-linux-gnu-thread-multi             
-- Target Database      postgres                                  
-- Input file           table.dia                                 
-- Generated at         Fri Nov 16 00:16:18 2018                  
-- Typemap for postgres not found in input file                   

-- get_constraints_drop 

-- get_permissions_drop 

-- get_view_drop

-- get_schema_drop
drop table cash_receipt cascade;

-- get_smallpackage_pre_sql 

-- get_schema_create
create table cash_receipt (
   id                serial                                 not null,
   invoice_id        integer references invoice(id)         not null,
   ref_no            varchar                                        ,
   amount            decimal(6,4)                           not null,
   description       varchar                                        ,
   received_date     timestamp default current_timestamp    not null,
   received_from     varchar                                        ,
   received_by       varchar                                        ,
   payment_method_id smallint references payment_method(id)         ,
   account_id        integer references account(id)         not null,--  account who perform this action
   created_date      timestamp default current_timestamp    not null,
   status            boolean default true                   not null,
   constraint pk_cash_receipt primary key (id)
)   ;

-- get_view_create

-- get_permissions_create

-- get_inserts

-- get_smallpackage_post_sql

-- get_associations_create
alter table invoice_detail owner to gear_user;
