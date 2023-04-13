\if :{?finan_sql}
\else
\set finan_sql true

select not exists (
    select 1 from pg_language where lanname='plpython3u'
) as include_python3u \gset

\if :include_python3u
create language plpython3u;
\endif

drop schema if exists finan cascade;
create schema finan;

-- designed for a long-running sessions, modules are cached in GD

\ir finan/black_scholes.sql
\ir finan/cashflow.sql
\ir finan/fixed_rate.sql

create function finan.init()
    returns void
    language plpython3u
    security definer
as $$
    if 'finan' in GD: return

    plpy.warning('caching finan for the session')

    import numpy
    import scipy

    import sympy
    import sympy.stats
    import datetime

    class AttrDict(dict):
        def __init__(self, *args, **kwargs):
            super(AttrDict, self).__init__(*args, **kwargs)
            self.__dict__ = self

    GD['finan'] = AttrDict({
        'numpy': numpy,
        'scipy': scipy,
        'scipy.stats': scipy.stats,
        'sympy': sympy,
        'datetime': datetime,
    })

    plpy.execute("""
        select
            finan.init_fixed_rate(), -- nper, pv, fv, pmt, rate
            finan.init_cashflow(), -- irr, mirr
            finan.init_black_scholes() -- bls*
    """)
$$;

\endif