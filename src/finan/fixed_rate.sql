-- https://numpy.org/numpy-financial/latest/index.html
--
create function finan.init_fixed_rate()
    returns void
    language plpython3u
    security definer
as $$
    fin = GD['finan']
    sym = fin.sympy
    pmt, pv, fv, due, rate, nper = sym.symbols('fv, pmt, pv, due, rate, nper')

    # equation to solve
    e = sym.Eq (
        fv # future value
        + pv * (1 + rate)**nper # is compounded present value
        + pmt * (1 + rate * due)/rate * ((1 + rate)**nper - 1) # and periodic payments
        , 0
    )

    fin.fv = sym.lambdify(
        [rate,nper,pmt,pv,due],
        sym.solve(e,fv))

    fin.nper = sym.lambdify(
        [rate,pmt,pv,fv,due],
        sym.solve(e,nper))

    fin.pmt = sym.lambdify(
        [rate,nper,pv,fv,due],
        sym.solve(e,pmt))

    fin.pv = sym.lambdify(
        [rate,nper,pmt,fv,due],
        sym.solve(e,pv))

    fin.rate = lambda x0, guess=0.1: sym.nsolve(
        sym.Subs(e, (nper, pmt, pv, fv, due), x0).doit(),
        rate,
        guess)
$$;


create or replace function finan.fv (
      rate double precision,
      nper double precision,
      pmt double precision default 0,
      pv double precision default 0,
      due int default 0 -- end: 0, begin: 1
)
    returns double precision
    language plpython3u
    security definer
    immutable
    strict
as $$
    if 'finan' not in GD: plpy.execute("select finan.init()")
    return GD['finan'].fv(rate, nper, pmt, pv, due)[0]
$$;

create or replace function finan.nper (
    rate double precision,
    pmt double precision,
    pv double precision,
    fv double precision default 0,
    due int default 0 -- end: 0, begin: 1
)
    returns double precision
    language plpython3u
    security definer
    immutable
    strict
as $$
    if 'finan' not in GD: plpy.execute("select finan.init()")
    return GD['finan'].nper(rate, pmt, pv, fv, due)[0]
$$;

create or replace function finan.pmt(
    rate double precision,
    nper double precision,
    pv double precision,
    fv double precision default 0,
    due int default 0 -- end: 0, begin: 1
)
    returns double precision
    language plpython3u
    security definer
    strict
as $$
    if 'finan' not in GD: plpy.execute("select finan.init()")
    return GD['finan'].pmt(rate, nper, pv, fv, due)[0]
$$;


create or replace function finan.pv(
    rate double precision,
    nper double precision,
    pmt double precision,
    fv double precision default 0,
    due int default 0 -- end: 0, begin: 1
)
    returns double precision
    language plpython3u
    strict
as $$
    if 'finan' not in GD: plpy.execute("select finan.init()")
    return GD['finan'].pv(rate, nper, pmt, fv, due)[0]
$$;

create or replace function finan.rate (
    nper double precision,
    pmt double precision,
    pv double precision,
    fv double precision default 0,
    due int default 0, -- end: 0, begin: 1
    guess double precision default 0.1
)
    returns double precision
    language plpython3u
    security definer
    strict
as $$
    if 'finan' not in GD: plpy.execute("select finan.init()")
    return GD['finan'].rate((nper, pmt, pv, fv, due))
$$;


\if :test
    create or replace function tests.test_finan_fixed_rate()
        returns setof text
         language plpgsql
    as $$
    declare
        a numeric;
    begin
        a = finan.fv(0.1/4, 4*4, -2000, 0, 1);
        return next ok(trunc(a) = 39729, 'calc future-value');

        a = finan.nper(0.045/12, -100, 5000);
        return next ok(trunc(a) = 55, 'calc number of periods');

        a = finan.pmt(0.045/12, 5*12, 5000);
        return next ok(trunc(a) = -93, 'calc periodic payment');

        a = finan.pv(0.045/12, 5*12, -93.22);
        return next ok(trunc(a) = 5000, 'calc present-value');

        a = finan.rate(5 * 12.0, -93.22, 5000) * 12 * 100;
        return next ok(trunc(a,2) = 4.50, 'calc rate');

    end;
    $$;
\endif

