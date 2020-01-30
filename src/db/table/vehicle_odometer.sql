-- Parse::SQL::Dia      version 0.30                              
-- Documentation        http://search.cpan.org/dist/Parse-Dia-SQL/
-- Environment          Perl 5.026001, /usr/bin/perl              
-- Architecture         x86_64-linux-gnu-thread-multi             
-- Target Database      postgres                                  
-- Input file           table.dia                                 
-- Generated at         Tue Nov  6 11:04:22 2018                  
-- Typemap for postgres not found in input file                   

-- get_constraints_drop 

-- get_permissions_drop 

-- get_view_drop

-- get_schema_drop
drop table vehicle_odometer;

-- get_smallpackage_pre_sql 

-- get_schema_create
create table vehicle_odometer (
   id            serial                              not null,
   vehicle_id    integer references vehicle(id)      not null,
   odometer_date date default current_date           not null,
   odometer      integer                             not null,
   created_date  timestamp default current_timestamp not null,
   account_id    integer references account(id)      not null,
   company_id    integer references company(id)              ,
   constraint pk_vehicle_odometer primary key (id)
)   ;

-- get_view_create

-- get_permissions_create

-- get_inserts

-- get_smallpackage_post_sql

-- get_associations_create
alter table vehicle_odometer owner to gear_user;
