-- interest payment in period, per

create or replace function finan.ipmt(
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
    return npf.ipmt(rate, per, nper, pv, fv, due)
$$;


\if :test
    create or replace function tests.test_finan_ipmt()
        returns setof text
         language plpgsql
    as $$
    declare
        a numeric;
    begin
        a = finan.ipmt(0.045/12, 12, 5*12, 5000);
        return next ok(trunc(a, 2) = -15.62, 'calc interest payment of a period');
    end;
    $$;
\endif
