-- multiple internal rate of return

create or replace function finan.mirr(
    cashflow double precision[],
    rate double precision,     -- rate on cashflow
    reinvest_rate double precision) -- rate on cashflow reinvestment
returns double precision as $$
    import numpy_financial as npf
    return npf.mirr(cashflow, rate, reinvest_rate)
$$ language plpython3u immutable strict;


\if :test
    create or replace function tests.test_finan_mirr() returns setof text as $$
    begin
        return next ok(trunc(finan.mirr(
            array[-10000,3000,4200,6800]::double precision[], 0.1, 0.12) * 100) = 15, 'can calc');

        return next ok((finan.mirr(
            array[]::double precision[], 0.1, 0.12) = 'NaN'), 'nan on empty cashflow');
    end;
    $$ language plpgsql;
\endif
