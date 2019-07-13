# discounted cash-flow analysis

- rate is the alternative interest rate from other source vs the investment cashflow

`net_present_value(rate, cashflow=[])`

<!--
> create or replace function net_present_value(
>   rate double precision,
>   cashflow double precision[])
> returns double precision as $$
>   import numpy as np
>   return np.npv(rate, cashflow)
> $$ language plpython3u;

> create or replace function net_present_value(
>   rate double precision[],
>   cashflow double precision[])
> returns double precision as $$
>   import numpy as np
>   return [np.npv(r, cashflow) for r in rate]
> $$ language plpython3u;
-->

- given a discount-rate 10%, a 10000 investments returns cashflow as below. this investment's worth now is:
    ```
    > select net_present_value(0.1, array[-10000,3000,4200,6800]::double precision[]);
    net_present_value
    -------------------
    1307.28775356874
    ```
- excel has a [different](https://feasibility.pro/npv-calculation-in-excel-numbers-not-match/) way to calc

`internal_rate_of_return(rate, cashflow=[])`
<!--
> create or replace function internal_rate_of_return(
>   cashflow double precision[])
> returns double precision as $$
>   import numpy as np
>   return np.irr(cashflow)
> $$ language plpython3u;
-->

- given a set of cashflow, what rate is which gives net-present-value = 0
    ```
    > select internal_rate_of_return(array[-10000,3000,4200,6800]::double precision[]);
    internal_rate_of_return
    -------------------------
        0.163405600688989
    ```

`modified_internal_rate_of_return(cashflow=[], rate, reinvest_rate)`
<!--
> create or replace function modified_internal_rate_of_return(
>   cashflow double precision[],
>   rate double precision,     -- rate on cashflow
>   reinvest_rate double precision) -- rate on cashflow reinvestment
> returns double precision as $$
>   import numpy as np
>   return np.mirr(cashflow, rate, reinvest_rate)
> $$ language plpython3u;
-->

- a 10k loan generates a cashflow. a 10% interest for the 10k loan, and 12% for reinvested profits
    ```
    > select modified_internal_rate_of_return(array[-10000,3000,4200,6800]::double precision[], 0.1, 0.12);
    modified_internal_rate_of_return
    ----------------------------------
                    0.151471336646763
    ```



`net_present_value(rate, cashflow=[], dates=[])`

<!--
ref: https://stackoverflow.com/questions/8919718/financial-python-library-that-has-xirr-and-xnpv-function

> create or replace function net_present_value(
>   rate double precision,
>   cashflow double precision[],
>   dates date[] )
> returns double precision as $$
>   import datetime
>   if rate <= -1.0:
>       return float('inf')
>   date_vals = list(map(lambda x: datetime.datetime.strptime(x,'%Y-%m-%d').date(), dates))
>   d0 = date_vals[0]
>   return sum([ vi / (1.0 + rate) ** ((di - d0).days / 365) for vi, di in zip(cashflow, date_vals)])
> $$ language plpython3u;
-->

- a -1000 loan at 1/1/2018, returns cashflow as below with 10% discount rate; its values now is:
    ```
    > select net_present_value(0.1, array[-1000, 250, 250, 250, 250, 250]::double precision[], array[date '2018-1-1', date '2018-6-1', date '2018-12-1', date '2019-3-1', date '2019-9-1', date '2019-12-30']::date[]);
    net_present_value
    -------------------
    113.271525238905
    ```

`internal_rate_of_return(cashflow=[], dates=[])`

<!--
> create or replace function internal_rate_of_return(
>   cashflow double precision[],
>   dates date[] )
> returns double precision as $$
>   import scipy.optimize
>   import datetime
>   date_vals = list(map(lambda x: datetime.datetime.strptime(x,'%Y-%m-%d').date(), dates))

>   def xnpv (rate, casflow, dates):
>       if rate <= -1.0:
>           return float('inf')
>       d0 = date_vals[0]
>       return sum([ vi / (1.0 + rate) ** ((di - d0).days / 365) for vi, di in zip(cashflow, dates)])

>   try:
>       return scipy.optimize.newton(lambda r: xnpv(r, cashflow, date_vals), 0.0)
>   except RuntimeError:    # Failed to converge?
>       return scipy.optimize.brentq(lambda r: xnpv(r, cashflow, date_vals), -1.0, 1e10)

> $$ language plpython3u;
-->

- a -1000 loan at 1/1/2018, returns cashflow as below; rate of return for net-present-value ~ 0
    ```
    > select internal_rate_of_return(array[-1000, 250, 250, 250, 250, 250]::double precision[], array[date '2018-1-1', date '2018-6-1', date '2018-12-1', date '2019-3-1', date '2019-9-1', date '2019-12-30']::date[]);
    internal_rate_of_return
    -------------------------
        0.204099471443879

    > select net_present_value(0.204099471443879, array[-1000, 250, 250, 250, 250, 250]::double precision[], array[date '2018-1-1', date '2018-6-1', date '2018-12-1', date '2019-3-1', date '2019-9-1', date '2019-12-30']::date[]);
    net_present_value
    ----------------------
    3.38218342221808e-12
    ```
