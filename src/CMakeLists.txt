set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(PWD ${CMAKE_CURRENT_LIST_DIR})

include(qzxing.cmake)

add_library(qzxing STATIC ${QZXING_SOURCES})
target_link_libraries(qzxing PUBLIC ${QZXING_LIBRARIES})

## Verbose Debug output and save video frames
#target_compile_definitions(qzxing PRIVATE -DQZXING_TRACE)

