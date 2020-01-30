-- Parse::SQL::Dia      version 0.30                              
-- Documentation        http://search.cpan.org/dist/Parse-Dia-SQL/
-- Environment          Perl 5.026001, /usr/bin/perl              
-- Architecture         x86_64-linux-gnu-thread-multi             
-- Target Database      postgres                                  
-- Input file           table.dia                                 
-- Generated at         Thu Jun 21 15:35:59 2018                  
-- Typemap for postgres not found in input file                   

-- get_constraints_drop 

-- get_permissions_drop 

-- get_view_drop

-- get_schema_drop
drop table company_address;

-- get_smallpackage_pre_sql 

-- get_schema_create
create table company_address (
   id             serial                              not null,
   company_id     integer references company(id)      not null,
   is_main_office boolean default false               not null,
   line_a         varchar                             not null,
   line_b         varchar                                     ,
   location       varchar                                     ,
   account_id     integer references account(id)      not null,
   created_date   timestamp default current_timestamp not null,
   status         boolean default true                not null,
   constraint pk_company_address primary key (id)
)   ;

-- get_view_create

-- get_permissions_create

-- get_inserts

-- get_smallpackage_post_sql

-- get_associations_create
alter table company_address owner to gear_user;
