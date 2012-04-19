This is a modified version of the Cycles renderer used in Blender 3D.
The modifications are limited to stripping down dependencies to the
point where it can be compiled to javascript (using emscripten).

Current status: 1.6 MB javascript output (with `elephant.xml` test
scene embedded).  On my random hardware it takes about 7 seconds to
parse the test scene and render the first pass at a little 80x60
image; 8 secs for 160x120; 22secs for 640x480.

