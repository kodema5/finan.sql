


create or replace function normpdf(
    x double precision,
    loc double precision default 0.0,
    scale double precision default 1.0
) returns double precision as $$
    import scipy.stats
    return scipy.stats.norm.pdf(x,loc,scale)
$$ language plpython3u;


create or replace function normcdf(
    x double precision,
    loc double precision default 0.0,
    scale double precision default 1.0
) returns double precision as $$
    import scipy.stats
    return scipy.stats.norm.cdf(x,loc,scale)
$$ language plpython3u;







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
$$ language sql;





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
$$ language plpgsql;





























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
$$ language plpgsql;











create or replace function gamma(
    a black_scholes_t
) returns double precision as $$
declare
    d1 double precision = d1(a);
begin
    return (normpdf(d1) * exp(-a.q * a.t)) / (a.SO * a.s * sqrt(a.T));
end;
$$ language plpgsql;











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
$$ language plpgsql;












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
$$ language plpgsql;












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
$$ language plpgsql;












create or replace function vega(
    a black_scholes_t
) returns double precision as $$
    select a.SO * sqrt(a.T) * normpdf(d1(a)) * exp(-a.q * a.T)
$$ language sql;








