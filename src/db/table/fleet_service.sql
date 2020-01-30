-- Parse::SQL::Dia      version 0.30                              
-- Documentation        http://search.cpan.org/dist/Parse-Dia-SQL/
-- Environment          Perl 5.026001, /usr/bin/perl              
-- Architecture         x86_64-linux-gnu-thread-multi             
-- Target Database      postgres                                  
-- Input file           table.dia                                 
-- Generated at         Thu Nov  8 12:53:05 2018                  
-- Typemap for postgres not found in input file                   

-- get_constraints_drop 

-- get_permissions_drop 

-- get_view_drop

-- get_schema_drop
drop table fleet_service cascade;

-- get_smallpackage_pre_sql 

-- get_schema_create
create table fleet_service (
   id               serial                              not null,
   vehicle_odometer integer                             not null,
   invoice_id       integer references invoice(id)      not null,
   vehicle_id       integer references vehicle(id)      not null,
   description      varchar                                     ,
   created_date     timestamp default current_timestamp not null,
   status           boolean default true                not null,
   constraint pk_fleet_service primary key (id)
)   ;

-- get_view_create

-- get_permissions_create

-- get_inserts

-- get_smallpackage_post_sql

-- get_associations_create
alter table fleet_service owner to gear_user;
