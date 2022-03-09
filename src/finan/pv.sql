-- present value

create or replace function finan.pv(
    rate double precision,
    nper double precision,
    pmt double precision,
    fv double precision default 0,
    due int default 0 -- end: 0, begin: 1
)
    returns double precision
    language plpython3u
    strict
as $$
    import numpy_financial as npf
    return npf.pv(rate, nper, pmt, fv, due)
$$;


\if :test
    create or replace function tests.test_finan_pv()
        returns setof text
        language plpgsql
    as $$
    declare
        a numeric;
    begin
        a = finan.pv(0.045/12, 5*12, -93.22);
        return next ok(trunc(a) = 5000, 'calc present-value');
    end;
    $$;
\endif
