#!/bin/bash
set -ex

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* .

# Override PGXS FLEX/BISON paths to use conda environment versions
FLEX_BIN="$(which flex)"
BISON_BIN="$(which bison)"
PERL_BIN="$(which perl)"

if [[ "${CONDA_BUILD_CROSS_COMPILATION}" == "1" ]]; then
  chmod +x $RECIPE_DIR/arm64_pg_config
  export PG_CONFIG="${RECIPE_DIR}/arm64_pg_config"
  make FLEX="${FLEX_BIN}" BISON="${BISON_BIN}" PERL="${PERL_BIN}" DESTDIR="${PREFIX}" OPTFLAGS=""
  make install FLEX="${FLEX_BIN}" BISON="${BISON_BIN}" PERL="${PERL_BIN}"

else
  make FLEX="${FLEX_BIN}" BISON="${BISON_BIN}" PERL="${PERL_BIN}" DESTDIR="${PREFIX}" OPTFLAGS=""
  make install FLEX="${FLEX_BIN}" BISON="${BISON_BIN}" PERL="${PERL_BIN}"

  initdb -D test_db
  pg_ctl -D test_db -l test.log start

  make installcheck

  pg_ctl -D test_db stop
fi


