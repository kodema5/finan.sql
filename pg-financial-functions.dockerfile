# docker build -t pg-financial-functions -f pg-financial-functions.dockerfile .
# set PGPASSWORD=rei
# docker run --rm -d -p 5432:5432 -v %cd%:/work --name pg-financial-functions -e POSTGRES_PASSWORD=%PGPASSWORD% pg-financial-functions
# psql -U postgres -d postgres -f src/readme.sql
# docker stop pg-financial-functions

FROM postgres:latest

RUN apt-get update \
    && apt-get install -y \
        postgresql-plpython3-11 \
        postgresql-11-python3-multicorn \
        postgresql-11-pgtap \
        python3-pip

RUN pip3 install \
        numpy \
        pandas \
        scipy \
        scikit-learn \
        cvxopt

WORKDIR work