






create or replace function net_present_value(
    rate double precision,
    cashflow double precision[])
returns double precision as $$
    import numpy as np
    return np.npv(rate, cashflow)
$$ language plpython3u;

create or replace function net_present_value(
    rate double precision[],
    cashflow double precision[])
returns double precision as $$
    import numpy as np
    return [np.npv(r, cashflow) for r in rate]
$$ language plpython3u;













create or replace function internal_rate_of_return(
    cashflow double precision[])
returns double precision as $$
    import numpy as np
    return np.irr(cashflow)
$$ language plpython3u;












create or replace function modified_internal_rate_of_return(
    cashflow double precision[],
    rate double precision,     -- rate on cashflow
    reinvest_rate double precision) -- rate on cashflow reinvestment
returns double precision as $$
    import numpy as np
    return np.mirr(cashflow, rate, reinvest_rate)
$$ language plpython3u;

















create or replace function net_present_value(
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
$$ language plpython3u;













create or replace function internal_rate_of_return(
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

$$ language plpython3u;














