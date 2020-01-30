-- Parse::SQL::Dia      version 0.30                              
-- Documentation        http://search.cpan.org/dist/Parse-Dia-SQL/
-- Environment          Perl 5.026001, /usr/bin/perl              
-- Architecture         x86_64-linux-gnu-thread-multi             
-- Target Database      postgres                                  
-- Input file           table.dia                                 
-- Generated at         Wed Aug 22 14:12:09 2018                  
-- Typemap for postgres not found in input file                   

-- get_constraints_drop 

-- get_permissions_drop 

-- get_view_drop

-- get_schema_drop
drop table company_sale_channel_member;

-- get_smallpackage_pre_sql 

-- get_schema_create
create table company_sale_channel_member (
   id                      serial                                      not null,
   company_sale_channel_id integer references company_sale_channel(id) not null,
   account_id              integer references account(id)              not null,
   member_title            varchar                                     not null,
   is_leader               boolean default false                       not null,
   constraint pk_company_sale_channel_member primary key (id)
)   ;

-- get_view_create

-- get_permissions_create

-- get_inserts

-- get_smallpackage_post_sql

-- get_associations_create
alter table company_sale_channel_member owner to gear_user;
