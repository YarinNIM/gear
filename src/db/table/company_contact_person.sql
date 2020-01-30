-- Parse::SQL::Dia      version 0.30                              
-- Documentation        http://search.cpan.org/dist/Parse-Dia-SQL/
-- Environment          Perl 5.026001, /usr/bin/perl              
-- Architecture         x86_64-linux-gnu-thread-multi             
-- Target Database      postgres                                  
-- Input file           table.dia                                 
-- Generated at         Mon Aug  6 11:27:32 2018                  
-- Typemap for postgres not found in input file                   

-- get_constraints_drop 

-- get_permissions_drop 

-- get_view_drop

-- get_schema_drop
drop table company_contact_person;

-- get_smallpackage_pre_sql 

-- get_schema_create
create table company_contact_person (
   id              serial                              not null,
   company_id      integer references company(id)      not null,
   account_id      integer references account(id)              ,
   position_title  varchar                             not null,
   person_title_id integer references person_title(id) not null,
   first_name      varchar                             not null,
   last_name       varchar                             not null,
   sex             varchar default 'm'                 not null,
   mobile          varchar                             not null,
   email_address   varchar                                     ,
   status          boolean default true                not null,
   constraint pk_company_contact_person primary key (id)
)   ;

-- get_view_create

-- get_permissions_create

-- get_inserts

-- get_smallpackage_post_sql

-- get_associations_create
alter table company_contact_person owner to gear_user;
