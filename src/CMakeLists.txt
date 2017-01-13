set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(PWD ${CMAKE_CURRENT_LIST_DIR})

include(qzxing.cmake)

add_library(qzxing STATIC ${QZXING_SOURCES})
target_link_libraries(qzxing PUBLIC ${QZXING_LIBRARIES})

target_compile_definitions(qzxing PRIVATE -DQZXING_LIBRARY)
target_compile_definitions(qzxing PRIVATE -DZXING_ICONV_CONST)
#target_compile_definitions(qzxing PRIVATE -DDISABLE_LIBRARY_FEATURES)
