create function finan.init_cashflow()
    returns void
    language plpython3u
    security definer
as $$
    fin = GD['finan']
    sci = fin.scipy
    num = fin.numpy

    # net present value over rate r and cashflow cs
    def npv (r, cs):
        if r < -1.0:
            return float('inf')
        return sum([
            c / (1 + r)**i
            for i, c
            in enumerate(cs)
        ])

    fin.npv = npv

    # r as such npv(r,cs) = 0
    def irr (cs):
        try:
            return sci.optimize.newton(
                lambda r: npv(r, cs),
                0.0) # x0
        except RuntimeError:
            return sci.optimize.brentq(
                lambda r: npv(r, cs),
                -1.0, # xa
                1e10) # xb

    fin.irr = irr

    # modified rate of return over cashflow cs, rate r,
    # and reinvestment rate
    def mirr(cs, r, rr):
        arr = num.asarray(cs)
        n = arr.size
        pos = arr > 0
        neg = arr < 0
        if not (pos.any() and neg.any()):
            return float('nan')
        a = num.abs(npv(rr, arr * pos))
        b = num.abs(npv(r, arr * neg))
        return (a/b)**(1/(n-1)) * (1 + rr) - 1

    fin.mirr = mirr
$$;

create or replace function finan.irr (
    cashflow double precision[]
)
    returns double precision
    language plpython3u
    security definer
    strict
as $$
    if 'finan' not in GD: plpy.execute("select finan.init()")
    return GD['finan'].irr(cashflow)
$$;


create or replace function finan.mirr(
    cashflow double precision[],
    rate double precision,     -- rate on cashflow
    reinvest_rate double precision -- rate on cashflow reinvestment
)
    returns double precision
    language plpython3u
    immutable
    strict
as $$
    if 'finan' not in GD: plpy.execute("select finan.init()")
    return GD['finan'].mirr(cashflow, rate, reinvest_rate)
$$;

\if :test
    create or replace function tests.test_finan_cashflow()
        returns setof text
         language plpgsql
    as $$
    begin
        return next ok(
            trunc(finan.irr(array[-10000,3000,4200,6800]::double precision[])::numeric,5) = 0.16340,
            'calc internal rate of returns');


        return next ok(trunc(finan.mirr(
            array[-10000,3000,4200,6800]::double precision[], 0.1, 0.12) * 100) = 15,
            'calc modified internal rate of return');

    end;
    $$;
\endif

