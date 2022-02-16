-- rate

create or replace function finan.rate (
    nper double precision,
    pmt double precision,
    pv double precision,
    fv double precision default 0,
    due int default 0, -- end: 0, begin: 1
    guess double precision default 0.1,
    tol double precision default 1e-6,
    max_iter int default 1000)
returns double precision as $$
    import numpy_financial as npf
    return npf.rate(nper, pmt, pv, fv, due, guess, tol, max_iter)
$$ language plpython3u immutable strict;


\if :test
    create or replace function tests.test_finan_rate() returns setof text as $$
    declare
        a numeric;
    begin
        a = finan.rate(5 * 12.0, -93.22, 5000) * 12 * 100;
        return next ok(trunc(a,2) = 4.50, 'calc rate');
    end;
    $$ language plpgsql;
\endif
