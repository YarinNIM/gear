drop table if exists real_estate;
create table real_estate
(
    id      serial  primary key not null,
    -- The account ment title
    title   varchar(255) not null,
    -- The descripton of the real estate
    description varchar(500) null null

);
