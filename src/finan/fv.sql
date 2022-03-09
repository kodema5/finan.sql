-- future value

create or replace function finan.fv (
      rate double precision,
      nper double precision,
      pmt double precision default 0,
      pv double precision default 0,
      due int default 0 -- end: 0, begin: 1
)
    returns double precision
    language plpython3u
    immutable
    strict
as $$
      import numpy_financial as npf
      return npf.fv(rate, nper, pmt, pv, due)
$$;


\if :test
    create or replace function tests.test_finan_fv()
        returns setof text
        language plpgsql
    as $$
    declare
        a numeric;
    begin
        a = finan.fv(0.1/4, 4*4, -2000, 0, 1);
        return next ok(trunc(a) = 39729, 'calc future-value');
    end;
    $$;
\endif
