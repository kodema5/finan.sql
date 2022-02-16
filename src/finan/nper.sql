-- number of periods

create or replace function finan.nper (
    rate double precision,
    pmt double precision,
    pv double precision,
    fv double precision default 0,
    due int default 0) -- end: 0, begin: 1
returns double precision as $$
    import numpy_financial as npf
    return npf.nper(rate, pmt, pv, fv, due)
$$ language plpython3u immutable strict;


\if :test
    create or replace function tests.test_finan_nper() returns setof text as $$
    declare
        a numeric;
    begin
        a = finan.nper(0.045/12, -100, 5000);
        return next ok(trunc(a) = 55, 'calc number of periods');
    end;
    $$ language plpgsql;
\endif
