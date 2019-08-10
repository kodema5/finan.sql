




create or replace function future_value(
      rate double precision,
      nper double precision,
      pmt double precision default 0,
      pv double precision default 0,
      due int default 0) -- end: 0, begin: 1
returns double precision as $$
      import numpy as np
      return np.fv(rate, nper, pmt, pv, due)
$$ language plpython3u strict;

create or replace function finan_tests.test_future_values() returns setof text as $$
begin
    return next ok(floor(future_value(0.1/4, 4*4, -2000, 0, 1)) = 39729, 'can calc');
    return next ok(future_value(null, 4*4, -2000) is null, 'is strict');
end;
$$ language plpgsql;





















create or replace function present_value(
    rate double precision,
    nper double precision,
    pmt double precision,
    fv double precision default 0,
    due int default 0) -- end: 0, begin: 1
returns double precision as $$
    import numpy as np
    return np.pv(rate, nper, pmt, fv, due)
$$ language plpython3u strict;

create or replace function finan_tests.test_present_values() returns setof text as $$
begin
    return next ok(floor(present_value(0.045/12, 5*12, -93.22)) = 5000, 'can calc');
    return next ok(present_value(null, 5*12, -93.22) is null, 'is strict');
end;
$$ language plpgsql;





















create or replace function payment(
    rate double precision,
    nper double precision,
    pv double precision,
    fv double precision default 0,
    due int default 0) -- end: 0, begin: 1
returns double precision as $$
    import numpy as np
    return np.pmt(rate, nper, pv, fv, due)
$$ language plpython3u strict;

create or replace function finan_tests.test_payment() returns setof text as $$
begin
    return next ok(trunc(payment(0.045/12, 5*12, 5000)) = -93, 'can calc');
    return next ok(payment(0.045, 5*12, null) is null, 'is strict');
end;
$$ language plpgsql;














create or replace function number_of_periods (
    rate double precision,
    pmt double precision,
    pv double precision,
    fv double precision default 0,
    due int default 0) -- end: 0, begin: 1
returns double precision as $$
    import numpy as np
    return np.nper(rate, pmt, pv, fv, due)
$$ language plpython3u strict;












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
$$ language plpython3u strict;












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
$$ language plpython3u strict;



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
$$ language plpython3u strict;

















