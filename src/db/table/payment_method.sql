-- Parse::SQL::Dia      version 0.30                              
-- Documentation        http://search.cpan.org/dist/Parse-Dia-SQL/
-- Environment          Perl 5.026001, /usr/bin/perl              
-- Architecture         x86_64-linux-gnu-thread-multi             
-- Target Database      postgres                                  
-- Input file           table.dia                                 
-- Generated at         Thu Nov 15 23:11:48 2018                  
-- Typemap for postgres not found in input file                   

-- get_constraints_drop 

-- get_permissions_drop 

-- get_view_drop

-- get_schema_drop
drop table payment_method;

-- get_smallpackage_pre_sql 

-- get_schema_create
create table payment_method (
   id        smallserial                            not null,
   parent_id smallint references payment_method(id)         ,
   name_en   varchar(100) unique                    not null,
   name_kh   varchar                                        ,
   status    boolean default true                   not null,
   constraint pk_payment_method primary key (id)
)   ;

-- get_view_create

-- get_permissions_create

-- get_inserts

-- get_smallpackage_post_sql

-- get_associations_create
alter table payment_method owner to gear_user;
