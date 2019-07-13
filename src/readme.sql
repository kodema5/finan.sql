




select
    not exists (select 1 from pg_language where lanname='plpython3u') as has_no_plpython3u
\gset
\if :has_no_plpython3u
    create language plpython3u;
\endif













drop schema if exists financial_functions cascade;
create schema financial_functions;



set schema 'financial_functions';






\ir fixed-rate.sql




\ir discounted-cash-flow.sql




set search_path to default;

