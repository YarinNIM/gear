-- Parse::SQL::Dia      version 0.30                              
-- Documentation        http://search.cpan.org/dist/Parse-Dia-SQL/
-- Environment          Perl 5.026001, /usr/bin/perl              
-- Architecture         x86_64-linux-gnu-thread-multi             
-- Target Database      postgres                                  
-- Input file           table.dia                                 
-- Generated at         Wed Oct 24 15:43:27 2018                  
-- Typemap for postgres not found in input file                   

-- get_constraints_drop 

-- get_permissions_drop 

-- get_view_drop

-- get_schema_drop
drop table unit_type;

-- get_smallpackage_pre_sql 

-- get_schema_create
create table unit_type (
   id        smallserial                       not null,
   parent_id smallint references unit_type(id)         ,
   name_en   varchar                           not null,
   name_kh   varchar                           not null,
   constraint pk_unit_type primary key (id)
)   ;

-- get_view_create

-- get_permissions_create

-- get_inserts

-- get_smallpackage_post_sql

-- get_associations_create
alter table unit_type owner to gear_user;
