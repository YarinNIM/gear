-- Parse::SQL::Dia      version 0.30                              
-- Documentation        http://search.cpan.org/dist/Parse-Dia-SQL/
-- Environment          Perl 5.026001, /usr/bin/perl              
-- Architecture         x86_64-linux-gnu-thread-multi             
-- Target Database      postgres                                  
-- Input file           table.dia                                 
-- Generated at         Mon May  7 16:53:52 2018                  
-- Typemap for postgres not found in input file                   

-- get_constraints_drop 

-- get_permissions_drop 

-- get_view_drop

-- get_schema_drop
drop table country_zone;

-- get_smallpackage_pre_sql 

-- get_schema_create
create table country_zone (
   id         serial                         not null,
   country_id integer references country(id) not null,
   name       varchar                        not null,
   code       varchar(5)                     not null,
   status     boolean default true           not null,
   constraint pk_country_zone primary key (id)
)   ;

-- get_view_create

-- get_permissions_create

-- get_inserts

-- get_smallpackage_post_sql

-- get_associations_create
alter table country_zone owner to gear_user;
