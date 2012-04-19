
if [ ! -e "CMakeCache.txt" ] ; then
    echo "Run from build directory.  Example of creating build directory:"
    echo "mkdir build && cd build && emconfigure cmake .."
fi

rm -rf /tmp/emscripten_temp
# your mileage will vary...
#make && cp bin/cycles_test cycles_test.bc && EMCC_DEBUG=1 emcc --embed-file elephant.xml --embed-file gumbo.xml cycles_test.bc --llvm-opts "-globaldce -internalize -O3" --closure 0 -o cycles_test_base.js || exit 1
make && cp bin/cycles_test cycles_test.bc && EMCC_DEBUG=1 emcc --embed-file elephant.xml --embed-file gumbo.xml cycles_test.bc -O3  --llvm-opts "['-globaldce', '-internalize','-O3']" --closure 0 -o cycles_test_base.js || exit 1
echo "Post-running closure..."
EMCC=`which emcc`
CLOSURE_COMPILER="`dirname $EMCC`/third_party/closure-compiler/compiler.jar"
level="ADVANCED_OPTIMIZATIONS"
  # level="SIMPLE_OPTIMIZATIONS"
java -Xmx1024m -jar $CLOSURE_COMPILER --compilation_level $level --js cycles_test_base.js --js_output_file cycles_test.js


# set cmake build mode to Release
# hack  emscripten -- in tools/shared.py --
# def llvm_opt(filename, opts):
#    if type(opts) is int:
#      opts = Building.pick_llvm_opts(opts)
#    opts = ['-globaldce','-internalize','-O3']  ## ADD
#    cmd = [LLVM_OPT, filename] + opts + ['-o=' + filename + '.opt.bc'] ## ADD
#    print >>sys.stderr, cmd  ## MOD
#    output = Popen(cmd, stdout=PIPE).communicate()[0]
