




select
    not exists (select 1 from pg_language where lanname='plpython3u') as has_no_plpython3u
\gset
\if :has_no_plpython3u
    create language plpython3u;
\endif













drop schema if exists finan_tests cascade;
create schema finan_tests;



drop schema if exists finan cascade;
create schema finan;



set schema 'finan';






\ir fixed-rate.sql




\ir discounted-cash-flow.sql




\ir black-scholes-option-pricing.sql



set search_path to default;



select exists (select 1 from pg_available_extensions where name='pgtap') as has_pgtap
\gset

\if :has_pgtap
set search_path TO finan_tests, finan, public;
create extension if not exists pgtap with schema finan_tests;
select * from runtests('finan_tests'::name);
\endif

drop schema finan_tests cascade;

