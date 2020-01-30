-- Parse::SQL::Dia      version 0.30                              
-- Documentation        http://search.cpan.org/dist/Parse-Dia-SQL/
-- Environment          Perl 5.026001, /usr/bin/perl              
-- Architecture         x86_64-linux-gnu-thread-multi             
-- Target Database      postgres                                  
-- Input file           table.dia                                 
-- Generated at         Mon Aug  6 11:22:05 2018                  
-- Typemap for postgres not found in input file                   

-- get_constraints_drop 

-- get_permissions_drop 

-- get_view_drop

-- get_schema_drop
drop table person_title;

-- get_smallpackage_pre_sql 

-- get_schema_create
create table person_title (
   id       serial               not null,
   title_en varchar(10)          not null unique,
   title_kh varchar(50)                  ,
   status   boolean default true not null,
   constraint pk_person_title primary key (id)
)   ;

-- get_view_create

-- get_permissions_create

-- get_inserts

-- get_smallpackage_post_sql

-- get_associations_create
alter table person_title owner to gear_user;
