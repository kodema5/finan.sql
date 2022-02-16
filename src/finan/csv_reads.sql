create function finan.csv_reads(
    string text,
    headers text[] default null,
    delimiter text default ',',
    newline text default e'\n'
) returns setof jsonb as $$
    import csv
    import json

    ls = filter(None,
        [a.strip() for a in string.split(newline)])
    rs = csv.DictReader(ls, headers, delimiter=delimiter)
    for r in rs:
        yield json.dumps(r)
$$ language plpython3u;

-- example usage:

-- select * from finan.csv_reads(
--     e'1,2,3,4,5,6'
--     '\na,b,c,d,e,fssss'
--     '\ngęś,zółty,wąż,idzie,wąską,dróżką\n',
--     array['col1', 'col2', 'col3', 'col4', 'col5', 'col6']
-- );

-- create type finan.foo_t as (
--     a text,
--     b numeric,
--     c date
-- );

-- do $$
-- declare
--     rs finan.foo_t[];
-- begin
--     select array_agg(jsonb_populate_record(null::finan.foo_t, a))
--     into rs
--     from finan.csv_reads(
--         e'\na,b,c'
--         '\naaaa,2,2022-12-20'
--     ) a;

--     raise warning '-----%', rs[1].c + 1;
-- end;
-- $$;