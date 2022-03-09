-- periodic payment

create or replace function finan.pmt(
    rate double precision,
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
    return npf.pmt(rate, nper, pv, fv, due)
$$;


\if :test
    create or replace function tests.test_finan_pmt()
        returns setof text
        language plpgsql
    as $$
    declare
        a numeric;
    begin
        a = finan.pmt(0.045/12, 5*12, 5000);
        return next ok(trunc(a) = -93, 'calc periodic payment');
    end;
    $$;
\endif
