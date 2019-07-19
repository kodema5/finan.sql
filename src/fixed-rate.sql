




create or replace function future_value(
      rate double precision,
      nper double precision,
      pmt double precision default 0,
      pv double precision default 0,
      due int default 0) -- end: 0, begin: 1
returns double precision as $$
      import numpy as np
      return np.fv(rate, nper, pmt, pv, due)
$$ language plpython3u;





















create or replace function present_value(
    rate double precision,
    nper double precision,
    pmt double precision,
    fv double precision default 0,
    due int default 0) -- end: 0, begin: 1
returns double precision as $$
    import numpy as np
    return np.pv(rate, nper, pmt, fv, due)
$$ language plpython3u;






















create or replace function payment(
    rate double precision,
    nper double precision,
    pv double precision,
    fv double precision default 0,
    due int default 0) -- end: 0, begin: 1
returns double precision as $$
    import numpy as np
    return np.pmt(rate, nper, pv, fv, due)
$$ language plpython3u;













create or replace function number_of_periods (
    rate double precision,
    pmt double precision,
    pv double precision,
    fv double precision default 0,
    due int default 0) -- end: 0, begin: 1
returns double precision as $$
    import numpy as np
    return np.nper(rate, pmt, pv, fv, due)
$$ language plpython3u;












create or replace function rate (
    nper double precision,
    pmt double precision,
    pv double precision,
    fv double precision default 0,
    due int default 0, -- end: 0, begin: 1
    guess double precision default 0.1,
    tol double precision default 1e-6,
    maxiter int default 1000)
returns double precision as $$
    import numpy as np
    return np.rate(nper, pmt, pv, fv, due, guess, tol, maxiter)
$$ language plpython3u;












create or replace function principal_payment(
      rate double precision,
      per double precision,
      nper double precision,
      pv double precision,
      fv double precision default 0,
      due int default 0) -- end: 0, begin: 1
returns double precision as $$
      import numpy as np
      return np.ppmt(rate, per, nper, pv, fv, due)
$$ language plpython3u;



create or replace function interest_payment(
    rate double precision,
    per double precision,
    nper double precision,
    pv double precision,
    fv double precision default 0,
    due int default 0) -- end: 0, begin: 1
returns double precision as $$
    import numpy as np
    return np.ipmt(rate, per, nper, pv, fv, due)
$$ language plpython3u;

















