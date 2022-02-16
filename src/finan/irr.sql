-- internal rate of return

create or replace function finan.irr (
    cashflow double precision[]
)
returns double precision as $$
    import numpy_financial as npf
    return npf.irr(cashflow)
$$ language plpython3u immutable strict;


create or replace function finan.irr (
    cashflow double precision[],
    dates date[]
)
returns double precision as $$
    import scipy.optimize
    import datetime
    date_vals = list(map(lambda x: datetime.datetime.strptime(x,'%Y-%m-%d').date(), dates))

    def xnpv (rate, casflow, dates):
        if rate <= -1.0:
            return float('inf')
        d0 = date_vals[0]
        return sum([ vi / (1.0 + rate) ** ((di - d0).days / 365) for vi, di in zip(cashflow, dates)])

    try:
        return scipy.optimize.newton(lambda r: xnpv(r, cashflow, date_vals), 0.0)
    except RuntimeError:    # Failed to converge?
        return scipy.optimize.brentq(lambda r: xnpv(r, cashflow, date_vals), -1.0, 1e10)

$$ language plpython3u immutable strict;


\if :test
    create or replace function tests.test_finan_irr() returns setof text as $$
    begin
        return next ok(
            trunc(finan.irr(array[-10000,3000,4200,6800]::double precision[])::numeric,5) = 0.16340,
            'calc internal rate of returns');

        declare
            a double precision;
            cs double precision[] = array[-1000, 250, 250, 250, 250, 250];
            ds date[] = array['2018-1-1', '2018-6-1', '2018-12-1', '2019-3-1', '2019-9-1', '2019-12-30'];
        begin
            a = finan.irr(cs, ds);
            return next ok(trunc(a::numeric, 3) = 0.204, 'calc internal rate of returns with dates');

            a = finan.npv(a, cs, ds);
            return next ok(trunc(a::numeric, 3) = 0, 'calc npv should be ~0');
        end;

    end;
    $$ language plpgsql;
\endif
