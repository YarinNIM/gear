-- Parse::SQL::Dia      version 0.30                              
-- Documentation        http://search.cpan.org/dist/Parse-Dia-SQL/
-- Environment          Perl 5.022001, /usr/bin/perl              
-- Architecture         x86_64-linux-gnu-thread-multi             
-- Target Database      postgres                                  
-- Input file           table.dia                                 
-- Generated at         Thu Apr 19 11:08:04 2018                  
-- Typemap for postgres not found in input file                   

-- get_constraints_drop 

-- get_permissions_drop 

-- get_view_drop

-- get_schema_drop
drop table system_role cascade;

-- get_smallpackage_pre_sql 

-- get_schema_create
create table system_role (
   id          serial               not null,
   name        varchar                      ,
   permissions jsonb default '{}'           ,
   status      boolean default true         ,
   constraint pk_system_role primary key (id)
)   ;

-- get_view_create

-- get_permissions_create

-- get_inserts

-- get_smallpackage_post_sql

-- get_associations_create
alter table system_role owner to gear_user;
