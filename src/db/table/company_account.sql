-- Parse::SQL::Dia      version 0.30                              
-- Documentation        http://search.cpan.org/dist/Parse-Dia-SQL/
-- Environment          Perl 5.026001, /usr/bin/perl              
-- Architecture         x86_64-linux-gnu-thread-multi             
-- Target Database      postgres                                  
-- Input file           table.dia                                 
-- Generated at         Mon Jul 23 16:17:07 2018                  
-- Typemap for postgres not found in input file                   

-- get_constraints_drop 

-- get_permissions_drop 

-- get_view_drop

-- get_schema_drop
drop table company_account;

-- get_smallpackage_pre_sql 

-- get_schema_create
create table company_account (
   id           serial                                 not null,
   company_id   integer references company(id)         not null,
   account_id   integer references account(id)         not null,
   role_id      integer references role_permission(id) not null,
   status       boolean default true                   not null,
   created_date timestamp default current_timestamp    not null,
   create_by    integer references account(id)         not null,
   constraint pk_company_account primary key (id)
)   ;

-- get_view_create

-- get_permissions_create

-- get_inserts

-- get_smallpackage_post_sql

-- get_associations_create
alter table company_account owner to gear_user;
