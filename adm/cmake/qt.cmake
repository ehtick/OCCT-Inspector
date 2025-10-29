#qt

# Add QtX option with description
set(QtX "Qt6" CACHE STRING "Qt version to use (Qt4, Qt5, or Qt6)")
set_property(CACHE QtX PROPERTY STRINGS Qt4 Qt5 Qt6)

# Validate QtX value
if(NOT QtX MATCHES "^Qt[456]$")
  message(FATAL_ERROR "QtX must be one of: Qt4, Qt5, Qt6")
endif()

# Qt is searched manually first (just determine root)
message (STATUS "Processing Qt 3-rd party")

# Try to find Qt in 3RDPARTY_DIR if not explicitly set
set (USE_QT_FROM_3RDPARTY_DIR TRUE)
if (NOT DEFINED 3RDPARTY_QT_DIR OR 3RDPARTY_QT_DIR STREQUAL "")
  if (3RDPARTY_DIR AND EXISTS "${3RDPARTY_DIR}")
    FIND_PRODUCT_DIR ("${3RDPARTY_DIR}" Qt 3RDPARTY_QT_DIR_NAME)

    if (3RDPARTY_QT_DIR_NAME AND NOT 3RDPARTY_QT_DIR_NAME STREQUAL "")
      # Combine directory name with absolute path and show in GUI
      set (3RDPARTY_QT_DIR "${3RDPARTY_DIR}/${3RDPARTY_QT_DIR_NAME}" CACHE PATH "The directory containing Qt" FORCE)
    else()
      set (3RDPARTY_QT_DIR "" CACHE PATH "The directory containing qt")
      set (USE_QT_FROM_3RDPARTY_DIR FALSE)
    endif()
  else()
    set (3RDPARTY_QT_DIR "" CACHE PATH "The directory containing qt")
    set (USE_QT_FROM_3RDPARTY_DIR FALSE)
  endif()
endif()

# Search for Qt based on QtX version
if (${QtX} STREQUAL "Qt6")
  if (USE_QT_FROM_3RDPARTY_DIR AND 3RDPARTY_QT_DIR)
    set(CMAKE_PREFIX_PATH ${3RDPARTY_QT_DIR})
    find_package(Qt6 REQUIRED COMPONENTS Core Gui Widgets Xml LinguistTools PATHS ${3RDPARTY_QT_DIR} NO_DEFAULT_PATH)
  elseif (${QtX}_DIR)
    find_package(Qt6 REQUIRED COMPONENTS Core Gui Widgets Xml LinguistTools PATHS ${${QtX}_DIR} NO_DEFAULT_PATH)
  else ()
    find_package(Qt6 REQUIRED COMPONENTS Core Gui Widgets Xml LinguistTools)
  endif ()
elseif (${QtX} STREQUAL "Qt5")
  if (USE_QT_FROM_3RDPARTY_DIR AND 3RDPARTY_QT_DIR)
    set(CMAKE_PREFIX_PATH ${3RDPARTY_QT_DIR})
    find_package(Qt5 REQUIRED COMPONENTS Widgets Quick Xml PATHS ${3RDPARTY_QT_DIR} NO_DEFAULT_PATH)
  elseif (${QtX}_DIR)
    find_package(Qt5 REQUIRED COMPONENTS Widgets Quick Xml PATHS ${${QtX}_DIR} NO_DEFAULT_PATH)
  else ()
    find_package(Qt5 REQUIRED COMPONENTS Widgets Quick Xml)
  endif ()
elseif (${QtX} STREQUAL "Qt4")
  if (USE_QT_FROM_3RDPARTY_DIR AND 3RDPARTY_QT_DIR)
    set(CMAKE_PREFIX_PATH ${3RDPARTY_QT_DIR})
  endif()
  find_package(Qt4)
endif ()

# Set 3RDPARTY_QT_DIR based on found Qt version
if (${Qt6_FOUND})
  if (NOT 3RDPARTY_QT_DIR OR 3RDPARTY_QT_DIR STREQUAL "")
    if (NOT USE_QT_FROM_3RDPARTY_DIR AND WIN32)
      # Qt6_DIR typically points to lib/cmake/Qt6, need to go up to Qt root
      get_filename_component(QT_CMAKE_DIR "${Qt6_DIR}" DIRECTORY)
      get_filename_component(QT_LIB_DIR "${QT_CMAKE_DIR}" DIRECTORY)
      get_filename_component(QT_ROOT_DIR "${QT_LIB_DIR}" DIRECTORY)

      # Verify this is indeed the Qt root by checking for bin directory
      if(EXISTS "${QT_ROOT_DIR}/bin")
        set(3RDPARTY_QT_DIR ${QT_ROOT_DIR} CACHE PATH "The directory containing Qt" FORCE)
      else()
        message(WARNING "Found Qt6 at ${Qt6_DIR} but could not determine Qt root directory with bin/ folder")
        set(3RDPARTY_QT_DIR ${Qt6_DIR} CACHE PATH "The directory containing Qt" FORCE)
      endif()
    elseif(NOT USE_QT_FROM_3RDPARTY_DIR)
      set(3RDPARTY_QT_DIR ${Qt6_DIR} CACHE PATH "The directory containing Qt" FORCE)
    endif()
  endif()
elseif (${Qt5_FOUND})
  if (NOT 3RDPARTY_QT_DIR OR 3RDPARTY_QT_DIR STREQUAL "")
    if (NOT USE_QT_FROM_3RDPARTY_DIR AND WIN32)
      # Qt5_DIR typically points to lib/cmake/Qt5, need to go up to Qt root
      get_filename_component(QT_CMAKE_DIR "${Qt5_DIR}" DIRECTORY)
      get_filename_component(QT_LIB_DIR "${QT_CMAKE_DIR}" DIRECTORY)
      get_filename_component(QT_ROOT_DIR "${QT_LIB_DIR}" DIRECTORY)

      # Verify this is indeed the Qt root by checking for bin directory
      if(EXISTS "${QT_ROOT_DIR}/bin")
        set(3RDPARTY_QT_DIR ${QT_ROOT_DIR} CACHE PATH "The directory containing Qt" FORCE)
      else()
        message(WARNING "Found Qt5 at ${Qt5_DIR} but could not determine Qt root directory with bin/ folder")
        set(3RDPARTY_QT_DIR ${Qt5_DIR} CACHE PATH "The directory containing Qt" FORCE)
      endif()
    elseif(NOT USE_QT_FROM_3RDPARTY_DIR)
      set(3RDPARTY_QT_DIR ${Qt5_DIR} CACHE PATH "The directory containing Qt" FORCE)
    endif()
  endif()
elseif (${Qt4_FOUND})
  if (NOT 3RDPARTY_QT_DIR OR 3RDPARTY_QT_DIR STREQUAL "")
    set(3RDPARTY_QT_DIR ${QT_QTCORE_LIBRARY} CACHE PATH "The directory containing Qt" FORCE)
  endif()
endif()

set (USED_3RDPARTY_QT_DIR "${3RDPARTY_QT_DIR}")

# Add Qt bin directory to DLL search paths
if (3RDPARTY_QT_DIR AND EXISTS "${3RDPARTY_QT_DIR}/bin")
  list (APPEND 3RDPARTY_DLL_DIRS "${3RDPARTY_QT_DIR}/bin")
else()
  list (APPEND 3RDPARTY_NO_DLLS 3RDPARTY_QT_DLL_DIR)
endif()
