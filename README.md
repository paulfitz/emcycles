This is a modified version of the Cycles renderer used in Blender 3D.
The modifications are limited to stripping down dependencies to the
point where it can be compiled to javascript (using emscripten).

Current status: 1.6 MB javascript output (with `elephant.xml` test
scene embedded).  On my random hardware it takes about 7 seconds to
parse the test scene and render the first pass at a little 80x60
image; 8 secs for 160x120; 22secs for 640x480.

Compiling
---------

You'll need emscripten to compile this code.  Basically, you'll be
using a specially tweaked C++ compiler that outputs javascript.
Before doing that, it is a good idea to just try compiling the code
with a regular old C++ compiler.  You'll need a compiler 
(e.g. `g++`) and `cmake`. Then:

    mkdir build && cd build && cmake .. && make

All going well, you should end up with a program called
`./bin/cycles_test` which when run spits out a bunch of 
numbers (these in fact encode a picture of two elephants).

    scene_init.
    filename faked as elephant.xml
    filename faked as elephant.xml
    session_init.
    draw_out 80 60 4!
    993 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 209 
    ...
    999 
    Got image
    session_exit.

Did that work?  Ok.  Now back out of the "build" directory, make sure
you have `emscripten` (see https://github.com/kripken/emscripten) and try this:

    mkdir js_build && cd js_build && emconfigure cmake .. && make

Note the "emconfigure" in there, that switches everything over to
a different compiler.  The resulting code is unrunnable, but 
can be converted to javascript as follows:

    cp bin/cycles_test cycles_test.bc && emcc --embed-file elephant.xml --embed-file gumbo.xml cycles_test.bc -o cycles_test.js

or to create a test html page:

    cp bin/cycles_test cycles_test.bc && emcc --embed-file elephant.xml --embed-file gumbo.xml cycles_test.bc -o cycles_test.html

You'll need patience :-).  You'll then need to fiddle with emcc's
various flags to get a good optimized result.  The .html needs to be
served by a local webserver to be viewed correctly I think.