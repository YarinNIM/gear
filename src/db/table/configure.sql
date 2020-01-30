-- Parse::SQL::Dia      version 0.30                              
-- Documentation        http://search.cpan.org/dist/Parse-Dia-SQL/
-- Environment          Perl 5.026001, /usr/bin/perl              
-- Architecture         x86_64-linux-gnu-thread-multi             
-- Target Database      postgres                                  
-- Input file           table.dia                                 
-- Generated at         Fri Nov  9 23:02:04 2018                  
-- Typemap for postgres not found in input file                   

-- get_constraints_drop 

-- get_permissions_drop 

-- get_view_drop

-- get_schema_drop
drop table configure;

-- get_smallpackage_pre_sql 

-- get_schema_create
create table configure (
   id          smallserial                       not null,
   name        varchar unique                    not null,
   key         varchar unique                    not null,
   value       varchar                           not null,
   data_type   varchar default 'varchar'         not null,
   parent_id   smallint references configure(id)         ,
   description varchar default ''                not null,
   constraint pk_configure primary key (id)
)   ;

-- get_view_create

-- get_permissions_create

-- get_inserts

-- get_smallpackage_post_sql

-- get_associations_create
alter table configure owner to gear_user;
