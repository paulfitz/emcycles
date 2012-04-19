

set(CYC ${CMAKE_SOURCE_DIR}/cycles_hack)
include_directories(${CYC}/device ${CYC}/bvh ${CYC}/util ${CYC}/render ${CYC}/kernel ${CYC}/subd ${CYC}/app ${CMAKE_CURRENT_SOURCE_DIR}) 

set(SRC
  cycles_test.cpp
  ../cycles_hack/app/cycles_xml.cpp
  ../cycles_hack/app/cycles_xml.h
  replacements/util/util_view.cpp
  replacements/util/util_path.cpp
  replacements/util/util_cache.cpp
  replacements/util/util_string.cpp
  replacements/render/sobol.cpp
  pugixml.cpp
  )
add_executable(cycles_test ${SRC})
target_link_libraries(cycles_test cycles_render cycles_device cycles_bvh cycles_kernel cycles_subd cycles_util)

foreach(f gumbo.xml elephant.xml)
  configure_file(${f} ${CMAKE_BINARY_DIR}/${f} COPYONLY)
endforeach ()

message(STATUS "Only supported command: ./app/cycles_test")
message(STATUS "Requires elephant.xml and gumbo.xml in current directory")


if (HACK_EMSCRIPTEN)

  set_property(
    TARGET cycles_test
    PROPERTY SUFFIX
    .bc)

endif()

# add_executable(rejigger_image rejigger_image.cpp)
