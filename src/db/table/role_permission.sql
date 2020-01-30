-- Parse::SQL::Dia      version 0.30                              
-- Documentation        http://search.cpan.org/dist/Parse-Dia-SQL/
-- Environment          Perl 5.026001, /usr/bin/perl              
-- Architecture         x86_64-linux-gnu-thread-multi             
-- Target Database      postgres                                  
-- Input file           table.dia                                 
-- Generated at         Wed Jul  4 16:24:09 2018                  
-- Typemap for postgres not found in input file                   

-- get_constraints_drop 

-- get_permissions_drop 

-- get_view_drop

-- get_schema_drop
drop table role_permission;

-- get_smallpackage_pre_sql 

-- get_schema_create
create table role_permission (
   id            serial                              not null,
   name          varchar                                     ,
   permissions   jsonb default '{}'                          ,
   is_admin_role boolean default false               not null,
   status        boolean default true                        ,
   created_by    integer references account(id)              ,
   created_date  timestamp default current_timestamp         ,
   constraint pk_role_permission primary key (id)
)   ;

-- get_view_create

-- get_permissions_create

-- get_inserts

-- get_smallpackage_post_sql

-- get_associations_create
alter table role_permission owner to gear_user;
