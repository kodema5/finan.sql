-- for rate-of-return/net-present-value over an investment cashflow.
-- rate is the alternative interest rate from other source
-- vs the investment cashflow

---------------------------------------------------------------------------

create or replace function finan.npv (
    rate double precision,
    cashflow double precision[]
)
    returns double precision
    language plpython3u
    immutable
    strict
as $$
    import numpy_financial as npf
    return npf.npv(rate, cashflow)
$$;


create or replace function finan.npv (
    rate double precision[],
    cashflow double precision[]
)
    returns double precision
    language plpython3u
    immutable
    strict
as $$
    import numpy_financial as npf
    return [npf.npv(r, cashflow) for r in rate]
$$;


create or replace function finan.npv (
    rate double precision,
    cashflow double precision[],
    dates date[]
)
    returns double precision
    language plpython3u
    immutable
    strict
as $$
    import datetime
    if rate <= -1.0:
        return float('inf')
    date_vals = list(map(lambda x: datetime.datetime.strptime(x,'%Y-%m-%d').date(), dates))
    d0 = date_vals[0]
    return sum([ vi / (1.0 + rate) ** ((di - d0).days / 365) for vi, di in zip(cashflow, date_vals)])
$$;


\if :test
    create or replace function tests.test_finan_npv()
        returns setof text
         language plpgsql
    as $$
    begin
        -- supposed a contract
        declare
            r double precision = 0.1; -- the discount rate
            cs double precision[] = array[-10000,3000,4200,6800]; -- with cashflow
            npv double precision = finan.npv(r, cs); -- the price of this contract is
        begin
            return next ok(trunc(npv) = 1307, 'calc net present values');
        end;

        declare
            a double precision;
            cs double precision[] = array[-1000, 250, 250, 250, 250, 250];
            ds date[] = array['2018-1-1', '2018-6-1', '2018-12-1', '2019-3-1', '2019-9-1', '2019-12-30'];
        begin
            a = finan.npv(0.1, cs, ds);
            return next ok(trunc(a::numeric,2) = 113.27, 'calc net present value with dates');
        end;
    end;
    $$;
\endif
