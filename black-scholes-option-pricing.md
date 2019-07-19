# black scholes option pricing

<!--
> create or replace function normpdf(
>   x double precision,
>   loc double precision default 0.0,
>   scale double precision default 1.0
> ) returns double precision as $$
>   import scipy.stats
>   return scipy.stats.norm.pdf(x,loc,scale)
> $$ language plpython3u;


> create or replace function normcdf(
>   x double precision,
>   loc double precision default 0.0,
>   scale double precision default 1.0
> ) returns double precision as $$
>   import scipy.stats
>   return scipy.stats.norm.cdf(x,loc,scale)
> $$ language plpython3u;
-->

Call - option to buy on or before date at certain price,
Put  - option to sell on or before date at certain price;
like an insurance for a trade. where:

```
> create type black_scholes_t as (
>   SO double precision, -- current price
>   X double precision, -- exercise price of option
>   r double precision, -- risk-free rate over option period
>   T double precision, -- option expiration (in years)
>   S double precision, -- asset volatility
>   q double precision -- asset yield
> );
```
<!--
> create or replace function d1(
>   a black_scholes_t
> ) returns double precision as $$
>   select (ln(a.SO / a.X) + (a.r + a.S*a.S/2.0) * a.T) / (a.S * sqrt(a.T))
> $$ language sql;
-->

`[callPrice, putPrice] = price(black_scholes_t)` call and put option pricing

<!--
> create or replace function price(
>   a black_scholes_t
> ) returns double precision[2] as $$
> declare
>   d1 double precision = d1(a);
>   d2 double precision = d1 - (a.S * sqrt(a.T));
>   ert double precision = exp(-a.r * a.T);
>   eqt double precision = exp(-a.q * a.T);
> begin
>   return array[
>       a.SO * eqt * normcdf(d1) - a.X * ert * normcdf(d2), -- call
>       a.X * ert * normcdf(-d2) - a.SO * eqt * normcdf(-d1) -- put
>   ]::double precision[2];
> end;
> $$ language plpgsql;
-->
an option expired in 3 months at an exercise price of $95. Trading at at $100, and volatility of 50% per annum, with risk-free rate of 10%.
```
 > select ((100, 95, 0.1, 0.25, 0.5, 0.0)::black_scholes_t).price;
                price
-------------------------------------
{13.6952727386081,6.34971438129973}
```

s&p-100 is at 910 with 25% volatility and 2.5% dividend, risk-free rate is 2%. what is strike price at 980 for 3 months options
```
 > select ((910, 980, 0.02, 0.25, 0.25, 0.025)::black_scholes_t).price;
                price
-------------------------------------
{19.6366634066511,90.4186565481906}
```

option to buy GBP with USD in 4 months at 1.6, when 8% USD interest and 11% GBP and USD volatility at 20%
```
 > select ((1.6, 1.6, 0.08, 0.3333, 0.2, 0.11)::black_scholes_t).price;
                price
-----------------------------------------
{0.0603272194547098,0.0758270545223216}
```


`[callDelta, putDelta] = delta(black_scholes_t)` sensitivity to price change

<!--
> create or replace function delta(
>   a black_scholes_t
> ) returns double precision[2] as $$
> declare
>   d1 double precision = d1(a);
>   eqt double precision = exp(-a.q * a.T);
>   cd double precision = eqt * normcdf(d1);
> begin
>   return array[
>       cd,
>       cd - eqt
>   ]::double precision[2];
> end;
> $$ language plpgsql;
-->

```
 > select ((50, 50, 0.1, 0.25, 0.3, 0)::black_scholes_t).delta;
                delta
----------------------------------------
{0.595480769902361,-0.404519230097639}
```
`gamma(black_scholes_t)` sensitivity to delta change

<!--
> create or replace function gamma(
>   a black_scholes_t
> ) returns double precision as $$
> declare
>   d1 double precision = d1(a);
> begin
>   return (normpdf(d1) * exp(-a.q * a.t)) / (a.SO * a.s * sqrt(a.T));
> end;
> $$ language plpgsql;
-->
```
 > select ((50, 50, 0.1, 0.25, 0.3, 0)::black_scholes_t).gamma;
    gamma
--------------------
0.0516614748457897
```

`[CallEl, PutEl] = labmda(black_scholes_t)` option elasticity - % change in option price over change in asset-price (SO)

<!--
> create or replace function lambda(
>   a black_scholes_t
> ) returns double precision[2] as $$
> declare
>   d1 double precision = d1(a);
>   nd1 double precision = normcdf(d1);

>   px double precision[2] = price(a);
>   cp double precision = px[1];
>   pp double precision = px[2];

>   ce double precision;
>   pe double precision;
> begin
>   if cp>=(1e-14) and pp>=(1e-14) then
>       ce = a.SO / cp * nd1;
>       if nd1-1 < 1e-6 then
>           pe = a.SO / pp * (-normcdf(-d1));
>       else
>           pe = a.SO / pp * (nd1 - 1);
>       end if;
>   end if;
>   return array[ce, pe];
> end;
> $$ language plpgsql;
-->

```
 > select ((50, 50, 0.12, 0.25, 0.3, 0)::black_scholes_t).lambda;
                lambda
--------------------------------------
{8.12738492654569,-8.64655992790169}
```

`[CallRho, PutRho] = rho(black_scholes_t)` % change in option price over change in interest rate (r)

<!--
> create or replace function rho(
>   a black_scholes_t
> ) returns double precision[2] as $$
> declare
>   d1 double precision = d1(a);
>   d2 double precision = d1 - (a.S * sqrt(a.T));
>   d3 double precision = a.X * a.T * exp(-a.r * a.T);
> begin
>   return array[d3 * normcdf(d2), -d3 * normcdf(-d2)];
> end;
> $$ language plpgsql;
-->

```
 > select ((50, 50, 0.12, 0.25, 0.3, 0)::black_scholes_t).rho;
                rho
--------------------------------------
{6.66863756134086,-5.46193160801549}
```

`[CallTheta, PutTheta] = theta(black_scholes_t)` % change in option price over change in time (T)

<!--
> create or replace function theta(
>   a black_scholes_t
> ) returns double precision[2] as $$
> declare
>   d1 double precision = d1(a);
>   d2 double precision = d1 - (a.S * sqrt(a.T));

>   b double precision = -a.SO * normpdf(d1) * a.S * exp(-a.q * a.T) / (2.0 * sqrt(a.T));
>   eqt double precision = a.q * a.SO * exp(-a.q * a.T);
>   ert double precision = a.r * a.X * exp(-a.r * a.T);
> begin
>   return array[
>       b + normcdf(D1) * eqt - ert * normcdf(D2),
>       b - normcdf(-D1) * eqt + ert * normcdf(-D2)
>   ];
> end;
> $$ language plpgsql;
-->

```
 > select ((50, 50, 0.12, 0.25, 0.3, 0)::black_scholes_t).theta;
                theta
---------------------------------------
{-8.96302975902918,-3.14035655773813}
```

`vega(black_scholes_t)` % change in option price over volatility (S)

<!--
> create or replace function vega(
>   a black_scholes_t
> ) returns double precision as $$
>   select a.SO * sqrt(a.T) * normpdf(d1(a)) * exp(-a.q * a.T)
> $$ language sql;
-->

```
 > select ((50, 50, 0.12, 0.25, 0.3, 0)::black_scholes_t).vega;
    vega
------------------
9.60347288264262
```
