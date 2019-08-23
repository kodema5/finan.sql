




select
    not exists (select 1 from pg_language where lanname='plpython3u') as has_no_plpython3u
\gset
\if :has_no_plpython3u
    create language plpython3u;
\endif















drop schema if exists finan_tests cascade;
create schema finan_tests;
drop schema if exists finan cascade;
create schema finan;


set schema 'finan';













create or replace function fv (
      rate double precision,
      nper double precision,
      pmt double precision default 0,
      pv double precision default 0,
      due int default 0) -- end: 0, begin: 1
returns double precision as $$
      import numpy as np
      return np.fv(rate, nper, pmt, pv, due)
$$ language plpython3u immutable strict;

create or replace function finan_tests.test_fv() returns setof text as $$
begin
    return next ok(floor(fv(0.1/4, 4*4, -2000, 0, 1)) = 39729, 'can calc');
    return next ok(fv(null, 4*4, -2000) is null, 'is strict');
end;
$$ language plpgsql;




select fv(0.05/12, 5*12, -1000);







select fv(0.1/4, 4*4, -2000, 0, 1);









create or replace function pv(
    rate double precision,
    nper double precision,
    pmt double precision,
    fv double precision default 0,
    due int default 0) -- end: 0, begin: 1
returns double precision as $$
    import numpy as np
    return np.pv(rate, nper, pmt, fv, due)
$$ language plpython3u strict;

create or replace function finan_tests.test_pv() returns setof text as $$
begin
    return next ok(floor(pv(0.045/12, 5*12, -93.22)) = 5000, 'can calc');
    return next ok(pv(null, 5*12, -93.22) is null, 'is strict');
end;
$$ language plpgsql;




select pv(0.055/12, 5*12, 100);







select pv(0.045/12, 5*12, -93.22);









create or replace function pmt(
    rate double precision,
    nper double precision,
    pv double precision,
    fv double precision default 0,
    due int default 0) -- end: 0, begin: 1
returns double precision as $$
    import numpy as np
    return np.pmt(rate, nper, pv, fv, due)
$$ language plpython3u immutable strict;

create or replace function finan_tests.test_pmt() returns setof text as $$
begin
    return next ok(trunc(pmt(0.045/12, 5*12, 5000)) = -93, 'can calc');
    return next ok(pmt(0.045, 5*12, null) is null, 'is strict');
end;
$$ language plpgsql;




select pmt(0.045/12, 5*12, 5000);




select pmt(0.045/12, 5*12, 5000) * 5*12 + 5000 as total_interest_payments;










create or replace function nper (
    rate double precision,
    pmt double precision,
    pv double precision,
    fv double precision default 0,
    due int default 0) -- end: 0, begin: 1
returns double precision as $$
    import numpy as np
    return np.nper(rate, pmt, pv, fv, due)
$$ language plpython3u immutable strict;




select nper(0.045/12, -100, 5000);








create or replace function rate (
    nper double precision,
    pmt double precision,
    pv double precision,
    fv double precision default 0,
    due int default 0, -- end: 0, begin: 1
    guess double precision default 0.1,
    tol double precision default 1e-6,
    max_iter int default 1000)
returns double precision as $$
    import numpy as np
    return np.rate(nper, pmt, pv, fv, due, guess, tol, max_iter)
$$ language plpython3u immutable strict;




select rate(5 * 12, -93.22, 5000) * 12;








create or replace function ppmt(
      rate double precision,
      per double precision,
      nper double precision,
      pv double precision,
      fv double precision default 0,
      due int default 0) -- end: 0, begin: 1
returns double precision as $$
      import numpy as np
      return np.ppmt(rate, per, nper, pv, fv, due)
$$ language plpython3u immutable strict;



select ppmt(0.045/12, 12, 5*12, 5000);








create or replace function ipmt(
    rate double precision,
    per double precision,
    nper double precision,
    pv double precision,
    fv double precision default 0,
    due int default 0) -- end: 0, begin: 1
returns double precision as $$
    import numpy as np
    return np.ipmt(rate, per, nper, pv, fv, due)
$$ language plpython3u immutable strict;




select pmt(0.045/12, 5*12, 5000);



select ppmt(0.045/12, 12, 5*12, 5000);



