-- principal payment in period, per

create or replace function finan.ppmt(
    rate double precision,
    per double precision,
    nper double precision,
    pv double precision,
    fv double precision default 0,
    due int default 0 -- end: 0, begin: 1
)
    returns double precision
    language plpython3u
    immutable
    strict
as $$
    import numpy_financial as npf
    return npf.ppmt(rate, per, nper, pv, fv, due)
$$;


\if :test
    create or replace function tests.test_finan_ppmt()
        returns setof text
        language plpgsql
    as $$
    declare
        a numeric;
    begin
        a = finan.ppmt(0.045/12, 12, 5*12, 5000);
        return next ok(trunc(a, 2) = -77.59, 'calc principal payment of a period');
    end;
    $$;
\endif
