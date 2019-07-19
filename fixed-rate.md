# fixed rate functions

`future_value(rate, nper, pmt, pv=0, due=0/1)`

<!--
> create or replace function future_value(
>     rate double precision,
>     nper double precision,
>     pmt double precision default 0,
>     pv double precision default 0,
>     due int default 0) -- end: 0, begin: 1
> returns double precision as $$
>     import numpy as np
>     return np.fv(rate, nper, pmt, pv, due)
> $$ language plpython3u;
-->

invest 1000/month for 5 years with compounded at 5%/yr
```
 > select future_value(0.05/12, 5*12, -1000);
future_value
------------------
68006.0828408428
```

invest on start of quarters, 2000/q for 4 years with rate 10%/year
```
 > select future_value(0.1/4, 4*4, -2000, 0, 1);
future_value
------------------
39729.4608941661
```

`present_value(rate, nper, pmt, fv=0, due=0/1)`

<!--
> create or replace function present_value(
>   rate double precision,
>   nper double precision,
>   pmt double precision,
>   fv double precision default 0,
>   due int default 0) -- end: 0, begin: 1
> returns double precision as $$
>   import numpy as np
>   return np.pv(rate, nper, pmt, fv, due)
> $$ language plpython3u;
-->


cd pays 100/mo with 5.5%/year for 5 years. buy if less than present-value
```
 > select present_value(0.055/12, 5*12, 100);
present_value
------------------
-5235.2835445651
```

a loan of 4.5%, 93.22 payment for 5 years. the original loan is:
```
 > select present_value(0.045/12, 5*12, -93.22);
present_value
------------------
5000.26303638651
```

`payment(rate, nper, pv, fv=0, due=0/1)`

<!--
> create or replace function payment(
>   rate double precision,
>   nper double precision,
>   pv double precision,
>   fv double precision default 0,
>   due int default 0) -- end: 0, begin: 1
> returns double precision as $$
>   import numpy as np
>   return np.pmt(rate, nper, pv, fv, due)
> $$ language plpython3u;
-->

a loan of 5000, with 4.5%, for 5 years. payment per period is:
```
 > select payment(0.045/12, 5*12, 5000);
    payment
------------------
-93.215096207585
```

`number_of_periods(rate, pmt, pv, fv=0, due=0/1)`

<!--
> create or replace function number_of_periods (
>   rate double precision,
>   pmt double precision,
>   pv double precision,
>   fv double precision default 0,
>   due int default 0) -- end: 0, begin: 1
> returns double precision as $$
>   import numpy as np
>   return np.nper(rate, pmt, pv, fv, due)
> $$ language plpython3u;
-->

a loan of 5000, with 4.5%, paid 100/mo, will take
```
 > select number_of_periods(0.045/12, -100, 5000);
    periods
------------------
55.4742521906629
```

`rate(nper, pmt, pv, fv=0, due=0/1, guess=0.1, tol=1e-6, maxiter=1000)`
<!--
> create or replace function rate (
>   nper double precision,
>   pmt double precision,
>   pv double precision,
>   fv double precision default 0,
>   due int default 0, -- end: 0, begin: 1
>   guess double precision default 0.1,
>   tol double precision default 1e-6,
>   maxiter int default 1000)
> returns double precision as $$
>   import numpy as np
>   return np.rate(nper, pmt, pv, fv, due, guess, tol, maxiter)
> $$ language plpython3u;
-->

a loan of 5000, paid 100/mo, for 5 years
```
 > select rate(5 * 12, -93.22, 5000) * 12;
    ?column?
--------------------
0.0450215684902132
```

`principal_payment(rate, per, nper, pv, fv=0, due=0/1)`
<!--
> create or replace function principal_payment(
>     rate double precision,
>     per double precision,
>     nper double precision,
>     pv double precision,
>     fv double precision default 0,
>     due int default 0) -- end: 0, begin: 1
> returns double precision as $$
>     import numpy as np
>     return np.ppmt(rate, per, nper, pv, fv, due)
> $$ language plpython3u;
-->
`interest_payment(rate, per, nper, pv, fv=0, due=0/1)`
<!--
> create or replace function interest_payment(
>   rate double precision,
>   per double precision,
>   nper double precision,
>   pv double precision,
>   fv double precision default 0,
>   due int default 0) -- end: 0, begin: 1
> returns double precision as $$
>   import numpy as np
>   return np.ipmt(rate, per, nper, pv, fv, due)
> $$ language plpython3u;
-->

a loan of 5000, with 4.5%, for 5 years. payment per period is, on the 12th month,
```
 > select payment(0.045/12, 5*12, 5000);
    payment
------------------
-93.215096207585
 > select principal_payment(0.045/12, 12, 5*12, 5000);
principal_payment
-------------------
-77.595028342707
 > select interest_payment(0.045/12, 12, 5*12, 5000);
interest_payment
------------------
-15.620067864878
```
