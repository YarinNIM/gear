-- Parse::SQL::Dia      version 0.30                              
-- Documentation        http://search.cpan.org/dist/Parse-Dia-SQL/
-- Environment          Perl 5.026001, /usr/bin/perl              
-- Architecture         x86_64-linux-gnu-thread-multi             
-- Target Database      postgres                                  
-- Input file           table.dia                                 
-- Generated at         Sat Jun  9 11:18:42 2018                  
-- Typemap for postgres not found in input file                   

-- get_constraints_drop 

-- get_permissions_drop 

-- get_view_drop

-- get_schema_drop
drop table company;

-- get_smallpackage_pre_sql 

-- get_schema_create
create table company (
   id               serial                               not null,
   name_en          varchar unique                       not null,
   name_kh          varchar unique                               ,
   desc_en          varchar                                      ,
   desc_kh          varchar                                      ,
   company_type_id  integer references company_type(id)  not null,--  priviate/public...
   industry_type_id integer references industry_type(id)         ,--  Industries which this profile involve bissunis in
   account_id       integer references account(id)       not null,--  created by an account
   created_date     timestamp default current_timestamp          ,
   status           boolean default true                         ,
   has_vat          boolean default false                        ,
   vat_no           varchar unique                               ,
   company_logo_id  integer references company_logo(id)          ,--  Id to company logo
   is_verified      boolean default false                        ,
   constraint pk_company primary key (id)
)   ;

-- get_view_create

-- get_permissions_create

-- get_inserts

-- get_smallpackage_post_sql

-- get_associations_create
alter table company owner to gear_user;
