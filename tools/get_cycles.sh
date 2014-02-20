#!/usr/bin/env bash

if [ ! -e cycles_hack ]; then

    if [ "$1" = "" ]; then
	echo "Please provide path to cycles source"
	exit 1
    fi

    csrc="$1"
    
    if [ ! -e $csrc/kernel ]; then
	echo "Cycles source not found in $csrc"
	exit 1
    fi

    echo "Fetching $csrc as cycles_hack"
    cp -r $csrc cycles_hack || exit 1

else
    if [ ! "$1" = "" ]; then
	echo "Please remove cycles_hack if you really wish to start over"
	exit 1
    fi    
fi

if [ -e CMakeCache.txt ]; then
    echo "Moving from build directory to source directory"
    cd `grep Project_SOURCE_DIR CMakeCache.txt | sed "s|.*=||"` || exit 1
fi

PROJ="$PWD"

echo "Entering cycles_hack"
cd cycles_hack || exit 1
BASE="$PWD"

echo "Tweaking CMakeLists.txt"
sed -i "s|WITH_CYCLES_BLENDER ON|WITH_CYCLES_BLENDER OFF|" CMakeLists.txt 
sed -i "s|#*add_definitions..DWITH|#add_definitions(-DWITH|" CMakeLists.txt 
grep -v "### hack" CMakeLists.txt > CMakeLists.txt.tmp || exit 1
{
    cat CMakeLists.txt.tmp || exit 1
    echo "add_subdirectory(\${CMAKE_SOURCE_DIR}/src wrapper) ### hack"
} > CMakeLists.txt || exit 1
rm -f CMakeLists.txt.tmp

cd $BASE/util || exit 1
for f in `cd $PROJ/src/replacements/util/; ls *.h *.cpp`; do
    echo "Replacing $f"
    rm -f $f
    #sed -i "s|#*$f|#$f|" CMakeLists.txt
    sed -i "s:\(\(#*\)\|\(\.\./\.\./src/replacements/util/\)\)$f:../../src/replacements/util/$f:" CMakeLists.txt
done
for f in util_opencl.cpp; do
    sed -i "s|#*$f|#$f|" CMakeLists.txt
done
# sed -i "s|boost::function<void.void.>|boost_function_void_void|g" *.h
sed -i "s|boost::function|std::function|g" *.h
sed -i "s|#define WITH_CYCLES_OPTIMIZED_KERNEL|//#define WITH_CYCLES_OPTIMIZED_KERNEL|g" *.h
sed -i "s|#define __KERNEL_SS|//#define __KERNEL_SS|g" *.h
cd $BASE/kernel
sed -i "s|#define __KERNEL_SS|//#define __KERNEL_SS|g" *.cpp
cd $BASE/render
sed -i "s|boost::function|std::function|g" *.h
cd $BASE/device
sed -i "s|boost::function|std::function|g" *.h

cd $BASE/device || exit 1
echo "Removing CUDA etc"
for f in device_cuda.cpp device_multi.cpp device_network.cpp device_opencl.cpp; do
    sed -i "s|#*$f|#$f|" CMakeLists.txt
done

echo "dropping some gl stuff"
grep -v PFHIT device.cpp > /tmp/device.cpp
awk '/pixels_copy_from\(rgba/{print;print "draw_out((char*)rgba.data_pointer,w,h,4);";print "#if 0 //PFHIT";next}1'  /tmp/device.cpp | awk '/::draw_pixels/{print "extern void draw_out(char *mem, int w, int h, int pix);"}1' | awk '/glDisable/{print;print "#endif";next}1' > device.cpp

cd $BASE/render || exit 1
echo "dropping some oiio stuff"

grep -v PFHIT image.cpp > /tmp/image.cpp
awk '/static bool is_float_image/{print;print "{ return false;";print "#if 0";next}1' /tmp/image.cpp | awk '/return is_float/{print; print "#endif"; next}1' | awk '/ImageManager::add_image/{print;print "{ return -1;";print "#if 0";next}1'| awk '/^.return slot/{print; print "#endif"; next}1' | awk '/ImageManager::remove_image/{print;print "{";print "#if 0";next}1' | awk '/ImageManager::file_load_image/{print "#endif";print "}"}1' | awk '/ImageManager::file_load(_float)?_image/{print;print "{ return false;"; print "#if 0";next}1' | awk '/return true/{print; print "#endif"; next}1' > image.cpp

grep -v PFHIT buffers.cpp > /tmp/buffers.cpp
awk '/DisplayBuffer::write/{print;print"{";print "#if 0";next}1' < /tmp/buffers.cpp | awk '/delete out/{print; print "#endif"; next}1' > buffers.cpp


cd $BASE/subd || exit 1
echo "fixing for syntax issue"
cp subd_mesh.cpp /tmp
cat /tmp/subd_mesh.cpp | sed 's/foreach(em/foreach3(pair < Key, SubdEdge* > em/' | sed 's|pair<Key|//pair<Key|' > subd_mesh.cpp

cd $BASE/util || exit 1
sed -i "s|#include <OpenImageIO|//#include <OpenImageIO|" *.h
sed -i "s|OIIO_NAMESPACE_USING|//OIIO_NAMESPACE_USING|" *.h

cd $BASE/render || exit 1
echo "tweaking enormous sobol array"
cp sobol.cpp /tmp
cat /tmp/sobol.cpp | sed "s|SOBOL_NUMBERS\[SOBOL_MAX_DIMENSIONS-1\]|SOBOL_NUMBERS[]|" | sed "s|\({135,.*}\),|\1\n};\n/\*|" | sed "s|\&SOBOL_NUMBERS\[dim-1\]|get_sobol_numbers(dim-1)|" | sed 's|\(void sobol_generate\)|*\/\n#include <stdio.h>\nSobolDirectionNumbers *get_sobol_numbers(int x) {\nif (x>134) { printf("Oops I was bluffing about sobol, bluff called: %d (see %s)\\n", x, __FILE__);\nexit(1);\n}\nreturn \&SOBOL_NUMBERS[x];\n}\n\n\1|' > sobol.cpp

