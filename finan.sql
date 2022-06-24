\if :{?finan_sql}
\else
\set finan_sql true

drop schema if exists finan cascade;
create schema if not exists finan;

select not exists (
    select 1 from pg_language where lanname='plpython3u'
) as plpython3u_needed \gset

\if :plpython3u_needed
    create language plpython3u;
\endif

\unset plpython3u_needed


\ir src/finan/index.sql

\endif
