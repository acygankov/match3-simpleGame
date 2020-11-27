cmake_minimum_required(VERSION 3.1)

project(match3-simpleGame LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(SOURCES
    main.cpp
    gamearea.cpp
    areaitem.cpp)

set(HEADERS
    gamearea.h
    areaitem.h)

find_package(Qt5 COMPONENTS Core Quick REQUIRED)
add_executable(${PROJECT_NAME} ${SOURCES} ${HEADERS} "qml.qrc")
target_compile_definitions(${PROJECT_NAME} PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt5::Core Qt5::Quick)
