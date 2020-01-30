drop type  obj_company_address cascade;
create type obj_company_address as
(
    id integer,
    line_a varchar,
    line_b varchar,
    location varchar,
    is_main_office boolean
);
