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
    sed -i "s|#*$f|#$f|" CMakeLists.txt
done
for f in util_opencl.cpp; do
    sed -i "s|#*$f|#$f|" CMakeLists.txt
done
sed -i "s|boost::function<void.void.>|boost_function_void_void|g" *.h

cd $BASE/device || exit 1
echo "Removing CUDA etc"
for f in device_cuda.cpp device_multi.cpp device_network.cpp device_opencl.cpp; do
    sed -i "s|#*$f|#$f|" CMakeLists.txt
done
