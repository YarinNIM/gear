-- Parse::SQL::Dia      version 0.30                              
-- Documentation        http://search.cpan.org/dist/Parse-Dia-SQL/
-- Environment          Perl 5.022001, /usr/bin/perl              
-- Architecture         x86_64-linux-gnu-thread-multi             
-- Target Database      postgres                                  
-- Input file           table.dia                                 
-- Generated at         Tue Apr 24 13:12:08 2018                  
-- Typemap for postgres not found in input file                   

-- get_constraints_drop 

-- get_permissions_drop 

-- get_view_drop

-- get_schema_drop
drop table admin_role;

-- get_smallpackage_pre_sql 

-- get_schema_create
create table admin_role (
   id           serial                              not null,
   name         varchar                                     ,
   permissions  jsonb default '{}'                          ,
   status       boolean default true                        ,
   created_by   integer references account(id)              ,
   created_date timestamp default current_timestamp         ,
   constraint pk_admin_role primary key (id)
)   ;

-- get_view_create

-- get_permissions_create

-- get_inserts

-- get_smallpackage_post_sql

-- get_associations_create
alter table admin_role owner to gear_user;
