
create or replace function finan.normpdf(
    x double precision,
    loc double precision default 0.0,
    scale double precision default 1.0
) returns double precision as $$
    import scipy.stats
    return scipy.stats.norm.pdf(x,loc,scale)
$$ language plpython3u immutable strict;

create or replace function finan.normcdf(
    x double precision,
    loc double precision default 0.0,
    scale double precision default 1.0
) returns double precision as $$
    import scipy.stats
    return scipy.stats.norm.cdf(x,loc,scale)
$$ language plpython3u immutable strict;


create type finan.black_scholes_t as (
    call_price numeric,
    call_delta numeric,
    call_lambda numeric,
    call_rho numeric,
    call_theta numeric,
    gamma numeric,
    put_price numeric,
    put_delta numeric,
    put_lambda numeric,
    put_rho numeric,
    put_theta numeric,
    vega numeric
);

create or replace function finan.black_scholes (
    SO double precision, -- current price
    X double precision, -- exercise price of option
    r double precision, -- risk-free rate over option period
    T double precision, -- option expiration (in years)
    S double precision, -- asset volatility
    q double precision -- asset yield
) returns finan.black_scholes_t as $$
declare
    a finan.black_scholes_t;

    sat double precision = sqrt(t);
    ssat double precision = s * sat;
    ert double precision = exp(-r * t);
    xert double precision = x * ert;
    xertr double precision = xert * r;

    d1 double precision = (ln(so / x) + (r + s*s*0.5) * t) / ssat;
    d2 double precision = d1 - ssat;
    d3 double precision = xert * t;

    ncd1 double precision = finan.normcdf(d1);
    ncd2 double precision = finan.normcdf(d2);
    ncmd1 double precision = finan.normcdf(-d1);
    ncmd2 double precision = finan.normcdf(-d2);
    npd1 double precision = finan.normpdf(d1);
    ncd1m1 double precision = ncd1 - 1;

    eqt double precision = exp(-q * t);
    soeqt double precision = so * eqt;
    soeqtq double precision = soeqt * q;

    b double precision = -soeqt * npd1 * s / (2.0 * sat);
begin
    a.call_price = soeqt * ncd1 - xert * ncd2;
    a.put_price = xert * ncmd2 - soeqt * ncmd1;

    a.call_delta = eqt * ncd1;
    a.put_delta = a.call_delta - eqt;

    a.gamma = npd1 * eqt / (ssat * so);

    if a.call_price>=(1e-14) and a.put_price>=(1e-14) then
        a.call_lambda = so / a.call_price * ncd1;
        a.put_lambda  = case
            when ncd1m1 < 1e-6 then so / a.put_price * (-ncmd1)
            else so / a.put_price * ncd1m1
            end;
    end if;

    a.call_rho = d3 * ncd2;
    a.put_rho = -d3 * ncmd2;

    a.call_theta = b + soeqtq * ncd1 - xertr * ncd2;
    a.put_theta = b - soeqtq * ncmd1 + xertr * ncmd2;

    a.vega = soeqt * sat * npd1;
    return a;
end;
$$ language plpgsql;


\if :test
    create function tests.test_finan_black_scholes() returns setof text as $$
    begin
        declare
            a finan.black_scholes_t;
        begin
            a = finan.black_scholes(50, 50, 0.12, 0.25, 0.3, 0);

            return next ok(trunc(a.call_price,2) = 3.74, 'call price');
            return next ok(trunc(a.put_price,2) = 2.26, 'put price');

            return next ok(trunc(a.call_delta,2) = 0.60, 'call delta');
            return next ok(trunc(a.put_delta,2) = -0.39, 'put delta');

            return next ok(trunc(a.gamma,6) = 0.051218, 'gamma');

            return next ok(trunc(a.call_lambda,2) = 8.12, 'call lambda');
            return next ok(trunc(a.put_lambda,2) = -8.64, 'put lambda');

            return next ok(trunc(a.call_rho,2) = 6.66, 'call rho');
            return next ok(trunc(a.put_rho,2) = -5.46, 'put rho');

            return next ok(trunc(a.call_theta,2) = -8.96, 'call theta');
            return next ok(trunc(a.put_theta,2) = -3.14, 'put theta');

            return next ok(trunc(a.vega,2) = 9.60, 'vega');
        end;

    end;
    $$ language plpgsql;
\endif