select ipmt(0.045/12, 12, 5*12, 5000);














create or replace function npv(
    rate double precision,
    cashflow double precision[])
returns double precision as $$
    import numpy as np
    return np.npv(rate, cashflow)
$$ language plpython3u immutable strict;

create or replace function npv(
    rate double precision[],
    cashflow double precision[])
returns double precision as $$
    import numpy as np
    return [np.npv(r, cashflow) for r in rate]
$$ language plpython3u immutable strict;




select npv(
    0.1,
    array[-10000,3000,4200,6800]::double precision[]);










create or replace function irr (
    cashflow double precision[])
returns double precision as $$
    import numpy as np
    return np.irr(cashflow)
$$ language plpython3u immutable strict;




select irr(array[-10000,3000,4200,6800]::double precision[]);








create or replace function mirr(
    cashflow double precision[],
    rate double precision,     -- rate on cashflow
    reinvest_rate double precision) -- rate on cashflow reinvestment
returns double precision as $$
    import numpy as np
    return np.mirr(cashflow, rate, reinvest_rate)
$$ language plpython3u immutable strict;

create or replace function finan_tests.test_modified_internal_rate_of_return() returns setof text as $$
begin
    return next ok(trunc(mirr(
        array[-10000,3000,4200,6800]::double precision[], 0.1, 0.12) * 100) = 15, 'can calc');
    return next ok(mirr(null, null, null) is null, 'is strict');
    return next ok((mirr(
        array[]::double precision[], 0.1, 0.12) = 'NaN'), 'nan on empty cashflow');
end;
$$ language plpgsql;





select mirr(array[-10000,3000,4200,6800]::double precision[], 0.1, 0.12);












create or replace function npv(
    rate double precision,
    cashflow double precision[],
    dates date[] )
returns double precision as $$
    import datetime
    if rate <= -1.0:
        return float('inf')
    date_vals = list(map(lambda x: datetime.datetime.strptime(x,'%Y-%m-%d').date(), dates))
    d0 = date_vals[0]
    return sum([ vi / (1.0 + rate) ** ((di - d0).days / 365) for vi, di in zip(cashflow, date_vals)])
$$ language plpython3u immutable strict;




select npv(
    0.1,
    array[-1000, 250, 250, 250, 250, 250]::double precision[],
    array['2018-1-1', '2018-6-1', '2018-12-1', '2019-3-1', '2019-9-1', '2019-12-30']::date[]);








create or replace function irr(
    cashflow double precision[],
    dates date[] )
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




select irr(
    array[-1000, 250, 250, 250, 250, 250]::double precision[],
    array['2018-1-1', '2018-6-1', '2018-12-1', '2019-3-1', '2019-9-1', '2019-12-30']::date[]);




select npv(
    0.204099471443879,
    array[-1000, 250, 250, 250, 250, 250]::double precision[],
    array['2018-1-1', '2018-6-1', '2018-12-1', '2019-3-1', '2019-9-1', '2019-12-30']::date[]);










create or replace function normpdf(
    x double precision,
    loc double precision default 0.0,
    scale double precision default 1.0
) returns double precision as $$
    import scipy.stats
    return scipy.stats.norm.pdf(x,loc,scale)
$$ language plpython3u immutable strict;


create or replace function normcdf(
    x double precision,
    loc double precision default 0.0,
    scale double precision default 1.0
) returns double precision as $$
    import scipy.stats
    return scipy.stats.norm.cdf(x,loc,scale)
$$ language plpython3u immutable strict;







create type black_scholes_t as (
    SO double precision, -- current price
    X double precision, -- exercise price of option
    r double precision, -- risk-free rate over option period
    T double precision, -- option expiration (in years)
    S double precision, -- asset volatility
    q double precision -- asset yield
);


create or replace function d1(
    a black_scholes_t
) returns double precision as $$
    select (ln(a.SO / a.X) + (a.r + a.S*a.S/2.0) * a.T) / (a.S * sqrt(a.T))
$$ language sql immutable strict;






create or replace function price(
    a black_scholes_t
) returns double precision[2] as $$
declare
    d1 double precision = d1(a);
    d2 double precision = d1 - (a.S * sqrt(a.T));
    ert double precision = exp(-a.r * a.T);
    eqt double precision = exp(-a.q * a.T);
