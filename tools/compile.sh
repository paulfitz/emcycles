#!/bin/bash

set -e

make -j2

lst="cycles_test.bc"
cp bin/cycles_test $lst
for f in `cd lib; ls *.so`; do
    cp lib/$f $f.bc
    lst="$lst $f.bc"
done

cp bin/cycles_test cycles_test.bc && EMCC_DEBUG=1 emcc -O2 --embed-file elephant.xml --embed-file gumbo.xml $lst -o cycles_test.html
