-- Parse::SQL::Dia      version 0.30                              
-- Documentation        http://search.cpan.org/dist/Parse-Dia-SQL/
-- Environment          Perl 5.026001, /usr/bin/perl              
-- Architecture         x86_64-linux-gnu-thread-multi             
-- Target Database      postgres                                  
-- Input file           table.dia                                 
-- Generated at         Thu Nov  8 10:51:20 2018                  
-- Typemap for postgres not found in input file                   

-- get_constraints_drop 

-- get_permissions_drop 

-- get_view_drop

-- get_schema_drop
drop table fleet_service_detail;

-- get_smallpackage_pre_sql 

-- get_schema_create
create table fleet_service_detail (
   id               serial                                      not null,
   fleet_service_id integer references fleet_service(id)        not null,
   product_id       integer references product(id)              not null,
   qty              smallint                                    not null,
   km_to_use        smallint                                            ,
   attached_to      integer references fleet_service_detail(id)         ,
   constraint pk_fleet_service_detail primary key (id)
)   ;

-- get_view_create

-- get_permissions_create

-- get_inserts

-- get_smallpackage_post_sql

-- get_associations_create
alter table fleet_service_detail owner to gear_user;