begin
    return array[
        a.SO * eqt * normcdf(d1) - a.X * ert * normcdf(d2), -- call
        a.X * ert * normcdf(-d2) - a.SO * eqt * normcdf(-d1) -- put
    ]::double precision[2];
end;
$$ language plpgsql immutable strict;



select ((100, 95, 0.1, 0.25, 0.5, 0.0)::black_scholes_t).price;







select ((910, 980, 0.02, 0.25, 0.25, 0.025)::black_scholes_t).price;







select ((1.6, 1.6, 0.08, 0.3333, 0.2, 0.11)::black_scholes_t).price;










create or replace function delta(
    a black_scholes_t
) returns double precision[2] as $$
declare
    d1 double precision = d1(a);
    eqt double precision = exp(-a.q * a.T);
    cd double precision = eqt * normcdf(d1);
begin
    return array[
        cd,
        cd - eqt
    ]::double precision[2];
end;
$$ language plpgsql immutable strict;



select ((50, 50, 0.1, 0.25, 0.3, 0)::black_scholes_t).delta;








create or replace function gamma(
    a black_scholes_t
) returns double precision as $$
declare
    d1 double precision = d1(a);
begin
    return (normpdf(d1) * exp(-a.q * a.t)) / (a.SO * a.s * sqrt(a.T));
end;
$$ language plpgsql immutable strict;


select ((50, 50, 0.1, 0.25, 0.3, 0)::black_scholes_t).gamma;









create or replace function lambda(
    a black_scholes_t
) returns double precision[2] as $$
declare
    d1 double precision = d1(a);
    nd1 double precision = normcdf(d1);

    px double precision[2] = price(a);
    cp double precision = px[1];
    pp double precision = px[2];

    ce double precision;
    pe double precision;
begin
    if cp>=(1e-14) and pp>=(1e-14) then
        ce = a.SO / cp * nd1;
        if nd1-1 < 1e-6 then
            pe = a.SO / pp * (-normcdf(-d1));
        else
            pe = a.SO / pp * (nd1 - 1);
        end if;
    end if;
    return array[ce, pe];
end;
$$ language plpgsql immutable strict;



select ((50, 50, 0.12, 0.25, 0.3, 0)::black_scholes_t).lambda;









create or replace function rho(
    a black_scholes_t
) returns double precision[2] as $$
declare
    d1 double precision = d1(a);
    d2 double precision = d1 - (a.S * sqrt(a.T));
    d3 double precision = a.X * a.T * exp(-a.r * a.T);
begin
    return array[d3 * normcdf(d2), -d3 * normcdf(-d2)];
end;
$$ language plpgsql immutable strict;



select ((50, 50, 0.12, 0.25, 0.3, 0)::black_scholes_t).rho;









create or replace function theta(
    a black_scholes_t
) returns double precision[2] as $$
declare
    d1 double precision = d1(a);
    d2 double precision = d1 - (a.S * sqrt(a.T));

    b double precision = -a.SO * normpdf(d1) * a.S * exp(-a.q * a.T) / (2.0 * sqrt(a.T));
    eqt double precision = a.q * a.SO * exp(-a.q * a.T);
    ert double precision = a.r * a.X * exp(-a.r * a.T);
begin
    return array[
        b + normcdf(D1) * eqt - ert * normcdf(D2),
        b - normcdf(-D1) * eqt + ert * normcdf(-D2)
    ];
end;
$$ language plpgsql immutable strict;



select ((50, 50, 0.12, 0.25, 0.3, 0)::black_scholes_t).theta;









create or replace function vega(
    a black_scholes_t
) returns double precision as $$
    select a.SO * sqrt(a.T) * normpdf(d1(a)) * exp(-a.q * a.T)
$$ language sql immutable strict;



select ((50, 50, 0.12, 0.25, 0.3, 0)::black_scholes_t).vega;






set search_path to default;



select exists (select 1 from pg_available_extensions where name='pgtap') as has_pgtap
\gset

\if :has_pgtap
set search_path TO finan_tests, finan, public;
create extension if not exists pgtap with schema finan_tests;
select * from runtests('finan_tests'::name);
\endif

drop schema finan_tests cascade;

