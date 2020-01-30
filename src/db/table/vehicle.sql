-- Parse::SQL::Dia      version 0.30                              
-- Documentation        http://search.cpan.org/dist/Parse-Dia-SQL/
-- Environment          Perl 5.026001, /usr/bin/perl              
-- Architecture         x86_64-linux-gnu-thread-multi             
-- Target Database      postgres                                  
-- Input file           table.dia                                 
-- Generated at         Sat Sep 29 10:15:25 2018                  
-- Typemap for postgres not found in input file                   

-- get_constraints_drop 

-- get_permissions_drop 

-- get_view_drop

-- get_schema_drop
drop table vehicle;

-- get_smallpackage_pre_sql 

-- get_schema_create
create table vehicle (
   id               serial                               not null,
   vehicle_model_id integer references vehicle_model(id) not null,
   plate_number     varchar unique                               ,
   year             varchar(4)                                   ,
   color_id         integer references color(id)         not null,
   owner_id         integer references account(id)       not null,
   description      varchar                                      ,
   account_id       integer references account(id)       not null,
   created_date     timestamp default current_timestamp  not null,
   status           boolean default true                 not null,
   constraint pk_vehicle primary key (id)
)   ;

-- get_view_create

-- get_permissions_create

-- get_inserts

-- get_smallpackage_post_sql

-- get_associations_create
alter table vehicle owner to gear_user;
