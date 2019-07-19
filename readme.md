# pg financial functions

plpgsql/plpython3 based financial functions

<!--
> select
>   not exists (select 1 from pg_language where lanname='plpython3u') as has_no_plpython3u
> \gset
> \if :has_no_plpython3u
>   create language plpython3u;
> \endif
-->

## install

see [pg-financial-functions.dockerfile](pg-financial-functions.dockerfile) for dependencies

```
psql -f src\readme.sql
```

## in financial_functions schema

<!--
> drop schema if exists financial_functions cascade;
> create schema financial_functions;
-->

```
> set schema 'financial_functions';
```

## topics

- [`fixed-rate`](fixed-rate.md) calculates future/present/payment/periods/etc of fixed-rate such as loan, annunities
<!--
> \ir fixed-rate.sql
-->

- [`discounted-cash-flow`](discounted-cash-flow.md) calculates the rate-of-return/net-present-value over an investment cashflow
<!--
> \ir discounted-cash-flow.sql
-->

- [`black-scholes option-pricing`](black-scholes-option-pricing.md) calculates the options pricing and it sensitivity with black-scholes model
<!--
> \ir black-scholes-option-pricing.sql
-->

<!--
> set search_path to default;
-->
