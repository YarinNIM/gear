-- Parse::SQL::Dia      version 0.30                              
-- Documentation        http://search.cpan.org/dist/Parse-Dia-SQL/
-- Environment          Perl 5.026001, /usr/bin/perl              
-- Architecture         x86_64-linux-gnu-thread-multi             
-- Target Database      postgres                                  
-- Input file           table.dia                                 
-- Generated at         Mon Jan 28 12:31:27 2019                  
-- Typemap for postgres not found in input file                   

-- get_constraints_drop 

-- get_permissions_drop 

-- get_view_drop

-- get_schema_drop
drop table account_address cascade;

-- get_smallpackage_pre_sql 

-- get_schema_create
create table account_address (
   id            serial                         not null,
   contact_phone varchar(20)                    not null,
   address_name  varchar                        not null,
   address       varchar                        not null,
   village_id    integer references village(id) not null,
   status        boolean default true           not null,
   constraint pk_account_address primary key (id)
)   ;

-- get_view_create

-- get_permissions_create

-- get_inserts

-- get_smallpackage_post_sql

-- get_associations_create
alter table account_address owner to gear_user;
