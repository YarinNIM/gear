-- Parse::SQL::Dia      version 0.30                              
-- Documentation        http://search.cpan.org/dist/Parse-Dia-SQL/
-- Environment          Perl 5.026001, /usr/bin/perl              
-- Architecture         x86_64-linux-gnu-thread-multi             
-- Target Database      postgres                                  
-- Input file           table.dia                                 
-- Generated at         Mon Jul  9 14:43:00 2018                  
-- Typemap for postgres not found in input file                   

-- get_constraints_drop 

-- get_permissions_drop 

-- get_view_drop

-- get_schema_drop
drop table phone;

-- get_smallpackage_pre_sql 

-- get_schema_create
create table phone (
   id                   serial                              not null,
   country_calling_code varchar                                     ,
   country_id           integer references country(id)      not null,
   phone                varchar                             not null,
   is_verified          boolean default false               not null,
   created_date         timestamp default current_timestamp not null,
   constraint pk_phone primary key (id)
)   ;

-- get_view_create

-- get_permissions_create

-- get_inserts

-- get_smallpackage_post_sql

-- get_associations_create
alter table phone owner to gear_user;
