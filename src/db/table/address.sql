-- Parse::SQL::Dia      version 0.30                              
-- Documentation        http://search.cpan.org/dist/Parse-Dia-SQL/
-- Environment          Perl 5.026001, /usr/bin/perl              
-- Architecture         x86_64-linux-gnu-thread-multi             
-- Target Database      postgres                                  
-- Input file           table.dia                                 
-- Generated at         Mon Jan 28 14:58:04 2019                  
-- Typemap for postgres not found in input file                   

-- get_constraints_drop 

-- get_permissions_drop 

-- get_view_drop

-- get_schema_drop
drop table address;

-- get_smallpackage_pre_sql 

-- get_schema_create
create table address (
   id           serial                         not null,
   created_by   integer references account(id) not null,
   address_name varchar                        not null,
   address      varchar                        not null,
   village_id   integer references village(id) not null,
   location     varchar                                ,
   status       boolean default true           not null,
   constraint pk_address primary key (id)
)   ;

-- get_view_create

-- get_permissions_create

-- get_inserts

-- get_smallpackage_post_sql

-- get_associations_create
alter table address owner to gear_user;
